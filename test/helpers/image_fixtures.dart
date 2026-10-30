import 'dart:convert';
import 'dart:typed_data';

/// Byte-level JPEG and PNG fixtures with known metadata, one switch per
/// stripping rule (CHG-005 P2-D10). They are structurally valid files, not
/// decodable pictures: the sanitizer works on structure only.

/// Text planted in metadata; it must not survive sanitizing.
const String gpsMarker = 'GPS-48.8566N-2.3522E';
const String xmpMarker = 'XMP-GPS-48.8566';
const String iptcMarker = 'IPTC-CITY-PARIS';
const String pngTextMarker = 'PNG-LOCATION-PARIS';

/// Bytes that must survive unchanged.
const String iccMarker = 'ICC-PROFILE-DATA';
const String imageDataMarker = 'IMAGE-DATA-BYTES';

List<int> _segment(int marker, List<int> payload) {
  final length = payload.length + 2;
  return [0xFF, marker, length >> 8, length & 0xFF, ...payload];
}

/// A TIFF block with IFD0 holding Orientation and a GPS IFD pointer, plus
/// the planted GPS marker. [littleEndian] selects `II` vs `MM`.
List<int> _tiff({required int orientation, required bool littleEndian}) {
  final out = BytesBuilder();
  void u16(int v) =>
      out.add(littleEndian ? [v & 0xFF, v >> 8] : [v >> 8, v & 0xFF]);
  void u32(int v) => out.add(littleEndian
      ? [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, v >> 24]
      : [v >> 24, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF]);

  out.add(ascii.encode(littleEndian ? 'II' : 'MM'));
  u16(42);
  u32(8); // IFD0 offset
  u16(2); // two entries
  // Orientation (0x0112), SHORT, count 1, value in the first 2 bytes.
  u16(0x0112);
  u16(3);
  u32(1);
  u16(orientation);
  u16(0);
  // GPS IFD pointer (0x8825), LONG, count 1, offset 38.
  u16(0x8825);
  u16(4);
  u32(1);
  u32(38);
  u32(0); // next IFD
  // GPS IFD at 38: zero entries, then the planted marker.
  u16(0);
  u32(0);
  out.add(ascii.encode(gpsMarker));
  return out.takeBytes();
}

/// A JPEG with APP0, APP1 EXIF (orientation + GPS), APP1 XMP, APP2 ICC and
/// APP13 IPTC, followed by image segments.
Uint8List jpegWithMetadata({
  int orientation = 6,
  bool littleEndian = false,
  bool exif = true,
  bool xmp = true,
  bool icc = true,
  bool iptc = true,
}) {
  final out = BytesBuilder()..add([0xFF, 0xD8]);
  out.add(
      _segment(0xE0, [...ascii.encode('JFIF'), 0, 1, 2, 0, 0, 1, 0, 1, 0, 0]));
  if (exif) {
    out.add(_segment(0xE1, [
      ...ascii.encode('Exif'),
      0,
      0,
      ..._tiff(orientation: orientation, littleEndian: littleEndian),
    ]));
  }
  if (xmp) {
    out.add(_segment(0xE1, [
      ...ascii.encode('http://ns.adobe.com/xap/1.0/'),
      0,
      ...ascii.encode('<x:xmpmeta><exif:GPSLatitude>$xmpMarker'
          '</exif:GPSLatitude></x:xmpmeta>'),
    ]));
  }
  if (icc) {
    out.add(_segment(0xE2, [
      ...ascii.encode('ICC_PROFILE'),
      0,
      1,
      1,
      ...ascii.encode(iccMarker),
    ]));
  }
  if (iptc) {
    out.add(_segment(0xED, [
      ...ascii.encode('Photoshop 3.0'),
      0,
      ...ascii.encode('8BIM'),
      ...ascii.encode(iptcMarker),
    ]));
  }
  out.add(_segment(0xDB, List.filled(65, 1))); // DQT
  out.add(_segment(0xC0, [8, 0, 1, 0, 1, 1, 1, 0x11, 0])); // SOF0 1x1
  out.add(_segment(0xC4, List.filled(20, 0))); // DHT
  out.add(_segment(0xDA, [1, 1, 0, 0, 0x3F, 0])); // SOS header
  out.add(ascii.encode(imageDataMarker)); // entropy-coded data
  out.add([0xFF, 0xD9]);
  return out.takeBytes();
}

