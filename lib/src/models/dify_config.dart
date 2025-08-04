class DifyConfig {
  final String apiKey;
  final String baseUrl;
  final String? appId;
  final Duration timeout;
  final Map<String, String>? headers;

  const DifyConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.dify.ai/v1',
    this.appId,
    this.timeout = const Duration(seconds: 30),
    this.headers,
  });

  Map<String, String> get defaultHeaders => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    ...?headers,
  };

  DifyConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? appId,
    Duration? timeout,
    Map<String, String>? headers,
  }) {
    return DifyConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      appId: appId ?? this.appId,
      timeout: timeout ?? this.timeout,
      headers: headers ?? this.headers,
    );
  }
} 