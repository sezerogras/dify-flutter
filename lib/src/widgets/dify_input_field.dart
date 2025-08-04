import 'package:flutter/material.dart';

class DifyInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final String? placeholder;
  final int maxLines;
  final bool enabled;

  const DifyInputField({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.placeholder,
    this.maxLines = 4,
    this.enabled = true,
  });

  @override
  State<DifyInputField> createState() => _DifyInputFieldState();
}

class _DifyInputFieldState extends State<DifyInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _controller.text.isNotEmpty;
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty && !widget.isLoading && widget.enabled) {
      widget.onSendMessage(text.trim());
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled && !widget.isLoading,
                  maxLines: widget.maxLines,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isComposing && !widget.isLoading && widget.enabled
                    ? theme.primaryColor
                    : theme.disabledColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isComposing && !widget.isLoading && widget.enabled
                    ? () => _handleSubmitted(_controller.text)
                    : null,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _isComposing && !widget.isLoading && widget.enabled
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 