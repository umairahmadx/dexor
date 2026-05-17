import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  static const _imageExts = [
    'jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif',
    'tiff', 'tif', 'heic', 'heif', 'dng', 'cr2',
    'nef', 'arw', 'svg', 'ico'
  ];

  static Future<File?> pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _imageExts,
      );
      return result?.files.firstOrNull?.path != null
          ? File(result!.files.first.path!)
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<File>> pickImages() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _imageExts,
        allowMultiple: true,
      );
      return result?.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<File?> pickRaw() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dng', 'cr2', 'cr3', 'nef', 'arw', 'orf', 'raf', 'rw2'],
      );
      return result?.files.firstOrNull?.path != null
          ? File(result!.files.first.path!)
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> share(File file, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> shareMultiple(List<File> files) async {
    try {
      await Share.shareXFiles(
        files.map((f) => XFile(f.path)).toList(),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> open(File file) async {
    try {
      await OpenFilex.open(file.path);
    } catch (e) {
      // Handle error silently
    }
  }
}
