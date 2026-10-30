import 'dart:math';

import '../time/clock.dart';

/// Generates ObjectIds on the phone (spec R8): 4-byte seconds since epoch,
/// 5-byte random per install run, 3-byte counter, as 24 lowercase hex
/// characters. IDs sort by creation time.
class ObjectIdGenerator {
  ObjectIdGenerator({required Clock clock, Random? random});

  String next() => throw UnimplementedError('TASK-005-S06');
}

/// A 24-hex-character ID derived from [parts], for idempotent writes without
/// UNIQUE constraints (CHG-005 P2-D8). Same parts, same ID; order matters.
String deterministicObjectId(List<String> parts) =>
    throw UnimplementedError('TASK-005-S07');

/// Whether [value] is 24 lowercase hex characters.
bool isObjectId(String value) => throw UnimplementedError('TASK-005-S06');
