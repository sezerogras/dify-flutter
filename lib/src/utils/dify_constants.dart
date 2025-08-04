class DifyConstants {
  static const String defaultBaseUrl = 'https://api.dify.ai/v1';
  static const String chatEndpoint = '/chat-messages';
  static const String conversationsEndpoint = '/conversations';
  static const String usersEndpoint = '/users';
  static const String filesEndpoint = '/files';
  
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration reconnectDelay = Duration(seconds: 5);
  
  static const int maxRetries = 3;
  static const int maxMessageLength = 4000;
  
  // WebSocket events
  static const String wsConnect = 'connect';
  static const String wsDisconnect = 'disconnect';
  static const String wsMessage = 'message';
  static const String wsError = 'error';
  
  // Error messages
  static const String networkError = 'Network error occurred';
  static const String timeoutError = 'Request timed out';
  static const String unauthorizedError = 'Unauthorized access';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
} 