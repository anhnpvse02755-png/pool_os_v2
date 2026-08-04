import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/knowledge_node.dart';
import '../../../domain/services/ai_explain_service.dart';

/// AI explain screen — Q&A over an article (Phase C).
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

  @override
  void initState() {
    super.initState();
    final svc = AiExplainService();
    _messages.add(_Chat(
      role: 'assistant',
      text: svc.summarize(widget.article),
    ));
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
    return Scaffold(
      appBar: AppBar(title: const Text('AI Explain')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: 'Hỏi về bài viết…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppTheme.primary),
                    onPressed: _send,
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(m.text),
      ),
    );
  }
}

class _Chat {
  final String role;
  final String text;
  const _Chat({required this.role, required this.text});
}