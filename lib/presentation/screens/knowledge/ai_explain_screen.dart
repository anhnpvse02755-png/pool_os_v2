import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/knowledge_node.dart';
import '../../../domain/services/ai_explain_service.dart';

/// AI explain screen - Redesigned with Minimalist Luxury
/// Q&A over an article
class AiExplainScreen extends StatefulWidget {
  const AiExplainScreen({super.key, required this.article});
  final KnowledgeNode article;

  @override
  State<AiExplainScreen> createState() => _AiExplainScreenState();
}

class _AiExplainScreenState extends State<AiExplainScreen> {
  final TextEditingController _input = TextEditingController();
  final List<_Chat> _messages = [];
  bool _loading = false;
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    final svc = AiExplainService();
    _messages.add(_Chat(
      role: 'assistant',
      text: svc.summarize(widget.article),
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Chat(role: 'user', text: text));
      _input.clear();
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final svc = AiExplainService();
    final response = svc.ask(widget.article, text);
    if (!mounted) return;
    setState(() {
      _messages.add(_Chat(role: 'assistant', text: response));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(_brightness);

    return Scaffold(
      backgroundColor: AppColors.background(_brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(_brightness),
        elevation: 0,
        title: Text(
          'AI Explain',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(_brightness),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_loading)
            LinearProgressIndicator(
              backgroundColor: AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(_brightness),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: TextStyle(color: AppColors.textPrimary(_brightness)),
                      decoration: InputDecoration(
                        hintText: 'Hỏi về bài viết…',
                        hintStyle: TextStyle(color: AppColors.textTertiary(_brightness)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background(_brightness),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Chat m) {
    final isUser = m.role == 'user';
    final accentColor = AppColors.accentColor(_brightness);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? accentColor.withValues(alpha: 0.1)
              : AppColors.surface(_brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: AppColors.textPrimary(_brightness),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Chat {
  final String role;
  final String text;
  const _Chat({required this.role, required this.text});
}
