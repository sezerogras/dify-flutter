import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dify_provider.dart';
import '../models/dify_message.dart';
import 'dify_message_bubble.dart';
import 'dify_input_field.dart';

class DifyChatWidget extends StatefulWidget {
  final String? title;
  final String? placeholder;
  final bool showAppBar;
  final bool enableWebSocket;
  final VoidCallback? onError;
  final Widget? leading;
  final List<Widget>? actions;

  const DifyChatWidget({
    super.key,
    this.title,
    this.placeholder,
    this.showAppBar = true,
    this.enableWebSocket = false,
    this.onError,
    this.leading,
    this.actions,
  });

  @override
  State<DifyChatWidget> createState() => _DifyChatWidgetState();
}

class _DifyChatWidgetState extends State<DifyChatWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String message) {
    final provider = context.read<DifyProvider>();
    provider.sendMessage(message).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  void _handleRetry(DifyMessage message) {
    final provider = context.read<DifyProvider>();
    provider.sendMessage(message.content);
  }

  void _handleError(String error) {
    if (widget.onError != null) {
      widget.onError!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DifyProvider>(
      builder: (context, provider, child) {
        // Listen for errors
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleError(provider.error!);
            provider.clearError();
          });
        }

        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(
                  title: Text(widget.title ?? 'Dify Chat'),
                  leading: widget.leading,
                  actions: widget.actions,
                  elevation: 1,
                )
              : null,
          body: Column(
            children: [
              Expanded(
                child: provider.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(provider),
              ),
              DifyInputField(
                onSendMessage: _handleSendMessage,
                isLoading: provider.isLoading,
                placeholder: widget.placeholder,
                enabled: provider.currentUser != null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting with Dify AI',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(DifyProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        final isLastMessage = index == provider.messages.length - 1;
        
        return DifyMessageBubble(
          message: message,
          isLastMessage: isLastMessage,
          onRetry: message.status == MessageStatus.error
              ? () => _handleRetry(message)
              : null,
        );
      },
    );
  }
} 