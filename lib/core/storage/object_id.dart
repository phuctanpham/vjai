import 'dart:convert';
import 'dart:math';

import '../time/clock.dart';

/// Generates ObjectIds on the phone (spec R8): 4-byte seconds since epoch,
/// 5-byte random per install run, 3-byte counter, as 24 lowercase hex
/// characters. IDs sort by creation time.
class ObjectIdGenerator {
  final Clock _clock;
  final String _process;
  int _counter;

  ObjectIdGenerator({required Clock clock, Random? random})
      : _clock = clock,
        _process = _randomHex(random ?? Random.secure(), 5),
        _counter = (random ?? Random.secure()).nextInt(0x1000000);

  String next() {
    final seconds = _clock.now().millisecondsSinceEpoch ~/ 1000;
    _counter = (_counter + 1) & 0xFFFFFF;
    return seconds.toRadixString(16).padLeft(8, '0') +
        _process +
        _counter.toRadixString(16).padLeft(6, '0');
  }

  static String _randomHex(Random random, int bytes) => [
        for (var i = 0; i < bytes; i++)
          random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ].join();
}

/// A 24-hex-character ID derived from [parts], for idempotent writes without
/// UNIQUE constraints (CHG-005 P2-D8). Same parts, same ID; order matters.
String deterministicObjectId(List<String> parts) {
  // Length-prefixed so that ['ab', 'c'] and ['a', 'bc'] differ.
  final bytes = utf8.encode(parts.map((p) => '${p.length}:$p').join('|'));
  final high = _fnv1a64(bytes, 0xcbf29ce484222325);
  final low = _fnv1a64(bytes, 0x84222325cbf29ce4);
  return _hex64(high) + _hex64(low).substring(0, 8);
}

/// Whether [value] is 24 lowercase hex characters.
bool isObjectId(String value) => _objectIdPattern.hasMatch(value);

final RegExp _objectIdPattern = RegExp(r'^[0-9a-f]{24}$');

/// FNV-1a over 64 bits (wraps like the C reference on the Dart VM).
int _fnv1a64(List<int> bytes, int offset) {
  const prime = 0x100000001b3;
  var hash = offset;
  for (final b in bytes) {
    hash ^= b;
    hash *= prime;
  }
  return hash;
}

String _hex64(int value) =>
    (value >>> 32).toRadixString(16).padLeft(8, '0') +
    (value & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');

/// A stable 32-bit hash of [bytes] (FNV-1a), e.g. to pick a fake-analysis
/// sample set from a photo (CHG-006 G-01).
int stableHash(List<int> bytes) {
  var hash = 0x811c9dc5;
  for (final b in bytes) {
    hash ^= b;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
