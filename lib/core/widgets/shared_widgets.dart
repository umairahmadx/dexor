import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class ThemedCodeEditor extends StatefulWidget {
  const ThemedCodeEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.minLines = 3,
    this.maxLines = 10,
    this.hint = 'Enter content...',
    this.readOnly = false,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  final String hint;
  final bool readOnly;

  @override
  State<ThemedCodeEditor> createState() => _ThemedCodeEditorState();
}

class _ThemedCodeEditorState extends State<ThemedCodeEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  @override
  void didUpdateWidget(covariant ThemedCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text when initialValue changes from parent
    // but only if the widget is readOnly or the value truly differs
    if (widget.initialValue != _controller.text && widget.readOnly) {
      _controller.removeListener(_onTextChanged);
      _controller.text = widget.initialValue;
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: AppTokens.fast,
      curve: AppTokens.standardCurve,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}

class SplitPane extends StatefulWidget {
  const SplitPane({
    super.key,
    required this.left,
    required this.right,
    this.ratio = 0.5,
  });

  final Widget left;
  final Widget right;
  final double ratio;

  @override
  State<SplitPane> createState() => _SplitPaneState();
}

class _SplitPaneState extends State<SplitPane> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final leftWidth = screenWidth * _ratio;
    const dividerWidth = 4.0;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _ratio += details.delta.dx / screenWidth;
          _ratio = _ratio.clamp(0.2, 0.8);
        });
      },
      child: Row(
        children: [
          SizedBox(width: leftWidth, child: widget.left),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: dividerWidth,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          Expanded(child: widget.right),
        ],
      ),
    );
  }
}

class ToolStatusBar extends StatelessWidget {
  const ToolStatusBar({super.key, required this.info});

  final List<String> info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: AppColors.valid),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 16,
              children: [for (final text in info) Text(text)],
            ),
          ),
        ],
      ),
    );
  }
}

class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.text, this.label = 'Copy'});

  final String text;
  final String label;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: widget.text));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${widget.label} copied!')));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      icon: Icon(_copied ? Icons.check : Icons.copy),
      label: Text(widget.label),
    );
  }
}
