// Web implementation
import 'dart:html' as html;

void downloadCSV(String csv, String filename) {
  final bytes = csv.codeUnits;
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

// Alias for compatibility
Future<String?> saveCSVToFile(String csv, String filename) async {
  downloadCSV(csv, filename);
  return filename; // Return filename as success indicator for web
}
