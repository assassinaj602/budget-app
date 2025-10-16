// Mobile/Desktop implementation
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> saveCSVToFile(String csv, String filename) async {
  try {
    final directory = await getDownloadsDirectory();
    if (directory != null) {
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csv);
      return file.path;
    }
    return null;
  } catch (e) {
    return null;
  }
}
