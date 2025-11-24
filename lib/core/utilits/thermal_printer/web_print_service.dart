import 'dart:core';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:universal_html/js.dart' as js;

@JS('window.print')
external void windowPrint();

class WebPrintService {
  Future<void> printPdfWithIframe(Uint8List pdfBytes) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    final iframe = html.IFrameElement()
      ..style.display = 'none'
      ..src = url;

    html.document.body?.append(iframe);

    iframe.onLoad.listen((event) {
      js.context.callMethod('print', []);

      Future.delayed(Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
        iframe.remove();
      });
    });
  }

  Future<void> printPdfWithWindowOpen(Uint8List pdfBytes) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    final newWindow = html.window.open(url, '_blank');

    if (newWindow != null) {
      Future.delayed(Duration(milliseconds: 1500), () {
        try {
          windowPrint();
        } catch (e) {
          print('JS interop print failed: $e');
          _showPrintInstructions();
        }

        html.Url.revokeObjectUrl(url);
      });
    }
  }

  void printPdfDirect(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    final link = html.AnchorElement()
      ..href = url
      ..target = '_blank'
      ..click();

    Future.delayed(Duration(milliseconds: 1500), () {
      js.context.callMethod('print', []);
      html.Url.revokeObjectUrl(url);
    });
  }

  Future<void> printPdfWithEmbed(Uint8List pdfBytes) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    final embed = html.EmbedElement()
      ..src = url
      ..type = 'application/pdf'
      ..style.width = '0'
      ..style.height = '0';

    html.document.body?.append(embed);

    Future.delayed(Duration(milliseconds: 1000), () {
      js.context.callMethod('print', []);

      html.Url.revokeObjectUrl(url);
      embed.remove();
    });
  }

  void _showPrintInstructions() {
    html.window.alert('PDF opened in new tab. Please use Ctrl+P to print.');
  }
}
