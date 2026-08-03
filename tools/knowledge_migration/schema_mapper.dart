// ============================================================================
// schema_mapper.dart — V1 article → V2 article
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// Real field mapping lands in Commit 2.
// ============================================================================

import 'src/migration_dto.dart';

abstract class SchemaMapper {
  /// Maps a parsed V1 article JSON into the V2 article shape.
  /// Returns the V2 JSON as a deterministic ordered map.
  Map<String, dynamic> map(V1Article v1, Map<String, dynamic> v1Json);
}

class StubSchemaMapper implements SchemaMapper {
  @override
  Map<String, dynamic> map(V1Article v1, Map<String, dynamic> v1Json) {
    // Commit 2 will replace this with real mapping logic.
    throw UnimplementedError('SchemaMapper is a skeleton. Commit 2 will implement.');
  }
}