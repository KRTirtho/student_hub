import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pdfx/pdfx.dart';
import 'package:synchronized/synchronized.dart';

Lock _lock = Lock();

Future<PdfPageImage?> usePdfThumbnail(Future<PdfDocument>? document) {
  return useMemoized(() => getPdfThumbnail(document), [document]);
}

Future<PdfPageImage?> getPdfThumbnail(Future<PdfDocument>? document) =>
    _lock.synchronized<PdfPageImage?>(() async {
      final page = await (await document)?.getPage(1);

      if (page == null) {
        return null;
      }
      try {
        return page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.webp,
          backgroundColor: "#FFFFFFFF",
        );
      } finally {
        page.close();
      }
    });
