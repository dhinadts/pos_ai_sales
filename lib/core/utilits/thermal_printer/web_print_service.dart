import 'dart:core';
import 'dart:html' as html;
// import 'dart:js' as js;
import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:universal_html/js.dart' as js;

@JS('window.print')
external void windowPrint();

class WebPrintService {
  // Method 1: Using iframe for printing
  Future<void> printPdfWithIframe(Uint8List pdfBytes) async {
    // Create blob and URL
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    // Create iframe
    final iframe = html.IFrameElement()
      ..style.display = 'none'
      ..src = url;

    // Add to DOM
    html.document.body?.append(iframe);

    // Wait for PDF to load, then print
    iframe.onLoad.listen((event) {
      // Use JavaScript window.print()
      js.context.callMethod('print', []);

      // Clean up
      Future.delayed(Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
        iframe.remove();
      });
    });
  }

  Future<void> printPdfWithWindowOpen(Uint8List pdfBytes) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    // Open in new window
    final newWindow = html.window.open(url, '_blank');

    if (newWindow != null) {
      // Wait for PDF to load, then trigger print using JS interop
      Future.delayed(Duration(milliseconds: 1500), () {
        try {
          // Method 1: Using JS interop
          windowPrint();
        } catch (e) {
          print('JS interop print failed: $e');
          _showPrintInstructions();
        }

        // Clean up URL
        html.Url.revokeObjectUrl(url);
      });
    }
  }

  // Method 3: Direct browser print using JavaScript
  void printPdfDirect(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    // Create a temporary link
    final link = html.AnchorElement()
      ..href = url
      ..target = '_blank'
      ..click();

    // Trigger print after a delay
    Future.delayed(Duration(milliseconds: 1500), () {
      js.context.callMethod('print', []);
      html.Url.revokeObjectUrl(url);
    });
  }

  // Method 4: Using embed element
  Future<void> printPdfWithEmbed(Uint8List pdfBytes) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrl(blob);

    // Create embed element
    final embed = html.EmbedElement()
      ..src = url
      ..type = 'application/pdf'
      ..style.width = '0'
      ..style.height = '0';

    html.document.body?.append(embed);

    // Wait and print
    Future.delayed(Duration(milliseconds: 1000), () {
      js.context.callMethod('print', []);

      // Clean up
      html.Url.revokeObjectUrl(url);
      embed.remove();
    });
  }

  void _showPrintInstructions() {
    // Show alert with print instructions
    html.window.alert('PDF opened in new tab. Please use Ctrl+P to print.');
  }
}
