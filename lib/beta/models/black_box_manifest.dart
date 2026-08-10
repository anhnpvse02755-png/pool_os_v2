// ============================================================================
// Black Box Manifest — Package Metadata
// Version: 2.0
// ============================================================================

/// Package manifest containing metadata and stats
class BlackBoxManifest {
  /// Schema version (immutable once released)
  final String schemaVersion = '2.0';

  /// When the package was created
  final DateTime packageCreated;

  /// Tester identifier (A01, B02, etc.)
  final String testerId;

  /// Version information
  final VersionInfo versions;

  /// Package statistics
  final PackageStats stats;

  /// Package health check
  final PackageHealth? packageHealth;

  BlackBoxManifest({
    required this.packageCreated,
    required this.testerId,
    required this.versions,
    required this.stats,
    this.packageHealth,
  });

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'packageCreated': packageCreated.toIso8601String(),
      'testerId': testerId,
      'versions': versions.toJson(),
      'stats': stats.toJson(),
      if (packageHealth != null) 'packageHealth': packageHealth!.toJson(),
    };
  }

  factory BlackBoxManifest.fromJson(Map<String, dynamic> json) {
    return BlackBoxManifest(
      packageCreated: DateTime.parse(json['packageCreated'] as String),
      testerId: json['testerId'] as String,
      versions: VersionInfo.fromJson(json['versions'] as Map<String, dynamic>),
      stats: PackageStats.fromJson(json['stats'] as Map<String, dynamic>),
      packageHealth: json['packageHealth'] != null
          ? PackageHealth.fromJson(json['packageHealth'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Package health check — validates completeness and integrity
class PackageHealth {
  /// Did export succeed?
  final bool exportSucceeded;

  /// List of missing or empty files
  final List<String> missingFiles;

  /// List of validation issues
  final List<String> validationIssues;

  /// Was validation successful?
  final bool validationPassed;

  /// SHA-256 checksum of the ZIP
  final String? checksum;

  /// Export duration in milliseconds
  final int? exportDurationMs;

  /// Timestamp of validation
  final DateTime validatedAt;

  /// Size of the ZIP in bytes
  final int? zipSizeBytes;

  PackageHealth({
    required this.exportSucceeded,
    this.missingFiles = const [],
    this.validationIssues = const [],
    required this.validationPassed,
    this.checksum,
    this.exportDurationMs,
    required this.validatedAt,
    this.zipSizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exportSucceeded': exportSucceeded,
      'missingFiles': missingFiles,
      'validationIssues': validationIssues,
      'validationPassed': validationPassed,
      if (checksum != null) 'checksum': checksum,
      if (exportDurationMs != null) 'exportDurationMs': exportDurationMs,
      'validatedAt': validatedAt.toIso8601String(),
      if (zipSizeBytes != null) 'zipSizeBytes': zipSizeBytes,
    };
  }

  factory PackageHealth.fromJson(Map<String, dynamic> json) {
    return PackageHealth(
      exportSucceeded: json['exportSucceeded'] as bool? ?? false,
      missingFiles: (json['missingFiles'] as List<dynamic>?)?.cast<String>() ?? [],
      validationIssues: (json['validationIssues'] as List<dynamic>?)?.cast<String>() ?? [],
      validationPassed: json['validationPassed'] as bool? ?? false,
      checksum: json['checksum'] as String?,
      exportDurationMs: json['exportDurationMs'] as int?,
      validatedAt: DateTime.parse(json['validatedAt'] as String),
      zipSizeBytes: json['zipSizeBytes'] as int?,
    );
  }

  /// Quick summary for display
  String get summary {
    if (!exportSucceeded) return 'Export Failed';
    if (!validationPassed) return 'Validation Failed';
    if (missingFiles.isNotEmpty) return '${missingFiles.length} files missing';
    return 'Healthy';
  }

  /// Format zip size for display
  String get formattedSize {
    if (zipSizeBytes == null) return 'Unknown';
    final kb = zipSizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

/// Version information
class VersionInfo {
  final AppVersion app;
  final String schema;
  final KnowledgeGraphVersion? knowledgeGraph;
  final CoachBrainVersion? coachBrain;

  VersionInfo({
    required this.app,
    this.schema = '2.0',
    this.knowledgeGraph,
    this.coachBrain,
  });

  Map<String, dynamic> toJson() {
    return {
      'app': app.toJson(),
      'schema': schema,
      if (knowledgeGraph != null) 'knowledgeGraph': knowledgeGraph!.toJson(),
      if (coachBrain != null) 'coachBrain': coachBrain!.toJson(),
    };
  }

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      app: AppVersion.fromJson(json['app'] as Map<String, dynamic>),
      schema: json['schema'] as String? ?? '2.0',
      knowledgeGraph: json['knowledgeGraph'] != null
          ? KnowledgeGraphVersion.fromJson(json['knowledgeGraph'] as Map<String, dynamic>)
          : null,
      coachBrain: json['coachBrain'] != null
          ? CoachBrainVersion.fromJson(json['coachBrain'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AppVersion {
  final String name;
  final String version;
  final String build;
  final String channel;

  AppVersion({
    this.name = 'PoolOS',
    required this.version,
    required this.build,
    this.channel = 'beta',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'build': build,
      'channel': channel,
    };
  }

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      name: json['name'] as String? ?? 'PoolOS',
      version: json['version'] as String? ?? '1.0.0',
      build: json['build'] as String? ?? '1',
      channel: json['channel'] as String? ?? 'beta',
    );
  }
}

class KnowledgeGraphVersion {
  final String version;
  final String? buildDate;
  final int totalNodes;

  KnowledgeGraphVersion({
    required this.version,
    this.buildDate,
    this.totalNodes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      if (buildDate != null) 'buildDate': buildDate,
      'totalNodes': totalNodes,
    };
  }

  factory KnowledgeGraphVersion.fromJson(Map<String, dynamic> json) {
    return KnowledgeGraphVersion(
      version: json['version'] as String,
      buildDate: json['buildDate'] as String?,
      totalNodes: json['totalNodes'] as int? ?? 0,
    );
  }
}

class CoachBrainVersion {
  final String priorityEngine;
  final String coachService;
  final String conversationEngine;
  final String? buildDate;

  CoachBrainVersion({
    required this.priorityEngine,
    required this.coachService,
    required this.conversationEngine,
    this.buildDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'priorityEngine': priorityEngine,
      'coachService': coachService,
      'conversationEngine': conversationEngine,
      if (buildDate != null) 'buildDate': buildDate,
    };
  }

  factory CoachBrainVersion.fromJson(Map<String, dynamic> json) {
    return CoachBrainVersion(
      priorityEngine: json['priorityEngine'] as String,
      coachService: json['coachService'] as String,
      conversationEngine: json['conversationEngine'] as String,
      buildDate: json['buildDate'] as String?,
    );
  }
}

/// Package statistics
class PackageStats {
  final int sessionsTotal;
  final int sessionsCompleted;
  final int sessionsInterrupted;
  final int matchesTotal;
  final int recommendationsTotal;
  final int conversationsTotal;
  final int eventsTotal;
  final String packageSize;

  PackageStats({
    this.sessionsTotal = 0,
    this.sessionsCompleted = 0,
    this.sessionsInterrupted = 0,
    this.matchesTotal = 0,
    this.recommendationsTotal = 0,
    this.conversationsTotal = 0,
    this.eventsTotal = 0,
    this.packageSize = '0 MB',
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionsTotal': sessionsTotal,
      'sessionsCompleted': sessionsCompleted,
      'sessionsInterrupted': sessionsInterrupted,
      'matchesTotal': matchesTotal,
      'recommendationsTotal': recommendationsTotal,
      'conversationsTotal': conversationsTotal,
      'eventsTotal': eventsTotal,
      'packageSize': packageSize,
    };
  }

  factory PackageStats.fromJson(Map<String, dynamic> json) {
    return PackageStats(
      sessionsTotal: json['sessionsTotal'] as int? ?? 0,
      sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
      sessionsInterrupted: json['sessionsInterrupted'] as int? ?? 0,
      matchesTotal: json['matchesTotal'] as int? ?? 0,
      recommendationsTotal: json['recommendationsTotal'] as int? ?? 0,
      conversationsTotal: json['conversationsTotal'] as int? ?? 0,
      eventsTotal: json['eventsTotal'] as int? ?? 0,
      packageSize: json['packageSize'] as String? ?? '0 MB',
    );
  }
}
