import 'package:flutter/foundation.dart';

/// Column types PowerSync supports (CHG-005 P2-D7).
enum ColumnType { text, integer, real }

@immutable
class ColumnSpec {
  final String name;
  final ColumnType type;

  const ColumnSpec(this.name, this.type);
}

@immutable
class IndexSpec {
  final String name;
  final List<String> columns;

  const IndexSpec(this.name, this.columns);
}

/// One table of phone schema v1. Synced tables get `id TEXT PRIMARY KEY`
/// and no constraints; [localOnly] tables may use SQL constraints.
@immutable
class TableSpec {
  final String name;
  final List<ColumnSpec> columns;
  final List<IndexSpec> indexes;
  final bool localOnly;

  const TableSpec({
    required this.name,
    required this.columns,
    this.indexes = const [],
    this.localOnly = false,
  });
}

/// Phone schema v1 (CHG-005 › Phone schema v1): the table and column names
/// PowerSync must reproduce in P3 (BE-006).
class PhoneSchema {
  const PhoneSchema._();

  static const int version = 1;

  static List<TableSpec> get tables => throw UnimplementedError('TASK-005-S02');

  /// `CREATE TABLE` and `CREATE INDEX` statements for every table.
  static List<String> createStatements() =>
      throw UnimplementedError('TASK-005-S02');
}
