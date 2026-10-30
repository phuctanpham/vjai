import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/phone_schema.dart';

import '../../helpers/local_db.dart';

const _t = ColumnType.text;
const _i = ColumnType.integer;
const _r = ColumnType.real;

/// Phone schema v1 (CHG-005 › Phone schema v1). `id` is implicit and not
/// listed. Dates are ISO text, booleans INTEGER, JSON TEXT.
const Map<String, Map<String, ColumnType>> _contract = {
  'wardrobe_items': {
    'user_id': _t,
    'name': _t,
    'type_code': _t,
    'color': _t,
    'material': _t,
    'style_tag': _t,
    'ai_confidence': _r,
    'source_asset_id': _t,
    'cutout_attachment_id': _t,
    'last_worn_estimate': _t,
    'archived': _i,
    'created_at': _t,
    'updated_at': _t,
  },
  'wear_events': {
    'user_id': _t,
    'worn_date': _t,
    'candidate_id': _t,
    'source': _t,
    'signature': _t,
    'ambient_temp_c': _i,
    'items': _t,
    'created_at': _t,
  },
  'upload_batches': {
    'user_id': _t,
    'purpose': _t,
    'consent_id': _t,
    'status': _t,
    'req_outfit': _i,
    'req_pose': _i,
    'req_background': _i,
    'ambient_temp_c': _i,
    'created_at': _t,
    'updated_at': _t,
  },
  'media_assets': {
    'user_id': _t,
    'batch_id': _t,
    'slot_index': _i,
    'mime_type': _t,
    'attachment_id': _t,
    'orientation': _i,
    'exif_gps_stripped': _i,
    'bystanders_blurred': _i,
    'contains_person': _i,
    'removed': _i,
    'created_at': _t,
  },
  // Spec T2 AI_JOBS, added by CHG-006 G-03.
  'ai_processing_jobs': {
    'user_id': _t,
    'batch_id': _t,
    'asset_id': _t,
    'task_type': _t,
    'status': _t,
    'created_at': _t,
    'updated_at': _t,
  },
  'extracted_items': {
    'user_id': _t,
    'batch_id': _t,
    'asset_id': _t,
    'item_index': _i,
    'name': _t,
    'confidence': _r,
    'ai': _t,
    'value': _t,
    'last_worn_input': _t,
    'cutout_attachment_id': _t,
    'created_at': _t,
  },
  'consents': {
    'user_id': _t,
    'version': _t,
    'includes_body': _i,
    'granted_at': _t,
    'revoked_at': _t,
  },
  'interactions': {
    'user_id': _t,
    'session_id': _t,
    'candidate_id': _t,
    'action': _t,
    'dwell_ms': _i,
    'from_item_id': _t,
    'to_item_id': _t,
    'created_at': _t,
  },
  'gu_match_sessions': {
    'user_id': _t,
    'path': _t,
    'occasions': _t,
    'raw_prompt': _t,
    'eligible_item_count': _i,
    'owned_only': _i,
    'deck_size': _i,
    'recent': _i,
    'created_at': _t,
  },
  'outfit_candidates': {
    'user_id': _t,
    'session_id': _t,
    'deck_order': _i,
    'title': _t,
    'match_pct': _i,
    'highlight_reason': _t,
    'visual_mode': _t,
    'swipe_status': _t,
    'items': _t,
    'created_at': _t,
  },
  'item_types': {
    'type_code': _t,
    'group_code': _t,
    'label': _t,
  },
  'session_draft': {
    'occasions': _t,
    'prompt': _t,
  },
};

const Map<String, List<List<String>>> _indexes = {
  'wardrobe_items': [
    ['user_id', 'archived', 'created_at'],
  ],
  'wear_events': [
    ['user_id', 'worn_date'],
  ],
  'upload_batches': [
    ['user_id', 'status'],
  ],
  'media_assets': [
    ['batch_id', 'slot_index'],
  ],
  'ai_processing_jobs': [
    ['batch_id', 'asset_id'],
  ],
  'extracted_items': [
    ['batch_id', 'item_index'],
  ],
  'gu_match_sessions': [
    ['user_id', 'recent'],
  ],
  'outfit_candidates': [
    ['session_id', 'deck_order'],
  ],
  'interactions': [
    ['session_id'],
  ],
};

String _sqlType(ColumnType type) => switch (type) {
      ColumnType.text => 'TEXT',
      ColumnType.integer => 'INTEGER',
      ColumnType.real => 'REAL',
    };

