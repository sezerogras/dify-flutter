# Dify Flutter

A comprehensive Flutter package for integrating Dify AI platform with beautiful chat UI components. This package provides a complete solution for building AI-powered chat applications using Dify's API.

## Features

- 🚀 **Easy Integration**: Simple setup with just a few lines of code
- 💬 **Beautiful Chat UI**: Modern, customizable chat interface
- 🔄 **Real-time Messaging**: Support for streaming responses
- 📱 **Cross-platform**: Works on iOS, Android, Web, and Desktop
- 🎨 **Customizable**: Highly customizable UI components
- 🔌 **Provider Pattern**: Built with Flutter Provider for state management
- 💾 **Local Storage**: Automatic user session management
- 🌐 **WebSocket Support**: Real-time communication capabilities
- 📊 **Error Handling**: Comprehensive error handling and retry mechanisms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dify_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize Dify Client

```dart
import 'package:dify_flutter/dify_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => DifyProvider(),
        child: ChatScreen(),
      ),
    );
  }
}
```

### 2. Setup Configuration

```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDify();
  }

  Future<void> _initializeDify() async {
    final provider = context.read<DifyProvider>();
    
    // Initialize with your Dify configuration
    await provider.initialize(DifyConfig(
      apiKey: 'your-dify-api-key',
      baseUrl: 'https://api.dify.ai/v1', // Optional, defaults to this
    ));
    
    // Set up user
    await provider.setCurrentUser(
      userId: 'user-123',
      name: 'John Doe',
      email: 'john@example.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DifyChatWidget(
      title: 'AI Assistant',
      placeholder: 'Ask me anything...',
    );
  }
}
```

## Advanced Usage

### Custom Chat Widget

```dart
DifyChatWidget(
  title: 'Custom Chat',
  placeholder: 'Type your message...',
  showAppBar: true,
  enableWebSocket: false,
  onError: () {
    // Handle errors
    print('Chat error occurred');
  },
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        // Open settings
      },
    ),
  ],
)
```

### Manual Message Handling

```dart
class CustomChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DifyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Custom Chat')),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return DifyMessageBubble(
                      message: message,
                      onRetry: message.status == MessageStatus.error
                          ? () => provider.sendMessage(message.content)
                          : null,
                    );
                  },
                ),
              ),
              DifyInputField(
                onSendMessage: provider.sendMessage,
                isLoading: provider.isLoading,
                placeholder: 'Type a message...',
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Conversation Management

```dart
class ConversationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DifyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Conversations'),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => provider.createConversation(),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: provider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = provider.conversations[index];
              return ListTile(
                title: Text(conversation.name),
                subtitle: Text(conversation.updatedAt.toString()),
                onTap: () => provider.loadConversation(conversation.id),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => provider.deleteConversation(conversation.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

### WebSocket Connection

```dart
// Enable WebSocket for real-time messaging
provider.connectWebSocket();

// Listen to incoming messages
provider.messageStream.listen((message) {
  print('Received message: ${message.content}');
});

// Listen to errors
provider.errorStream.listen((error) {
  print('WebSocket error: $error');
});

// Disconnect when done
provider.disconnectWebSocket();
```

## API Reference

### DifyConfig

Configuration for the Dify client.

```dart
DifyConfig({
  required String apiKey,
  String baseUrl = 'https://api.dify.ai/v1',
  String? appId,
  Duration timeout = const Duration(seconds: 30),
  Map<String, String>? headers,
})
```

### DifyProvider

Main provider class for managing Dify state.

#### Methods

- `initialize(DifyConfig config)` - Initialize the Dify client
- `setCurrentUser({required String userId, String? name, String? email, Map<String, dynamic>? metadata})` - Set current user
- `createConversation({String? name, Map<String, dynamic>? metadata})` - Create new conversation
- `loadConversation(String conversationId)` - Load conversation by ID
- `loadConversations()` - Load all conversations
- `sendMessage(String content)` - Send a message
- `deleteConversation(String conversationId)` - Delete conversation
- `connectWebSocket()` - Connect to WebSocket
- `disconnectWebSocket()` - Disconnect WebSocket

#### Properties

- `messages` - List of messages in current conversation
- `conversations` - List of all conversations
- `currentUser` - Current user
- `currentConversation` - Current conversation
- `isLoading` - Loading state
- `isConnected` - WebSocket connection state
- `error` - Current error message

### DifyMessage

Message model with the following properties:

- `id` - Unique message ID
- `content` - Message content
- `role` - Message role (user, assistant, system)
- `status` - Message status (sending, sent, error, received)
- `timestamp` - Message timestamp
- `metadata` - Additional metadata
- `conversationId` - Associated conversation ID
- `userId` - Associated user ID

### DifyConversation

Conversation model with the following properties:

- `id` - Unique conversation ID
- `name` - Conversation name
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp
- `messageIds` - List of message IDs
- `metadata` - Additional metadata
- `userId` - Associated user ID

## Customization

### Theme Customization

The package uses Flutter's theme system. You can customize colors, text styles, and other properties through your app's theme:

```dart
MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    // Customize other theme properties
  ),
  home: MyApp(),
)
```

### Custom Widgets

You can create custom message bubbles by extending or replacing the `DifyMessageBubble` widget:

```dart
class CustomMessageBubble extends StatelessWidget {
  final DifyMessage message;
  
  const CustomMessageBubble({required this.message});
  
  @override
  Widget build(BuildContext context) {
    // Your custom implementation
    return Container(
      // Custom styling
    );
  }
}
```

## Error Handling

The package provides comprehensive error handling:

```dart
Consumer<DifyProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return Center(
        child: Column(
          children: [
            Text('Error: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.clearError(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return YourWidget();
  },
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please:

1. Check the [documentation](https://pub.dev/documentation/dify_flutter)
2. Search existing [issues](https://github.com/sezerogras/dify-flutter/issues)
3. Create a new issue with detailed information

## Changelog

### 1.0.0
- Initial release
- Basic chat functionality
- WebSocket support
- Conversation management
- Beautiful UI components
- Provider pattern integration
- Error handling
- Local storage support 