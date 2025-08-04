import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dify_message.dart';

class DifyMessageBubble extends StatelessWidget {
  final DifyMessage message;
  final bool isLastMessage;
  final VoidCallback? onRetry;

  const DifyMessageBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor,
              child: Icon(
                Icons.smart_toy,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isUser 
                  ? theme.primaryColor 
                  : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: !isUser ? Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser 
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyMedium?.color,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          color: isUser 
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                            : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (message.status == MessageStatus.sending) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUser 
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                : theme.primaryColor,
                            ),
                          ),
                        ),
                      ] else if (message.status == MessageStatus.error) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onRetry,
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 20,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 