/// The APPn / segment markers of [jpeg], in order, up to SOS.
List<int> jpegMarkers(Uint8List jpeg) {
  final markers = <int>[];
  var i = 2;
  while (i + 4 <= jpeg.length && jpeg[i] == 0xFF) {
    final marker = jpeg[i + 1];
    markers.add(marker);
    if (marker == 0xDA) break;
    final length = (jpeg[i + 2] << 8) | jpeg[i + 3];
    i += 2 + length;
  }
  return markers;
}

/// The bytes from SOS to the end (the image data the sanitizer must keep).
Uint8List jpegImageData(Uint8List jpeg) {
  for (var i = 0; i + 1 < jpeg.length; i++) {
    if (jpeg[i] == 0xFF && jpeg[i + 1] == 0xDA) {
      return Uint8List.sublistView(jpeg, i);
    }
  }
  throw StateError('no SOS');
}

final List<int> _crcTable = List.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

List<int> _chunk(String type, List<int> data) {
  final typeBytes = ascii.encode(type);
  final crc = _crc32([...typeBytes, ...data]);
  final len = data.length;
  return [
    len >> 24,
    (len >> 16) & 0xFF,
    (len >> 8) & 0xFF,
    len & 0xFF,
    ...typeBytes,
    ...data,
    crc >> 24,
    (crc >> 16) & 0xFF,
    (crc >> 8) & 0xFF,
    crc & 0xFF,
  ];
}

const List<int> pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// A PNG with IHDR, iCCP, tEXt, zTXt, iTXt, eXIf (orientation), IDAT, IEND.
Uint8List pngWithMetadata({
  int orientation = 6,
  bool text = true,
  bool ztxt = true,
  bool itxt = true,
  bool exif = true,
  bool iccp = true,
}) {
  final out = BytesBuilder()..add(pngSignature);
  out.add(_chunk('IHDR', [0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0]));
  if (iccp) {
    out.add(_chunk(
        'iCCP', [...ascii.encode('icc'), 0, 0, ...ascii.encode(iccMarker)]));
  }
  if (text) {
    out.add(_chunk('tEXt',
        [...ascii.encode('Location'), 0, ...ascii.encode(pngTextMarker)]));
  }
  if (ztxt) {
    out.add(_chunk('zTXt',
        [...ascii.encode('Comment'), 0, 0, ...ascii.encode(pngTextMarker)]));
  }
  if (itxt) {
    out.add(_chunk('iTXt', [
      ...ascii.encode('XML:com.adobe.xmp'),
      0,
      0,
      0,
      0,
      0,
      ...ascii.encode(xmpMarker)
    ]));
  }
  if (exif) {
    out.add(
        _chunk('eXIf', _tiff(orientation: orientation, littleEndian: false)));
  }
  out.add(_chunk('IDAT', ascii.encode(imageDataMarker)));
  out.add(_chunk('IEND', const []));
  return out.takeBytes();
}

/// Chunk types of [png], in order.
List<String> pngChunkTypes(Uint8List png) {
  final types = <String>[];
  var i = 8;
  while (i + 8 <= png.length) {
    final len =
        (png[i] << 24) | (png[i + 1] << 16) | (png[i + 2] << 8) | png[i + 3];
    types.add(ascii.decode(png.sublist(i + 4, i + 8)));
    i += 12 + len;
  }
  return types;
}

/// Whether [haystack] contains the ASCII [needle].
bool containsAscii(Uint8List haystack, String needle) {
  final n = ascii.encode(needle);
  outer:
  for (var i = 0; i + n.length <= haystack.length; i++) {
    for (var j = 0; j < n.length; j++) {
      if (haystack[i + j] != n[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// A minimal HEIC header (`ftypheic`), which Phase 2 rejects.
Uint8List heicBytes() => Uint8List.fromList([
      0,
      0,
      0,
      24,
      ...ascii.encode('ftypheic'),
      0,
      0,
      0,
      0,
      ...ascii.encode('mif1heic')
    ]);