void main() {
  group('PhoneSchema declaration', () {
    test('[TASK-005-S02] is version 1', () {
      expect(PhoneSchema.version, 1);
    });

    test('[TASK-005-S02] has exactly the v1 tables', () {
      expect(PhoneSchema.tables.map((t) => t.name).toSet(),
          _contract.keys.toSet());
    });

    test('[TASK-005-S02] columns and types match the contract', () {
      for (final table in PhoneSchema.tables) {
        final declared = {for (final c in table.columns) c.name: c.type};
        expect(declared, _contract[table.name], reason: table.name);
        expect(declared.containsKey('id'), isFalse,
            reason: '${table.name}: id is implicit');
      }
    });

    test('[TASK-005-S02] declares the contract indexes', () {
      for (final table in PhoneSchema.tables) {
        expect(
          table.indexes.map((i) => i.columns).toList(),
          _indexes[table.name] ?? const <List<String>>[],
          reason: table.name,
        );
      }
    });

    test('[TASK-005-S02] only session_draft is local-only', () {
      final localOnly =
          PhoneSchema.tables.where((t) => t.localOnly).map((t) => t.name);
      expect(localOnly, ['session_draft']);
    });

    test('[TASK-005-S02] synced tables have no FK or UNIQUE (PowerSync views)',
        () {
      final synced = {
        for (final t in PhoneSchema.tables)
          if (!t.localOnly) t.name,
      };
      final statements = PhoneSchema.createStatements();
      for (final sql in statements) {
        final upper = sql.toUpperCase();
        final forSynced = synced.any((name) => sql.contains(' $name'));
        if (!forSynced) continue;
        expect(upper, isNot(contains('REFERENCES')), reason: sql);
        expect(upper, isNot(contains('FOREIGN KEY')), reason: sql);
        expect(upper, isNot(contains('UNIQUE')), reason: sql);
        expect(upper, isNot(contains('CHECK')), reason: sql);
        expect(upper, isNot(contains('NOT NULL')), reason: sql);
      }
    });
  });

  group('PhoneSchema in SQLite', () {
    late TestDatabase t;

    setUp(() async => t = await TestDatabase.open());
    tearDown(() async => t.dispose());

    test('[TASK-005-S02] every table has id TEXT PRIMARY KEY', () async {
      for (final name in _contract.keys) {
        final info = await t.db.getAll('PRAGMA table_info($name)');
        final id = info.singleWhere((c) => c['name'] == 'id');
        expect(id['type'], 'TEXT', reason: name);
        expect(id['pk'], 1, reason: name);
        expect(info.where((c) => (c['pk'] as int) > 0), hasLength(1),
            reason: '$name: single-column key');
      }
    });

    test('[TASK-005-S02] table columns and declared types match', () async {
      for (final entry in _contract.entries) {
        final info = await t.db.getAll('PRAGMA table_info(${entry.key})');
        final actual = {
          for (final c in info)
            if (c['name'] != 'id') c['name'] as String: c['type'] as String,
        };
        expect(
          actual,
          {for (final c in entry.value.entries) c.key: _sqlType(c.value)},
          reason: entry.key,
        );
      }
    });

    test('[TASK-005-S02] synced tables have no foreign keys', () async {
      for (final name in _contract.keys) {
        final fks = await t.db.getAll('PRAGMA foreign_key_list($name)');
        expect(fks, isEmpty, reason: name);
      }
    });

    test('[TASK-005-S02] no unique index except the primary key', () async {
      for (final name in _contract.keys) {
        final list = await t.db.getAll('PRAGMA index_list($name)');
        final unique = list
            .where((i) => i['unique'] == 1 && i['origin'] != 'pk')
            .map((i) => i['name']);
        expect(unique, isEmpty, reason: name);
      }
    });

    test('[TASK-005-S02] the contract indexes exist with their columns',
        () async {
      for (final entry in _indexes.entries) {
        final list = await t.db.getAll('PRAGMA index_list(${entry.key})');
        final plain = list.where((i) => i['origin'] == 'c');
        final columns = <List<String>>[];
        for (final index in plain) {
          final info = await t.db.getAll('PRAGMA index_info(${index['name']})');
          final sorted = [...info]
            ..sort((a, b) => (a['seqno'] as int).compareTo(b['seqno'] as int));
          columns.add([for (final c in sorted) c['name'] as String]);
        }
        expect(columns, unorderedEquals(entry.value), reason: entry.key);
      }
    });

    test('[TASK-005-S02] session_draft accepts only the "current" row',
        () async {
      await t.db.execute(
          "INSERT INTO session_draft(id, occasions, prompt) VALUES ('current', '[]', '')");
      await expectLater(
        t.db.execute(
            "INSERT INTO session_draft(id, occasions, prompt) VALUES ('other', '[]', '')"),
        throwsA(anything),
      );
    });
  });
}
