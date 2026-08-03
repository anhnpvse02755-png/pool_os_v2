import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/flashcard.dart';
import '../../../domain/services/spaced_repetition_service.dart';

/// Flashcard review screen — flip front/back, grade 0..5.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.articleSlug});
  final String articleSlug;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _due = [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ProviderScope.containerOf(context, listen: false).read(spacedRepetitionServiceProvider);
    final due = await svc.dueFor(widget.articleSlug);
    if (!mounted) return;
    setState(() {
      _due = due;
      _loading = false;
    });
  }

  Future<void> _grade(int grade) async {
    final svc = ProviderScope.containerOf(context, listen: false).read(spacedRepetitionServiceProvider);
    await svc.review(cardId: _due[_index].id, grade: grade);
    if (!mounted) return;
    if (_index + 1 >= _due.length) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _index++;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
          appBar: AppBar(title: const Text('Flashcards')),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_due.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(
          child: Text('Không có thẻ nào cần ôn tập hôm nay.'),
        ),
      );
    }
    final card = _due[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard ${_index + 1}/${_due.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _revealed = !_revealed),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          _revealed ? card.back : card.front,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _revealed
                                ? AppTheme.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Độ khó (0 = sai, 5 = dễ):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(6, (i) {
                return ElevatedButton(
                  onPressed: () => _grade(i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: i <= 2 ? Colors.red : Colors.green,
                  ),
                  child: Text('$i'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}