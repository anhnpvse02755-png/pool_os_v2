import '../../data/models/knowledge_node.dart';

/// Phase C: AI summary / explain / ask service.
///
/// Backed locally — no remote LLM call yet; service exposes a stable
/// interface so a remote model can be plugged in later.
class AiExplainService {
  AiExplainService();

  /// Generate a 2-3 sentence summary of an article.
  String summarize(KnowledgeNode article) {
    return '${article.title}. ${_tone(article)}';
  }

  /// Explain a sentence / paragraph using simple heuristics. The real
  /// model would call out to an LLM.
  String explain(KnowledgeNode article, String passage) {
    return 'Giải thích: ${article.title} — $passage';
  }

  /// Free-form Q&A. Stub response that surfaces relevant context.
  String ask(KnowledgeNode article, String question) {
    return 'Câu hỏi: $question\n'
        'Ngữ cảnh: ${article.title} — ${article.category} — ${article.difficulty}.\n'
        'Trả lời (stub): Hãy tham khảo bài viết gốc để hiểu chi tiết.';
  }

  String _tone(KnowledgeNode article) {
    switch (article.difficulty) {
      case 'advanced':
        return 'Bài viết nâng cao dành cho người chơi đã có nền tảng vững.';
      case 'master':
        return 'Bài viết chuyên sâu dành cho người chơi chuyên nghiệp.';
      case 'intermediate':
        return 'Bài viết trung cấp, phù hợp cho người chơi đang tiến bộ.';
      default:
        return 'Bài viết cơ bản, phù hợp cho người mới bắt đầu.';
    }
  }
}