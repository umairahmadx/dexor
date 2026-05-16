import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'pdf_toolkit_models.dart';

class PdfFileService {
  const PdfFileService();

  Future<bool> requestStorage() async {
    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;

    final photos = await Permission.photos.request();
    return photos.isGranted || photos.isLimited;
  }

  Future<bool> requestCamera() async {
    return (await Permission.camera.request()).isGranted;
  }

  Future<PdfPickedFile?> pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return null;
    return PdfPickedFile(name: file.name, bytes: file.bytes!, path: file.path);
  }

  Future<List<PdfPickedFile>> pickPdfs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );
    return result?.files
            .where((file) => file.bytes != null)
            .map(
              (file) => PdfPickedFile(
                name: file.name,
                bytes: file.bytes!,
                path: file.path,
              ),
            )
            .toList(growable: false) ??
        const <PdfPickedFile>[];
  }

  Future<List<PdfPickedFile>> pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    return result?.files
            .where((file) => file.bytes != null)
            .map(
              (file) => PdfPickedFile(
                name: file.name,
                bytes: file.bytes!,
                path: file.path,
              ),
            )
            .toList(growable: false) ??
        const <PdfPickedFile>[];
  }

  Future<String?> saveResult(PdfOperationResult result) {
    return FileSaver.instance.saveFile(
      name: result.saveName,
      bytes: result.bytes,
      mimeType: _mimeFor(result.format),
    );
  }

  Future<File> writeTempResult(PdfOperationResult result) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${result.saveName}');
    await file.writeAsBytes(result.bytes, flush: true);
    return file;
  }

  Future<void> shareResult(PdfOperationResult result) async {
    final file = await writeTempResult(result);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: result.saveName),
    );
  }

  Future<OpenResult> openResult(PdfOperationResult result) async {
    final file = await writeTempResult(result);
    return OpenFilex.open(file.path);
  }

  MimeType _mimeFor(PdfOutputFormat format) {
    return switch (format) {
      PdfOutputFormat.pdf => MimeType.pdf,
      PdfOutputFormat.png => MimeType.png,
      PdfOutputFormat.jpg => MimeType.jpeg,
      PdfOutputFormat.txt => MimeType.text,
      PdfOutputFormat.zip => MimeType.zip,
    };
  }
}
