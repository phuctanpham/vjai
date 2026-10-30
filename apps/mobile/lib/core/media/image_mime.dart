import 'dart:typed_data';

const List<int> _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// ISO-BMFF brands of HEIF/HEIC files.
const Set<String> _heifBrands = {
  'heic', 'heix', 'hevc', 'hevx', 'heim', 'heis', 'mif1', 'msf1', //
};

/// The image MIME type from the file's leading bytes: `image/jpeg`,
/// `image/png`, `image/heic`, `image/gif`, or null when unknown. File names
/// and extensions are not trusted (TASK-007-S04).
String? sniffImageMime(Uint8List bytes) {
  bool startsWith(List<int> prefix, [int offset = 0]) {
    if (bytes.length < offset + prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[offset + i] != prefix[i]) return false;
    }
    return true;
  }

  if (startsWith(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith(_png)) return 'image/png';
  if (startsWith('GIF87a'.codeUnits) || startsWith('GIF89a'.codeUnits)) {
    return 'image/gif';
  }
  if (startsWith('ftyp'.codeUnits, 4) && bytes.length >= 12) {
    final brand = String.fromCharCodes(bytes.sublist(8, 12));
    if (_heifBrands.contains(brand)) return 'image/heic';
  }
  return null;
}
