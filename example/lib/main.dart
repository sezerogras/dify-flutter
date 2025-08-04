import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dify_flutter/dify_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dify Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => DifyProvider(),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    // Load saved data if available
    _userIdController.text = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _userNameController.text = 'Demo User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dify Flutter Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'Dify API Key',
                        hintText: 'Enter your Dify API key',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        hintText: 'Enter user ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        hintText: 'Enter user name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _initializeDify,
                      icon: Icon(Icons.play_arrow),
                      label: Text('Start Chat'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _buildFeatureItem('🚀 Easy Integration', 'Simple setup with just a few lines of code'),
                    _buildFeatureItem('💬 Beautiful Chat UI', 'Modern, customizable chat interface'),
                    _buildFeatureItem('🔄 Real-time Messaging', 'Support for streaming responses'),
                    _buildFeatureItem('📱 Cross-platform', 'Works on iOS, Android, Web, and Desktop'),
                    _buildFeatureItem('🎨 Customizable', 'Highly customizable UI components'),
                    _buildFeatureItem('🔌 Provider Pattern', 'Built with Flutter Provider for state management'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeDify() async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showError('Please enter your Dify API key');
      return;
    }

    if (_userIdController.text.trim().isEmpty) {
      _showError('Please enter a user ID');
      return;
    }

    final provider = context.read<DifyProvider>();
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Initialize Dify
      await provider.initialize(DifyConfig(
        apiKey: _apiKeyController.text.trim(),
        baseUrl: 'https://api.dify.ai/v1',
      ));

      // Set up user
      await provider.setCurrentUser(
        userId: _userIdController.text.trim(),
        name: _userNameController.text.trim(),
        email: 'demo@example.com',
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to chat screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _showError('Failed to initialize: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _userIdController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DifyChatWidget(
      title: 'Dify AI Assistant',
      placeholder: 'Ask me anything...',
      showAppBar: true,
      enableWebSocket: false,
      onError: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      },
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            final provider = context.read<DifyProvider>();
            provider.createConversation();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            _showSettings(context);
          },
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('User Info'),
              subtitle: Consumer<DifyProvider>(
                builder: (context, provider, child) {
                  return Text(provider.currentUser?.name ?? 'Not set');
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Conversations'),
              subtitle: Consumer<DifyProvider>(
                builder: (context, provider, child) {
                  return Text('${provider.conversations.length} conversations');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
} 