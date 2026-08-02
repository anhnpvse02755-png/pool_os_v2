/// Skill Certification Model
class SkillCertification {
  final String id;
  final String name;
  final String nameVi;
  final String category;
  final String description;
  final List<CertificationTest> tests;
  final DateTime createdAt;

  SkillCertification({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.description,
    required this.tests,
    required this.createdAt,
  });

  factory SkillCertification.fromJson(Map<String, dynamic> json) {
    return SkillCertification(
      id: json['id'],
      name: json['name'] ?? '',
      nameVi: json['name_vi'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      tests: (json['tests'] as List<dynamic>?)
              ?.map((e) => CertificationTest.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Individual test within a certification
class CertificationTest {
  final String id;
  final String title;
  final String titleVi;
  final String instructions;
  final int requiredSuccesses;
  final int totalAttempts;
  final String difficulty;
  final String? videoUrl;

  CertificationTest({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.instructions,
    required this.requiredSuccesses,
    required this.totalAttempts,
    this.difficulty = 'medium',
    this.videoUrl,
  });

  factory CertificationTest.fromJson(Map<String, dynamic> json) {
    return CertificationTest(
      id: json['id'],
      title: json['title'] ?? '',
      titleVi: json['title_vi'] ?? json['title'] ?? '',
      instructions: json['instructions'] ?? '',
      requiredSuccesses: json['required_successes'] ?? 8,
      totalAttempts: json['total_attempts'] ?? 10,
      difficulty: json['difficulty'] ?? 'medium',
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_vi': titleVi,
      'instructions': instructions,
      'required_successes': requiredSuccesses,
      'total_attempts': totalAttempts,
      'difficulty': difficulty,
      'video_url': videoUrl,
    };
  }

  double get passRate => requiredSuccesses / totalAttempts * 100;
}

/// Certification result
class CertificationResult {
  final String certificationId;
  final String testId;
  final int attempts;
  final int successes;
  final double successRate;
  final bool passed;
  final DateTime completedAt;

  CertificationResult({
    required this.certificationId,
    required this.testId,
    required this.attempts,
    required this.successes,
    required this.successRate,
    required this.passed,
    required this.completedAt,
  });

  factory CertificationResult.fromJson(Map<String, dynamic> json) {
    return CertificationResult(
      certificationId: json['certification_id'],
      testId: json['test_id'],
      attempts: json['attempts'] ?? 0,
      successes: json['successes'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certification_id': certificationId,
      'test_id': testId,
      'attempts': attempts,
      'successes': successes,
      'success_rate': successRate,
      'passed': passed,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

/// Skill Certification Library
class CertificationLibrary {
  static final List<SkillCertification> certifications = [
    SkillCertification(
      id: 'stop_shot_cert',
      name: 'Stop Shot Certification',
      nameVi: 'Chứng nhận Stop Shot',
      category: 'cueball',
      description: 'Kiểm tra khả năng dừng bi cái chính xác',
      tests: [
        CertificationTest(
          id: 'stop_basic',
          title: 'Basic Stop',
          titleVi: 'Stop cơ bản',
          instructions: 'Đánh bi cái dừng trong vòng 10cm từ điểm chạm. Thực hiện 10 lần, cần đạt 8 lần thành công.',
          requiredSuccesses: 8,
          totalAttempts: 10,
          difficulty: 'easy',
        ),
        CertificationTest(
          id: 'stop_advanced',
          title: 'Advanced Stop',
          titleVi: 'Stop nâng cao',
          instructions: 'Đánh bi cái dừng trong vòng 5cm từ điểm chạm. Thực hiện 10 lần, cần đạt 8 lần thành công.',
          requiredSuccesses: 8,
          totalAttempts: 10,
          difficulty: 'medium',
        ),
      ],
      createdAt: DateTime.now(),
    ),
    SkillCertification(
      id: 'draw_shot_cert',
      name: 'Draw Shot Certification',
      nameVi: 'Chứng nhận Draw',
      category: 'cueball',
      description: 'Kiểm tra khả năng draw bi cái quay về',
      tests: [
        CertificationTest(
          id: 'draw_basic',
          title: 'Basic Draw',
          titleVi: 'Draw cơ bản',
          instructions: 'Draw bi cái quay lại ít nhất 30cm. Thực hiện 10 lần, cần đạt 6 lần thành công.',
          requiredSuccesses: 6,
          totalAttempts: 10,
          difficulty: 'easy',
        ),
        CertificationTest(
          id: 'draw_medium',
          title: 'Medium Draw',
          titleVi: 'Draw trung bình',
          instructions: 'Draw bi cái quay lại ít nhất 50cm. Thực hiện 10 lần, cần đạt 7 lần thành công.',
          requiredSuccesses: 7,
          totalAttempts: 10,
          difficulty: 'medium',
        ),
        CertificationTest(
          id: 'draw_advanced',
          title: 'Advanced Draw',
          titleVi: 'Draw nâng cao',
          instructions: 'Draw bi cái quay lại ít nhất 80cm. Thực hiện 10 lần, cần đạt 8 lần thành công.',
          requiredSuccesses: 8,
          totalAttempts: 10,
          difficulty: 'hard',
        ),
      ],
      createdAt: DateTime.now(),
    ),
    SkillCertification(
      id: 'follow_shot_cert',
      name: 'Follow Shot Certification',
      nameVi: 'Chứng nhận Follow',
      category: 'cueball',
      description: 'Kiểm tra khả năng follow bi cái đi tới',
      tests: [
        CertificationTest(
          id: 'follow_basic',
          title: 'Basic Follow',
          titleVi: 'Follow cơ bản',
          instructions: 'Follow bi cái đi ít nhất 40cm. Thực hiện 10 lần, cần đạt 6 lần thành công.',
          requiredSuccesses: 6,
          totalAttempts: 10,
          difficulty: 'easy',
        ),
        CertificationTest(
          id: 'follow_medium',
          title: 'Medium Follow',
          titleVi: 'Follow trung bình',
          instructions: 'Follow bi cái đi ít nhất 80cm. Thực hiện 10 lần, cần đạt 7 lần thành công.',
          requiredSuccesses: 7,
          totalAttempts: 10,
          difficulty: 'medium',
        ),
        CertificationTest(
          id: 'follow_advanced',
          title: 'Advanced Follow',
          titleVi: 'Follow nâng cao',
          instructions: 'Follow bi cái đi ít nhất 1m. Thực hiện 10 lần, cần đạt 8 lần thành công.',
          requiredSuccesses: 8,
          totalAttempts: 10,
          difficulty: 'hard',
        ),
      ],
      createdAt: DateTime.now(),
    ),
    SkillCertification(
      id: 'bank_shot_cert',
      name: 'Bank Shot Certification',
      nameVi: 'Chứng nhận Bank',
      category: 'potting',
      description: 'Kiểm tra khả năng đánh bank',
      tests: [
        CertificationTest(
          id: 'bank_basic',
          title: 'Basic Bank',
          titleVi: 'Bank cơ bản',
          instructions: 'Đánh bi chạm băng vào lỗ đối diện. Thực hiện 10 lần, cần đạt 5 lần thành công.',
          requiredSuccesses: 5,
          totalAttempts: 10,
          difficulty: 'medium',
        ),
        CertificationTest(
          id: 'bank_advanced',
          title: 'Advanced Bank',
          titleVi: 'Bank nâng cao',
          instructions: 'Đánh bank với góc khó. Thực hiện 10 lần, cần đạt 6 lần thành công.',
          requiredSuccesses: 6,
          totalAttempts: 10,
          difficulty: 'hard',
        ),
      ],
      createdAt: DateTime.now(),
    ),
    SkillCertification(
      id: 'position_cert',
      name: 'Position Control Certification',
      nameVi: 'Chứng nhận Vị trí',
      category: 'position',
      description: 'Kiểm tra khả năng kiểm soát vị trí bi cái',
      tests: [
        CertificationTest(
          id: 'position_basic',
          title: 'Basic Position',
          titleVi: 'Vị trí cơ bản',
          instructions: 'Điều khiển bi cái đến vùng chỉ định (30cm). Thực hiện 10 lần, cần đạt 6 lần thành công.',
          requiredSuccesses: 6,
          totalAttempts: 10,
          difficulty: 'easy',
        ),
        CertificationTest(
          id: 'position_3ball',
          title: '3-Ball Position',
          titleVi: 'Position 3 bi',
          instructions: 'Đánh 3 bi theo thứ tự, kết thúc ở vị trí chỉ định. Thực hiện 5 lần, cần đạt 3 lần thành công.',
          requiredSuccesses: 3,
          totalAttempts: 5,
          difficulty: 'hard',
        ),
      ],
      createdAt: DateTime.now(),
    ),
  ];

  static SkillCertification? getCertification(String id) {
    return certifications.firstWhere(
      (c) => c.id == id,
      orElse: () => certifications.first,
    );
  }

  static List<SkillCertification> getByCategory(String category) {
    return certifications.where((c) => c.category == category).toList();
  }
}
