import 'package:flutter_test/flutter_test.dart';
import 'package:dify_flutter/dify_flutter.dart';

void main() {
  group('Dify Flutter Tests', () {
    test('DifyConfig creation', () {
      final config = DifyConfig(
        apiKey: 'test-api-key',
        baseUrl: 'https://api.dify.ai/v1',
      );
      
      expect(config.apiKey, 'test-api-key');
      expect(config.baseUrl, 'https://api.dify.ai/v1');
      expect(config.timeout, const Duration(seconds: 30));
    });

    test('DifyMessage creation', () {
      final message = DifyMessage(
        id: 'test-id',
        content: 'Hello, world!',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      
      expect(message.id, 'test-id');
      expect(message.content, 'Hello, world!');
      expect(message.role, MessageRole.user);
      expect(message.status, MessageStatus.sent);
    });

    test('DifyConversation creation', () {
      final conversation = DifyConversation(
        id: 'conv-id',
        name: 'Test Conversation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(conversation.id, 'conv-id');
      expect(conversation.name, 'Test Conversation');
      expect(conversation.messageIds, isEmpty);
    });

    test('DifyUser creation', () {
      final user = DifyUser(
        id: 'user-id',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(user.id, 'user-id');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });
  });
} 