import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../dify_client.dart';
import '../models/dify_config.dart';
import '../models/dify_message.dart';
import '../models/dify_conversation.dart';
import '../models/dify_user.dart';

class DifyProvider extends ChangeNotifier {
  DifyClient? _client;
  DifyConfig? _config;
  DifyUser? _currentUser;
  DifyConversation? _currentConversation;
  List<DifyMessage> _messages = [];
  List<DifyConversation> _conversations = [];
  
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;
  
  final Uuid _uuid = const Uuid();
  StreamSubscription<DifyMessage>? _messageSubscription;
  StreamSubscription<String>? _errorSubscription;

  // Getters
  DifyClient? get client => _client;
  DifyConfig? get config => _config;
  DifyUser? get currentUser => _currentUser;
  DifyConversation? get currentConversation => _currentConversation;
  List<DifyMessage> get messages => List.unmodifiable(_messages);
  List<DifyConversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;

  /// Initialize the Dify client
  Future<void> initialize(DifyConfig config) async {
    try {
      _setLoading(true);
      _config = config;
      _client = DifyClient(config: config);
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create or get current user
  Future<void> setCurrentUser({
    required String userId,
    String? name,
    String? email,
    Map<String, dynamic>? metadata,
  }) async {
    if (_client == null) {
      _setError('Client not initialized');
      return;
    }

    try {
      _setLoading(true);
      _currentUser = await _client!.createUser(
        userId: userId,
        name: name,
        email: email,
        metadata: metadata,
      );
      
      // Save user ID to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dify_user_id', userId);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to set user: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user from local storage
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('dify_user_id');
      
      if (userId != null && _client != null) {
        _currentUser = await _client!.getUser(userId);
        notifyListeners();
      }
    } catch (e) {
      // User might not exist, ignore error
    }
  }

  /// Create a new conversation
  Future<void> createConversation({
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    if (_client == null || _currentUser == null) {
      _setError('Client or user not initialized');
      return;
    }

    try {
      _setLoading(true);
      _currentConversation = await _client!.createConversation(
        name: name,
        userId: _currentUser!.id,
        metadata: metadata,
      );
      
      _conversations.insert(0, _currentConversation!);
      _messages.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to create conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load conversation
  Future<void> loadConversation(String conversationId) async {
    if (_client == null) {
      _setError('Client not initialized');
      return;
    }

    try {
      _setLoading(true);
      _currentConversation = await _client!.getConversation(conversationId);
      _messages.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all conversations
  Future<void> loadConversations() async {
    if (_client == null || _currentUser == null) {
      _setError('Client or user not initialized');
      return;
    }

    try {
      _setLoading(true);
      _conversations = await _client!.getConversations(
        userId: _currentUser!.id,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load conversations: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (_client == null || _currentUser == null) {
      _setError('Client or user not initialized');
      return;
    }

    if (content.trim().isEmpty) return;

    // Create user message
    final userMessage = DifyMessage(
      id: _uuid.v4(),
      content: content,
      role: MessageRole.user,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      conversationId: _currentConversation?.id,
      userId: _currentUser!.id,
    );

    _messages.add(userMessage);
    notifyListeners();

    // Create assistant message placeholder
    final assistantMessage = DifyMessage(
      id: _uuid.v4(),
      content: '',
      role: MessageRole.assistant,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      conversationId: _currentConversation?.id,
      userId: _currentUser!.id,
    );

    _messages.add(assistantMessage);
    notifyListeners();

    try {
      await _client!.sendStreamingMessage(
        message: content,
        conversationId: _currentConversation?.id,
        userId: _currentUser!.id,
        onMessage: (message) {
          // Update the assistant message
          final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
          if (index != -1) {
            _messages[index] = message.copyWith(
              status: MessageStatus.sending,
            );
            notifyListeners();
          }
        },
        onError: (error) {
          _setError(error);
          // Update message status to error
          final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(
              status: MessageStatus.error,
            );
            notifyListeners();
          }
        },
      );

      // Update final message status
      final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          status: MessageStatus.sent,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to send message: $e');
      // Update message status to error
      final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          status: MessageStatus.error,
        );
        notifyListeners();
      }
    }
  }

  /// Connect to WebSocket
  void connectWebSocket() {
    if (_client == null) {
      _setError('Client not initialized');
      return;
    }

    try {
      _client!.connectWebSocket(
        conversationId: _currentConversation?.id,
        userId: _currentUser?.id,
      );

      _messageSubscription = _client!.messageStream.listen(
        (message) {
          _messages.add(message);
          notifyListeners();
        },
        onError: (error) {
          _setError('WebSocket error: $error');
        },
      );

      _errorSubscription = _client!.errorStream.listen(
        (error) {
          _setError(error);
        },
      );

      _isConnected = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to connect WebSocket: $e');
    }
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    _client?.disconnectWebSocket();
    _messageSubscription?.cancel();
    _errorSubscription?.cancel();
    _isConnected = false;
    notifyListeners();
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    if (_client == null) {
      _setError('Client not initialized');
      return;
    }

    try {
      _setLoading(true);
      await _client!.deleteConversation(conversationId);
      
      _conversations.removeWhere((c) => c.id == conversationId);
      
      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
        _messages.clear();
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectWebSocket();
    _client?.dispose();
    super.dispose();
  }
} 