/// Knowledge Article Model
class KnowledgeArticle {
  final String id;
  final String title;
  final String titleVi;
  final String category;
  final String content;
  final List<String> relatedDrillCodes;
  final List<String> relatedArticleIds;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeArticle({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.category,
    required this.content,
    this.relatedDrillCodes = const [],
    this.relatedArticleIds = const [],
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) {
    return KnowledgeArticle(
      id: json['id'],
      title: json['title'] ?? '',
      titleVi: json['title_vi'] ?? json['title'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      relatedDrillCodes: List<String>.from(json['related_drill_codes'] ?? []),
      relatedArticleIds: List<String>.from(json['related_article_ids'] ?? []),
      videoUrl: json['video_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_vi': titleVi,
      'category': category,
      'content': content,
      'related_drill_codes': relatedDrillCodes,
      'related_article_ids': relatedArticleIds,
      'video_url': videoUrl,
    };
  }
}

/// Knowledge Library - Static knowledge base
class KnowledgeLibrary {
  // Static article lists to avoid const issues
  static final List<KnowledgeArticle> _cueBallArticles = [
    KnowledgeArticle(
      id: 'stop_shot',
      title: 'Stop Shot',
      titleVi: 'Dừng bi cái',
      category: 'cueball',
      content: '''
# Dừng bi cái (Stop Shot)

## Mục tiêu
Bi cái dừng ngay tại điểm chạm với bi mục tiêu, không đi xa hơn.

## Kỹ thuật
1. **Điểm đánh**: Đánh vào tâm bi cái (hoặc hơi dưới tâm một chút)
2. **Lực đánh**: Vừa phải đến mạnh
3. **Follow through**: Đầy đủ, không dừng đột ngột

## Lưu ý
- Đánh mạnh hơn bình thường một chút để overcome friction
- Giữ cổ tay cố định
- Follow through phải dài để truyền đủ lực

## Sai lầm thường gặp
- Đánh quá nhẹ
- Điểm đánh quá cao (tạo follow)
- Follow through không đủ dài
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    KnowledgeArticle(
      id: 'draw_shot',
      title: 'Draw Shot',
      titleVi: 'Draw',
      category: 'cueball',
      content: '''
# Draw Shot

## Mục tiêu
Bi cái quay ngược lại sau khi chạm bi mục tiêu.

## Kỹ thuật
1. **Điểm đánh**: Dưới tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh vừa phải
3. **Follow through**: Dài, hướng về phía bi mục tiêu

## Các cấp độ
- **Level 1**: Draw 20-30cm
- **Level 2**: Draw 40-50cm
- **Level 3**: Draw 60-80cm
- **Level 4**: Draw gần hết bàn
- **Level 5**: Full draw

## Lưu ý
- Điểm đánh càng thấp, draw càng nhiều
- Lực đánh ảnh hưởng đến khoảng cách quay lại
- Practice kiên nhẫn để cảm nhận

## Sai lầm thường gặp
- Điểm đánh không đủ thấp
- Đánh quá nhẹ
- "Scooping" - nâng đầu cơ khi đánh
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    KnowledgeArticle(
      id: 'follow_shot',
      title: 'Follow Shot',
      titleVi: 'Follow',
      category: 'cueball',
      content: '''
# Follow Shot

## Mục tiêu
Bi cái đi cùng hướng với bi mục tiêu sau khi chạm.

## Kỹ thuật
1. **Điểm đánh**: Trên tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh hơn bình thường 20-30%
3. **Follow through**: Rất dài

## Các cấp độ
- **Level 1**: Follow 30cm
- **Level 2**: Follow 50cm
- **Level 3**: Follow 80cm
- **Level 4**: Follow 1m
- **Level 5**: Full follow

## Lưu ý
- Điểm đánh càng cao, follow càng nhiều
- Lực phải đủ mạnh để overcome backspin
- Follow through dài là chìa khóa

## Sai lầm thường gặp
- Điểm đánh không đủ cao
- Đánh quá nhẹ
- Follow through quá ngắn
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<KnowledgeArticle> _aimingArticles = [
    KnowledgeArticle(
      id: 'ghost_ball',
      title: 'Ghost Ball Method',
      titleVi: 'Phương pháp Ghost Ball',
      category: 'aiming',
      content: '''
# Phương pháp Ghost Ball

## Giới thiệu
Ghost Ball là phương pháp ngắm phổ biến nhất, giúp xác định điểm ngắm chính xác.

## Cách thực hiện
1. **Hình dung bi cái**: Tưởng tượng một bi cái "ma" (ghost ball) đặt ngay vị trí bi cái cần đến
2. **Xác định điểm tiếp xúc**: Điểm mà bi mục tiêu cần chạm bi cái
3. **Ngắm điểm**: Aim vào điểm đó

## Áp dụng cho các cú đánh
- **Cú thẳng**: Điểm ngắm là tâm lỗ
- **Cú cắt**: Điểm ngắm là điểm tiếp xúc
- **Cú bank**: Cần tính góc phản xạ

## Luyện tập
1. Đặt 2 bi thẳng hàng với lỗ
2. Ngắm bi "ma" bằng mắt
3. Thực hành nhiều lần
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    KnowledgeArticle(
      id: 'cut_shots',
      title: 'Cut Shots',
      titleVi: 'Cú cắt',
      category: 'aiming',
      content: '''
# Cut Shots - Cú cắt

## Định nghĩa
Cú cắt là cú đánh mà bi cái không đi thẳng đến bi mục tiêu mà đi theo góc.

## Góc cắt
- **0°**: Cú thẳng (straight)
- **1-30°**: Cú cắt mỏng (thin cut)
- **30-60°**: Cú cắt trung bình (medium cut)
- **60-90°**: Cú cắt dày (thick cut)

## Kỹ thuật
1. **Xác định góc**: Ước lượng góc cắt
2. **Điểm ngắm**: Dịch chuyển điểm ngắm sang phía ngược lại với góc cắt
3. **Kiểm soát lực**: Lực ảnh hưởng đến độ chính xác

## Mẹo
- Góc cắt càng lớn, cần độ chính xác càng cao
- Giảm lực khi góc cắt lớn
- Practice các góc từ dễ đến khó
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<KnowledgeArticle> _safetyArticles = [
    KnowledgeArticle(
      id: 'basic_safety',
      title: 'Basic Safety',
      titleVi: 'An toàn cơ bản',
      category: 'safety',
      content: '''
# An toàn cơ bản

## Mục tiêu
Đánh safety sao cho đối thủ khó ghi điểm.

## Nguyên tắc
1. **Để bi đối thủ xa lỗ**: Tạo khoảng cách
2. **Kiểm soát bi cái**: Không tạo cơ hội cho đối thủ
3. **Tạo thế khó**: Buộc đối thủ đánh cú khó

## Kỹ thuật
1. **Đọc bàn**: Quan sát vị trí các bi và lỗ
2. **Tính góc**: Xác định điểm đánh trên băng
3. **Kiểm soát lực**: Bi cái dừng ở vị trí mong muốn

## Các loại safety
- **Hook**: Để bi đối thủ bị kẹp
- **Side safety**: Để bi đối thủ ở bên
- **Long safety**: Đẩy bi đối thủ ra xa
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<KnowledgeArticle> _bridgeArticles = [
    KnowledgeArticle(
      id: 'open_bridge',
      title: 'Open Bridge',
      titleVi: 'Gác cơ mở',
      category: 'bridge',
      content: '''
# Gác cơ mở (Open Bridge)

## Mô tả
Đây là kiểu gác cơ phổ biến nhất, dễ thực hiện.

## Cách thực hiện
1. Đặt tay lên bàn, ngón cái hướng về phía trước
2. Ngón trỏ quấn xuống, tạo vòng
3. Các ngón còn lại đặt trên bàn
4. Khoảng trống giữa ngón cái và ngón trỏ là nơi cơ đi qua

## Lưu ý
- Tay phải chắc chắn, không rung
- Khoảng trống đủ rộng cho cơ
- Cánh tay tạo đường thẳng với cơ
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    KnowledgeArticle(
      id: 'closed_bridge',
      title: 'Closed Bridge',
      titleVi: 'Gác cơ kín',
      category: 'bridge',
      content: '''
# Gác cơ kín (Closed Bridge)

## Mô tả
Dùng khi cần kiểm soát chặt chẽ hơn, đặc biệt cho cú đánh mềm.

## Cách thực hiện
1. Đặt tay như open bridge
2. Gập ngón trỏ xuống, chạm vào ngón cái
3. Tạo vòng kín bao quanh cơ
4. Có thể dùng ngón giữa hỗ trợ

## Ưu điểm
- Kiểm soát tốt hơn
- Ít bị run
- Tốt cho cú đánh mềm, chính xác

## Nhược điểm
- Khó thực hiện hơn
- Cần practice nhiều
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<KnowledgeArticle> _strategyArticles = [
    KnowledgeArticle(
      id: 'position_play',
      title: 'Position Play',
      titleVi: 'Vị trí',
      category: 'strategy',
      content: '''
# Vị trí (Position Play)

## Tầm quan trọng
Kiểm soát vị trí bi cái là kỹ năng phân biệt người chơi giỏi và xuất sắc.

## Nguyên tắc cơ bản
1. **Plan ahead**: Luôn nghĩ đến cú tiếp theo
2. **Leave options**: Để nhiều lựa chọn cho bản thân
3. **Control pace**: Kiểm soát tốc độ bi

## Kỹ thuật
- **Speed control**: Điều khiển lực
- **Spin application**: Sử dụng xoáy
- **Natural angles**: Tận dụng góc tự nhiên

## Practice
1. Đặt 3 bi, đánh lần lượt
2. Kết thúc ở vị trí thuận lợi cho cú tiếp
3. Tăng dần độ khó
''',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  static final List<KnowledgeCategory> categories = [
    KnowledgeCategory(
      id: 'cueball',
      name: 'Cue Ball Control',
      nameVi: 'Kiểm soát bi cái',
      icon: 'circle',
      articles: _cueBallArticles,
    ),
    KnowledgeCategory(
      id: 'aiming',
      name: 'Aiming',
      nameVi: 'Ngắm',
      icon: 'visibility',
      articles: _aimingArticles,
    ),
    KnowledgeCategory(
      id: 'safety',
      name: 'Safety Play',
      nameVi: 'An toàn',
      icon: 'shield',
      articles: _safetyArticles,
    ),
    KnowledgeCategory(
      id: 'bridge',
      name: 'Bridge',
      nameVi: 'Gác cơ',
      icon: 'handyman',
      articles: _bridgeArticles,
    ),
    KnowledgeCategory(
      id: 'strategy',
      name: 'Strategy',
      nameVi: 'Chiến thuật',
      icon: 'psychology',
      articles: _strategyArticles,
    ),
  ];

  static List<KnowledgeArticle> getAllArticles() {
    final List<KnowledgeArticle> all = [];
    for (final category in categories) {
      all.addAll(category.articles);
    }
    return all;
  }

  static KnowledgeArticle? getArticle(String id) {
    for (final category in categories) {
      for (final article in category.articles) {
        if (article.id == id) return article;
      }
    }
    return null;
  }

  static List<KnowledgeArticle> getArticlesByCategory(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) {
        return category.articles;
      }
    }
    return [];
  }

  static List<KnowledgeArticle> getRelatedArticles(String articleId) {
    final article = getArticle(articleId);
    if (article == null) return [];

    return article.relatedArticleIds
        .map((id) => getArticle(id))
        .whereType<KnowledgeArticle>()
        .toList();
  }

  static List<KnowledgeArticle> searchArticles(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllArticles().where((a) {
      return a.title.toLowerCase().contains(lowerQuery) ||
          a.titleVi.toLowerCase().contains(lowerQuery) ||
          a.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

class KnowledgeCategory {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final List<KnowledgeArticle> articles;

  const KnowledgeCategory({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.articles,
  });
}
