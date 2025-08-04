import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

import 'models/dify_config.dart';
import 'models/dify_message.dart';
import 'models/dify_conversation.dart';
import 'models/dify_user.dart';
import 'utils/dify_constants.dart';

class DifyClient {
  final DifyConfig config;
  final Dio _dio;
  final Uuid _uuid = const Uuid();
  
  WebSocketChannel? _webSocketChannel;
  StreamController<DifyMessage>? _messageStreamController;
  StreamController<String>? _errorStreamController;

  DifyClient({required this.config}) : _dio = Dio() {
    _dio.options.baseUrl = config.baseUrl;
    _dio.options.headers = config.defaultHeaders;
    _dio.options.connectTimeout = config.timeout;
    _dio.options.receiveTimeout = config.timeout;
  }

  /// Send a message to Dify chat API
  Future<DifyMessage> sendMessage({
    required String message,
    String? conversationId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        DifyConstants.chatEndpoint,
        data: {
          'inputs': {},
          'query': message,
          'response_mode': 'blocking',
          'conversation_id': conversationId,
          'user': userId,
          'metadata': metadata,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return DifyMessage(
          id: _uuid.v4(),
          content: data['answer'] ?? '',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          conversationId: data['conversation_id'],
          userId: userId,
          metadata: data['metadata'],
        );
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Send a streaming message to Dify chat API
  Future<void> sendStreamingMessage({
    required String message,
    required Function(DifyMessage) onMessage,
    required Function(String) onError,
    String? conversationId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        DifyConstants.chatEndpoint,
        data: {
          'inputs': {},
          'query': message,
          'response_mode': 'streaming',
          'conversation_id': conversationId,
          'user': userId,
          'metadata': metadata,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        final stream = response.data.stream;
        String accumulatedContent = '';
        String messageId = _uuid.v4();

        await for (final chunk in stream) {
          final chunkStr = utf8.decode(chunk);
          final lines = chunkStr.split('\n');
          
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              if (data == '[DONE]') {
                // Stream completed
                return;
              }
              
              try {
                final jsonData = json.decode(data);
                final content = jsonData['answer'] ?? '';
                accumulatedContent += content;
                
                final difyMessage = DifyMessage(
                  id: messageId,
                  content: accumulatedContent,
                  role: MessageRole.assistant,
                  status: MessageStatus.sending,
                  timestamp: DateTime.now(),
                  conversationId: jsonData['conversation_id'],
                  userId: userId,
                  metadata: jsonData['metadata'],
                );
                
                onMessage(difyMessage);
              } catch (e) {
                // Skip invalid JSON
              }
            }
          }
        }
      } else {
        throw Exception('Failed to send streaming message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      onError(_handleDioError(e).toString());
    } catch (e) {
      onError('Unexpected error: $e');
    }
  }

  /// Create a new conversation
  Future<DifyConversation> createConversation({
    String? name,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        DifyConstants.conversationsEndpoint,
        data: {
          'name': name ?? 'New Conversation',
          'user': userId,
          'metadata': metadata,
        },
      );

      if (response.statusCode == 200) {
        return DifyConversation.fromJson(response.data);
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get conversation by ID
  Future<DifyConversation> getConversation(String conversationId) async {
    try {
      final response = await _dio.get(
        '${DifyConstants.conversationsEndpoint}/$conversationId',
      );

      if (response.statusCode == 200) {
        return DifyConversation.fromJson(response.data);
      } else {
        throw Exception('Failed to get conversation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all conversations for a user
  Future<List<DifyConversation>> getConversations({
    String? userId,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get(
        DifyConstants.conversationsEndpoint,
        queryParameters: {
          if (userId != null) 'user': userId,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => DifyConversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await _dio.delete(
        '${DifyConstants.conversationsEndpoint}/$conversationId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete conversation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create or get user
  Future<DifyUser> createUser({
    required String userId,
    String? name,
    String? email,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        DifyConstants.usersEndpoint,
        data: {
          'user_id': userId,
          'name': name,
          'email': email,
          'metadata': metadata,
        },
      );

      if (response.statusCode == 200) {
        return DifyUser.fromJson(response.data);
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user by ID
  Future<DifyUser> getUser(String userId) async {
    try {
      final response = await _dio.get(
        '${DifyConstants.usersEndpoint}/$userId',
      );

      if (response.statusCode == 200) {
        return DifyUser.fromJson(response.data);
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Connect to WebSocket for real-time messaging
  void connectWebSocket({
    String? conversationId,
    String? userId,
  }) {
    try {
      final wsUrl = config.baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      final wsEndpoint = '$wsUrl/chat-messages/stream';
      
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsEndpoint));
      _messageStreamController = StreamController<DifyMessage>.broadcast();
      _errorStreamController = StreamController<String>.broadcast();

      _webSocketChannel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            final message = DifyMessage.fromJson(jsonData);
            _messageStreamController?.add(message);
          } catch (e) {
            _errorStreamController?.add('Failed to parse message: $e');
          }
        },
        onError: (error) {
          _errorStreamController?.add('WebSocket error: $error');
        },
        onDone: () {
          _errorStreamController?.add('WebSocket connection closed');
        },
      );
    } catch (e) {
      _errorStreamController?.add('Failed to connect WebSocket: $e');
    }
  }

  /// Send message through WebSocket
  void sendWebSocketMessage({
    required String message,
    String? conversationId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    if (_webSocketChannel != null) {
      final data = {
        'inputs': {},
        'query': message,
        'conversation_id': conversationId,
        'user': userId,
        'metadata': metadata,
      };
      _webSocketChannel!.sink.add(json.encode(data));
    }
  }

  /// Get message stream
  Stream<DifyMessage> get messageStream {
    return _messageStreamController?.stream ?? Stream.empty();
  }

  /// Get error stream
  Stream<String> get errorStream {
    return _errorStreamController?.stream ?? Stream.empty();
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    _webSocketChannel?.sink.close();
    _messageStreamController?.close();
    _errorStreamController?.close();
    _webSocketChannel = null;
    _messageStreamController = null;
    _errorStreamController = null;
  }

  /// Dispose resources
  void dispose() {
    disconnectWebSocket();
    _dio.close();
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(DifyConstants.timeoutError);
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return Exception(DifyConstants.unauthorizedError);
        } else if (e.response?.statusCode == 500) {
          return Exception(DifyConstants.serverError);
        } else {
          return Exception('HTTP ${e.response?.statusCode}: ${e.response?.statusMessage}');
        }
      case DioExceptionType.connectionError:
        return Exception(DifyConstants.networkError);
      default:
        return Exception(DifyConstants.unknownError);
    }
  }
} 