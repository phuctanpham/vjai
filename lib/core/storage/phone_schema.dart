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

const _t = ColumnType.text;
const _i = ColumnType.integer;
const _r = ColumnType.real;

/// Phone schema v1 (CHG-005 › Phone schema v1, CHG-006 G-03): the table and
/// column names PowerSync must reproduce in P3 (BE-006).
class PhoneSchema {
  const PhoneSchema._();

  static const int version = 1;

  static const List<TableSpec> tables = [
    TableSpec(
      name: 'wardrobe_items',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('name', _t),
        ColumnSpec('type_code', _t),
        ColumnSpec('color', _t),
        ColumnSpec('material', _t),
        ColumnSpec('style_tag', _t),
        ColumnSpec('ai_confidence', _r),
        ColumnSpec('source_asset_id', _t),
        ColumnSpec('cutout_attachment_id', _t),
        ColumnSpec('last_worn_estimate', _t),
        ColumnSpec('archived', _i),
        ColumnSpec('created_at', _t),
        ColumnSpec('updated_at', _t),
      ],
      indexes: [
        IndexSpec(
            'wardrobe_items_owner', ['user_id', 'archived', 'created_at']),
      ],
    ),
    TableSpec(
      name: 'wear_events',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('worn_date', _t),
        ColumnSpec('candidate_id', _t),
        ColumnSpec('source', _t),
        ColumnSpec('signature', _t),
        ColumnSpec('ambient_temp_c', _i),
        ColumnSpec('items', _t),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec('wear_events_owner_date', ['user_id', 'worn_date']),
      ],
    ),
    TableSpec(
      name: 'upload_batches',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('purpose', _t),
        ColumnSpec('consent_id', _t),
        ColumnSpec('status', _t),
        ColumnSpec('req_outfit', _i),
        ColumnSpec('req_pose', _i),
        ColumnSpec('req_background', _i),
        ColumnSpec('ambient_temp_c', _i),
        ColumnSpec('created_at', _t),
        ColumnSpec('updated_at', _t),
      ],
      indexes: [
        IndexSpec('upload_batches_owner_status', ['user_id', 'status']),
      ],
    ),
    TableSpec(
      name: 'media_assets',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('batch_id', _t),
        ColumnSpec('slot_index', _i),
        ColumnSpec('mime_type', _t),
        ColumnSpec('attachment_id', _t),
        ColumnSpec('orientation', _i),
        ColumnSpec('exif_gps_stripped', _i),
        ColumnSpec('bystanders_blurred', _i),
        ColumnSpec('contains_person', _i),
        ColumnSpec('removed', _i),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec('media_assets_batch_slot', ['batch_id', 'slot_index']),
      ],
    ),
    TableSpec(
      name: 'ai_processing_jobs',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('batch_id', _t),
        ColumnSpec('asset_id', _t),
        ColumnSpec('task_type', _t),
        ColumnSpec('status', _t),
        ColumnSpec('created_at', _t),
        ColumnSpec('updated_at', _t),
      ],
      indexes: [
        IndexSpec('ai_processing_jobs_batch_asset', ['batch_id', 'asset_id']),
      ],
    ),
    TableSpec(
      name: 'extracted_items',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('batch_id', _t),
        ColumnSpec('asset_id', _t),
        ColumnSpec('item_index', _i),
        ColumnSpec('name', _t),
        ColumnSpec('confidence', _r),
        ColumnSpec('ai', _t),
        ColumnSpec('value', _t),
        ColumnSpec('last_worn_input', _t),
        ColumnSpec('cutout_attachment_id', _t),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec('extracted_items_batch_index', ['batch_id', 'item_index']),
      ],
    ),
    TableSpec(
      name: 'consents',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('version', _t),
        ColumnSpec('includes_body', _i),
        ColumnSpec('granted_at', _t),
        ColumnSpec('revoked_at', _t),
      ],
    ),
    TableSpec(
      name: 'interactions',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('session_id', _t),
        ColumnSpec('candidate_id', _t),
        ColumnSpec('action', _t),
        ColumnSpec('dwell_ms', _i),
        ColumnSpec('from_item_id', _t),
        ColumnSpec('to_item_id', _t),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec('interactions_session', ['session_id']),
      ],
    ),
    TableSpec(
      name: 'gu_match_sessions',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('path', _t),
        ColumnSpec('occasions', _t),
        ColumnSpec('raw_prompt', _t),
        ColumnSpec('eligible_item_count', _i),
        ColumnSpec('owned_only', _i),
        ColumnSpec('deck_size', _i),
        ColumnSpec('recent', _i),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec('gu_match_sessions_owner_recent', ['user_id', 'recent']),
      ],
    ),
    TableSpec(
      name: 'outfit_candidates',
      columns: [
        ColumnSpec('user_id', _t),
        ColumnSpec('session_id', _t),
        ColumnSpec('deck_order', _i),
        ColumnSpec('title', _t),
        ColumnSpec('match_pct', _i),
        ColumnSpec('highlight_reason', _t),
        ColumnSpec('visual_mode', _t),
        ColumnSpec('swipe_status', _t),
        ColumnSpec('items', _t),
        ColumnSpec('created_at', _t),
      ],
      indexes: [
        IndexSpec(
            'outfit_candidates_session_order', ['session_id', 'deck_order']),
      ],
    ),
    TableSpec(
      name: 'item_types',
      columns: [
        ColumnSpec('type_code', _t),
        ColumnSpec('group_code', _t),
        ColumnSpec('label', _t),
      ],
    ),
    TableSpec(
      name: 'session_draft',
      columns: [
        ColumnSpec('occasions', _t),
        ColumnSpec('prompt', _t),
      ],
      localOnly: true,
    ),
  ];

  /// `CREATE TABLE` and `CREATE INDEX` statements for every table.
  static List<String> createStatements() => [
        for (final table in tables) ...[
          _createTable(table),
          for (final index in table.indexes)
            'CREATE INDEX ${index.name} ON ${table.name}'
                '(${index.columns.join(', ')})',
        ],
      ];

  static String _createTable(TableSpec table) {
    if (table.localOnly) {
      // The local-only draft holds exactly one row (CHG-005 P2-D7).
      final columns = [
        for (final c in table.columns) '${c.name} ${_sqlType(c.type)} NOT NULL',
      ];
      return 'CREATE TABLE ${table.name} '
          "(id TEXT PRIMARY KEY NOT NULL CHECK (id = 'current'), "
          '${columns.join(', ')})';
    }
    final columns = [
      for (final c in table.columns) '${c.name} ${_sqlType(c.type)}',
    ];
    return 'CREATE TABLE ${table.name} '
        '(id TEXT PRIMARY KEY, ${columns.join(', ')})';
  }

  static String _sqlType(ColumnType type) => switch (type) {
        ColumnType.text => 'TEXT',
        ColumnType.integer => 'INTEGER',
        ColumnType.real => 'REAL',
      };
}
