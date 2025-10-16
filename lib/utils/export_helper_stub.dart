// Stub implementation for unsupported platforms
void downloadCSV(String csv, String filename) {
  throw UnsupportedError('CSV export is not supported on this platform');
}

Future<String?> saveCSVToFile(String csv, String filename) async {
  throw UnsupportedError('CSV export is not supported on this platform');
}
