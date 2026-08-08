/// Turning what came off the camera into what actually gets sent.
///
/// ## This is the cost knob
///
/// A vision request is priced almost entirely on the image. The system prompt
/// and the schema are about 0.6k tokens and the answer is about 0.4k; a
/// 1568px-long-edge photo is around 1.6k on its own, and one straight off a
/// modern phone camera at 4032px is several times that for no useful gain -
/// every provider in scope downsamples large images on their side anyway, so an
/// oversized upload buys nothing but latency on a phone network and a larger
/// bill on somebody's own card. Halving the long edge roughly quarters the image
/// tokens. That is the whole reason this file exists.
///
/// So there are exactly two sizes: [kVisionLongEdgeDefault] for a normal
/// cupboard, and [kVisionLongEdgeDetailed] for a shelf of small print where the
/// extra tokens are the point. Nothing else is offered, because a free-floating
/// resolution slider is a bill nobody can predict.
///
/// ## Two things happen here besides the resize
///
/// **EXIF is dropped.** A photograph taken indoors carries GPS coordinates, a
/// timestamp, and the camera's identifiers, and none of that is any of the model
/// provider's business. Re-encoding through this file strips the block
/// wholesale, which is why an already-small JPEG is still re-encoded rather than
/// passed through: "it was already the right size" is not a reason to hand over
/// somebody's home address.
///
/// **Orientation is baked in.** Phone cameras store a portrait photo as a
/// landscape buffer plus an EXIF orientation tag. Strip the tag without applying
/// it and the model is handed a cupboard lying on its side, which it will
/// cheerfully describe. The rotation is applied to the pixels first.
library;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'ai_provider.dart';

/// The default long edge, in pixels. Chosen because it is the point above which
/// the providers in scope stop gaining accuracy on shelf photographs and start
/// only costing more.
const int kVisionLongEdgeDefault = 1568;

/// "Small print" mode - a shelf of spice jars and ingredient lists, where the
/// label is the whole question. Costs roughly 2.7x the image tokens of
/// [kVisionLongEdgeDefault], so it is a deliberate choice and not the default.
const int kVisionLongEdgeDetailed = 2576;

/// JPEG quality. High enough that label text stays legible after a downscale,
/// low enough that the upload is not the slow part on a kitchen's worth of
/// mobile signal. Below about 75 the fine print on a packet starts smearing,
/// which is the one thing the photograph is for.
const int _jpegQuality = 85;

/// Decode, rotate, downscale, strip metadata, re-encode as JPEG.
///
/// Synchronous and CPU-bound: decoding a 12-megapixel JPEG is comfortably long
/// enough to drop frames, so a screen with a camera preview on it should call
/// [prepareVisionImageOffThread] instead. This entry point exists so the logic
/// is testable without an isolate.
///
/// Bytes this device cannot decode are passed through untouched rather than
/// rejected. A deliberate trade: our decoder failing on some HEIC variant the
/// platform camera produced does not mean the provider's will, and a large
/// photo that arrives is worth more than a small one that never left. The cost
/// of being wrong is one 400 from the provider, which the client already
/// reports as a bad response.
///
/// The catch is broad because "cannot decode" does not reliably arrive as a
/// null. `decodeImage` identifies the format by handing the buffer to each
/// decoder in turn, and a decoder that mis-sniffs reads a header straight off
/// the end of the array - four bytes of junk from a truncated file come back as
/// a `RangeError` thrown from inside the PSD decoder, not as a null. Letting
/// that escape would put a raw range error on a camera screen.
VisionImage prepareVisionImage(
  Uint8List bytes, {
  int longEdge = kVisionLongEdgeDefault,
}) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded != null) return _rescale(decoded, longEdge);
  } catch (_) {
    // Fall through to the pass-through below.
  }
  return VisionImage(bytes: bytes, mediaType: _sniffMediaType(bytes));
}

VisionImage _rescale(img.Image decoded, int longEdge) {
  // Before the resize, or a portrait photo is downscaled against the wrong axis
  // and comes out with its long edge over the limit.
  var image = img.bakeOrientation(decoded);

  final currentLongEdge = image.width > image.height
      ? image.width
      : image.height;
  if (currentLongEdge > longEdge) {
    final scale = longEdge / currentLongEdge;
    image = img.copyResize(
      image,
      width: (image.width * scale).round().clamp(1, longEdge),
      height: (image.height * scale).round().clamp(1, longEdge),
      // Averaging rather than nearest-neighbour: this is a large reduction, and
      // point sampling at this ratio aliases small text into noise - which is
      // precisely the text the model is being asked to read.
      interpolation: img.Interpolation.average,
    );
  }

  // GPS, timestamp, camera serial. See the header - the provider gets a picture
  // of a cupboard and nothing else.
  image.exif = img.ExifData();

  return VisionImage(
    bytes: img.encodeJpg(image, quality: _jpegQuality),
    mediaType: 'image/jpeg',
  );
}

/// [prepareVisionImage] on a background isolate.
///
/// The capture screen holds a live camera preview, and doing this work on the
/// UI isolate stalls it for long enough to look like the app has hung at exactly
/// the moment the user is waiting to find out whether the shot was any good.
Future<VisionImage> prepareVisionImageOffThread(
  Uint8List bytes, {
  int longEdge = kVisionLongEdgeDefault,
}) => compute(_prepareOnIsolate, (bytes: bytes, longEdge: longEdge));

VisionImage _prepareOnIsolate(({Uint8List bytes, int longEdge}) args) =>
    prepareVisionImage(args.bytes, longEdge: args.longEdge);

/// Magic bytes, for the pass-through path only. Defaults to `image/jpeg`
/// because that is what every camera plugin in this app produces, and because
/// an honest guess gets a clear 400 from the provider whereas refusing to send
/// gets the user nothing at all.
String _sniffMediaType(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  return 'image/jpeg';
}
