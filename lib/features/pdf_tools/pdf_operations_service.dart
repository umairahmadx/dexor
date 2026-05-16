import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import 'pdf_toolkit_models.dart';

class PdfOperationsService {
  const PdfOperationsService();

  int pageCount(PdfPickedFile file, {String? password}) {
    final document = _openDocument(file, password: password);
    final count = document.pages.count;
    document.dispose();
    return count;
  }

  Future<PdfOperationResult> createPdf({
    required String title,
    required String body,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title.trim().isEmpty ? 'Dexor PDF' : title.trim(),
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Paragraph(
            text: body.trim().isEmpty ? 'Created on device with Dexor.' : body,
          ),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: const ['Name', 'Role', 'Status'],
            data: const [
              ['Alice', 'Engineer', 'Active'],
              ['Bob', 'Designer', 'Active'],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(
              color: pdf.PdfColors.blueGrey100,
            ),
          ),
        ],
      ),
    );
    return _result(
      'create',
      await document.save(),
      PdfOutputFormat.pdf,
      message: 'Created a new PDF on device.',
    );
  }

  Future<PdfOperationResult> mergePdfs(List<PdfPickedFile> files) async {
    if (files.length < 2) {
      throw ArgumentError('Select at least two PDFs to merge.');
    }
    final output = sf.PdfDocument();
    for (final file in files) {
      final source = _openDocument(file);
      for (var index = 0; index < source.pages.count; index++) {
        _copyPage(source, output, index);
      }
      source.dispose();
    }
    return _saveSyncfusion(
      output,
      'merge',
      message: 'Merged ${files.length} PDFs.',
    );
  }

  Future<PdfOperationResult> splitPdf(
    PdfPickedFile file, {
    required int startPage,
    required int endPage,
  }) async {
    final source = _openDocument(file);
    final start = startPage.clamp(0, source.pages.count - 1).toInt();
    final end = endPage.clamp(start, source.pages.count - 1).toInt();
    final output = sf.PdfDocument();
    for (var index = start; index <= end; index++) {
      _copyPage(source, output, index);
    }
    source.dispose();
    return _saveSyncfusion(
      output,
      'split',
      message: 'Extracted pages ${start + 1}-${end + 1}.',
    );
  }

  Future<PdfOperationResult> deletePages(
    PdfPickedFile file,
    List<int> pageIndices,
  ) async {
    final source = _openDocument(file);
    final toDelete = pageIndices
        .where((index) => index >= 0 && index < source.pages.count)
        .toSet();
    if (toDelete.length == source.pages.count) {
      source.dispose();
      throw ArgumentError('At least one page must remain.');
    }
    final output = sf.PdfDocument();
    for (var index = 0; index < source.pages.count; index++) {
      if (!toDelete.contains(index)) {
        _copyPage(source, output, index);
      }
    }
    source.dispose();
    return _saveSyncfusion(
      output,
      'delete_pages',
      message: 'Deleted ${toDelete.length} page(s).',
    );
  }

  Future<PdfOperationResult> rotatePages(
    PdfPickedFile file, {
    required PdfPageSelection selection,
    required int degrees,
  }) async {
    final document = _openDocument(file);
    final angle = _rotationForDegrees(degrees);
    for (var index = 0; index < document.pages.count; index++) {
      if (selection.contains(index)) {
        document.pages[index].rotation = angle;
      }
    }
    return _saveSyncfusion(
      document,
      'rotate',
      message: 'Rotated selected pages by $degrees degrees.',
    );
  }

  Future<PdfOperationResult> rearrangePages(
    PdfPickedFile file,
    List<int> newOrder,
  ) async {
    final source = _openDocument(file);
    final order = newOrder
        .where((index) => index >= 0 && index < source.pages.count)
        .toList(growable: false);
    if (order.isEmpty) {
      source.dispose();
      throw ArgumentError('Enter at least one valid page number.');
    }
    final output = sf.PdfDocument();
    for (final index in order) {
      _copyPage(source, output, index);
    }
    source.dispose();
    return _saveSyncfusion(
      output,
      'rearrange',
      message: 'Saved ${order.length} page(s) in a new order.',
    );
  }

  Future<PdfOperationResult> cropPdf(
    PdfPickedFile file, {
    required Rect cropRect,
    PdfPageSelection selection = const PdfPageSelection(allPages: true),
    PdfFidelityMode mode = PdfFidelityMode.preserveStructure,
    double dpi = 180,
  }) {
    if (mode == PdfFidelityMode.rasterized) {
      return _rasterCrop(
        file,
        cropRect: cropRect,
        selection: selection,
        dpi: dpi,
      );
    }
    return _templateCrop(file, cropRect: cropRect, selection: selection);
  }

  Future<PdfOperationResult> addText({
    required PdfPickedFile file,
    required String text,
    required PdfPlacement placement,
    double fontSize = 14,
  }) async {
    final document = _openDocument(file);
    final page = document.pages[_validPage(document, placement.pageIndex)];
    page.graphics.drawString(
      text,
      sf.PdfStandardFont(sf.PdfFontFamily.helvetica, fontSize),
      brush: sf.PdfSolidBrush(sf.PdfColor(0, 0, 0)),
      bounds: placement.bounds,
    );
    return _saveSyncfusion(
      document,
      'add_text',
      message: 'Added text to page ${placement.pageIndex + 1}.',
    );
  }

  Future<PdfOperationResult> addImage({
    required PdfPickedFile file,
    required PdfPickedFile image,
    required PdfPlacement placement,
  }) async {
    final document = _openDocument(file);
    final page = document.pages[_validPage(document, placement.pageIndex)];
    page.graphics.drawImage(sf.PdfBitmap(image.bytes), placement.bounds);
    return _saveSyncfusion(
      document,
      'add_image',
      message: 'Added image to page ${placement.pageIndex + 1}.',
    );
  }

  Future<PdfOperationResult> addTextWatermark({
    required PdfPickedFile file,
    required String text,
    String layerName = 'dexor_watermark_text',
    double opacity = 0.25,
    double fontSize = 48,
  }) async {
    final document = _openDocument(file);
    final font = sf.PdfStandardFont(
      sf.PdfFontFamily.helvetica,
      fontSize,
      style: sf.PdfFontStyle.bold,
    );
    for (var index = 0; index < document.pages.count; index++) {
      final page = document.pages[index];
      final layer = page.layers.add(name: layerName);
      final state = layer.graphics.save();
      layer.graphics.setTransparency(opacity);
      layer.graphics.translateTransform(
        page.size.width / 2,
        page.size.height / 2,
      );
      layer.graphics.rotateTransform(-45);
      layer.graphics.drawString(
        text,
        font,
        brush: sf.PdfSolidBrush(sf.PdfColor(150, 150, 150)),
        bounds: const Rect.fromLTWH(-180, -36, 360, 72),
        format: sf.PdfStringFormat(alignment: sf.PdfTextAlignment.center),
      );
      layer.graphics.restore(state);
    }
    return _saveSyncfusion(
      document,
      'text_watermark',
      message: 'Added removable Dexor watermark layer.',
    );
  }

  Future<PdfOperationResult> addImageWatermark({
    required PdfPickedFile file,
    required PdfPickedFile image,
    double opacity = 0.3,
    double size = 200,
  }) async {
    final document = _openDocument(file);
    final bitmap = sf.PdfBitmap(image.bytes);
    for (var index = 0; index < document.pages.count; index++) {
      final page = document.pages[index];
      final state = page.graphics.save();
      page.graphics.setTransparency(opacity);
      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(
          (page.size.width - size) / 2,
          (page.size.height - size) / 2,
          size,
          size,
        ),
      );
      page.graphics.restore(state);
    }
    return _saveSyncfusion(
      document,
      'image_watermark',
      message: 'Added image watermark.',
    );
  }

  Future<PdfOperationResult> addPageNumbers(PdfPickedFile file) async {
    final document = _openDocument(file);
    final font = sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 10);
    final total = document.pages.count;
    for (var index = 0; index < total; index++) {
      final page = document.pages[index];
      page.graphics.drawString(
        'Page ${index + 1} of $total',
        font,
        brush: sf.PdfSolidBrush(sf.PdfColor(100, 100, 100)),
        bounds: Rect.fromLTWH(0, page.size.height - 25, page.size.width, 20),
        format: sf.PdfStringFormat(alignment: sf.PdfTextAlignment.center),
      );
    }
    return _saveSyncfusion(
      document,
      'page_numbers',
      message: 'Added page numbers.',
    );
  }

  Future<PdfOperationResult> annotatePdf({
    required PdfPickedFile file,
    required String note,
    required PdfPlacement placement,
  }) async {
    final document = _openDocument(file);
    final page = document.pages[_validPage(document, placement.pageIndex)];
    page.annotations.add(
      sf.PdfTextMarkupAnnotation(
        placement.bounds,
        note,
        sf.PdfColor(255, 255, 0),
        author: 'Dexor',
      ),
    );
    final rectangle = sf.PdfRectangleAnnotation(placement.bounds, note)
      ..color = sf.PdfColor(255, 0, 0);
    rectangle.border = sf.PdfAnnotationBorder()..width = 2;
    page.annotations.add(rectangle);
    return _saveSyncfusion(
      document,
      'annotate',
      message: 'Added annotation to page ${placement.pageIndex + 1}.',
    );
  }

  Future<PdfOperationResult> eSignPdf({
    required PdfPickedFile file,
    required Uint8List signaturePng,
    required PdfPlacement placement,
  }) async {
    final document = _openDocument(file);
    final page = document.pages[_validPage(document, placement.pageIndex)];
    page.graphics.drawImage(sf.PdfBitmap(signaturePng), placement.bounds);
    return _saveSyncfusion(
      document,
      'esign',
      message: 'Placed visual signature on page ${placement.pageIndex + 1}.',
    );
  }

  Future<PdfOperationResult> protectPdf({
    required PdfPickedFile file,
    required String userPassword,
    String? ownerPassword,
    bool allowPrinting = true,
    bool allowCopying = false,
  }) async {
    if (userPassword.isEmpty) {
      throw ArgumentError('Enter a password to protect the PDF.');
    }
    final document = _openDocument(file);
    document.security.algorithm = sf.PdfEncryptionAlgorithm.aesx256Bit;
    document.security.userPassword = userPassword;
    document.security.ownerPassword = ownerPassword?.isNotEmpty == true
        ? ownerPassword!
        : userPassword;
    document.security.permissions.clear();
    if (allowPrinting) {
      document.security.permissions.add(sf.PdfPermissionsFlags.print);
    }
    if (allowCopying) {
      document.security.permissions.add(sf.PdfPermissionsFlags.copyContent);
    }
    document.security.permissions.add(sf.PdfPermissionsFlags.fillFields);
    return _saveSyncfusion(
      document,
      'protect',
      message: 'Password protected with AES-256.',
    );
  }

  Future<PdfOperationResult> unlockPdf({
    required PdfPickedFile file,
    required String password,
  }) async {
    final document = _openDocument(file, password: password);
    document.security.userPassword = '';
    document.security.ownerPassword = '';
    document.security.permissions.clear();
    return _saveSyncfusion(
      document,
      'unlock',
      message: 'Saved an unlocked copy.',
    );
  }

  Future<PdfOperationResult> redactPdf({
    required PdfPickedFile file,
    required List<PdfPlacement> areas,
    PdfFidelityMode mode = PdfFidelityMode.rasterized,
    double dpi = 200,
  }) {
    if (mode == PdfFidelityMode.rasterized) {
      return _secureRasterRedact(file, areas: areas, dpi: dpi);
    }
    return _overlayRedact(file, areas: areas);
  }

  Future<PdfOperationResult> removeWatermarkLayer({
    required PdfPickedFile file,
    String layerName = 'dexor_watermark_text',
  }) async {
    final document = _openDocument(file);
    var removed = 0;
    for (var pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
      final layers = document.pages[pageIndex].layers;
      for (var layerIndex = layers.count - 1; layerIndex >= 0; layerIndex--) {
        if (layers[layerIndex].name == layerName) {
          layers.removeAt(layerIndex);
          removed++;
        }
      }
    }
    return _saveSyncfusion(
      document,
      'remove_watermark',
      message: 'Removed $removed matching watermark layer(s).',
    );
  }

  Future<PdfOperationResult> compressPdf(
    PdfPickedFile file, {
    PdfFidelityMode mode = PdfFidelityMode.preserveStructure,
    double dpi = 120,
    int jpegQuality = 58,
  }) {
    if (mode == PdfFidelityMode.rasterized) {
      return _rasterCompress(file, dpi: dpi, jpegQuality: jpegQuality);
    }
    final document = _openDocument(file);
    document.compressionLevel = sf.PdfCompressionLevel.best;
    return _saveSyncfusion(
      document,
      'compress',
      message: 'Applied structure-preserving PDF stream compression.',
    );
  }

  Future<String> extractText(PdfPickedFile file) async {
    final document = _openDocument(file);
    final extractor = sf.PdfTextExtractor(document);
    final buffer = StringBuffer();
    for (var index = 0; index < document.pages.count; index++) {
      buffer.writeln('--- Page ${index + 1} ---');
      buffer.writeln(
        extractor.extractText(startPageIndex: index, endPageIndex: index),
      );
      buffer.writeln();
    }
    document.dispose();
    return buffer.toString();
  }

  Future<PdfOperationResult> pdfToTextFile(PdfPickedFile file) async {
    final text = await extractText(file);
    return _result(
      'pdf_to_text',
      Uint8List.fromList(utf8.encode(text)),
      PdfOutputFormat.txt,
      message: 'Exported PDF text.',
    );
  }

  Future<PdfOperationResult> pdfToImages(
    PdfPickedFile file, {
    PdfOutputFormat format = PdfOutputFormat.png,
    double dpi = 150,
  }) async {
    final images = <PdfOperationResult>[];
    var page = 0;
    await for (final raster in Printing.raster(file.bytes, dpi: dpi)) {
      images.add(
        await _imageResultFromRaster(
          raster,
          operation: 'page_${page + 1}',
          format: format,
          jpegQuality: 90,
        ),
      );
      page++;
    }
    return _zipResults(
      images,
      'pdf_images',
      message: 'Rendered $page page image(s).',
    );
  }

  Future<PdfOperationResult> extractImages(
    PdfPickedFile file, {
    double dpi = 200,
  }) {
    return pdfToImages(file, format: PdfOutputFormat.png, dpi: dpi);
  }

  Future<PdfOperationResult> imagesToPdf(List<PdfPickedFile> images) async {
    if (images.isEmpty) {
      throw ArgumentError('Select at least one image.');
    }
    final document = pw.Document();
    for (final imageFile in images) {
      final decoded = img.decodeImage(imageFile.bytes);
      if (decoded == null) continue;
      final png = img.encodePng(decoded);
      final pdfImage = pw.MemoryImage(Uint8List.fromList(png));
      document.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat(
            decoded.width.toDouble(),
            decoded.height.toDouble(),
          ),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return _result(
      'images_to_pdf',
      await document.save(),
      PdfOutputFormat.pdf,
      message: 'Created a PDF from ${images.length} image(s).',
    );
  }

  Future<String> ocrPdf(PdfPickedFile file, {double dpi = 200}) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final tempDir = await getTemporaryDirectory();
    final buffer = StringBuffer();
    var page = 0;
    try {
      await for (final raster in Printing.raster(file.bytes, dpi: dpi)) {
        final imageFile = File(
          '${tempDir.path}/dexor_ocr_${DateTime.now().microsecondsSinceEpoch}_$page.png',
        );
        await imageFile.writeAsBytes(await raster.toPng(), flush: true);
        final result = await recognizer.processImage(
          InputImage.fromFile(imageFile),
        );
        buffer.writeln('=== Page ${page + 1} ===');
        buffer.writeln(result.text);
        buffer.writeln();
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
        page++;
      }
    } finally {
      await recognizer.close();
    }
    return buffer.toString();
  }

  Future<String> ocrImage(PdfPickedFile image) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/dexor_ocr_image_${DateTime.now().microsecondsSinceEpoch}_${image.name}',
    );
    try {
      await tempFile.writeAsBytes(image.bytes, flush: true);
      final result = await recognizer.processImage(
        InputImage.fromFile(tempFile),
      );
      return result.text;
    } finally {
      await recognizer.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  List<PdfFormFieldInfo> listFormFields(
    PdfPickedFile file, {
    String? password,
  }) {
    final document = _openDocument(file, password: password);
    final fields = <PdfFormFieldInfo>[];
    for (var index = 0; index < document.form.fields.count; index++) {
      final field = document.form.fields[index];
      fields.add(
        PdfFormFieldInfo(
          name: field.name ?? 'field_$index',
          type: _fieldType(field),
          value: _fieldValue(field),
        ),
      );
    }
    document.dispose();
    return fields;
  }

  Future<PdfOperationResult> fillForm({
    required PdfPickedFile file,
    required Map<String, String> values,
    bool flattenAfterFill = true,
  }) async {
    final document = _openDocument(file);
    for (var index = 0; index < document.form.fields.count; index++) {
      final field = document.form.fields[index];
      final name = field.name;
      if (name == null || !values.containsKey(name)) continue;
      _setFieldValue(field, values[name] ?? '');
    }
    if (flattenAfterFill) {
      document.form.flattenAllFields();
    }
    return _saveSyncfusion(
      document,
      'fill_form',
      message: 'Filled ${values.length} form value(s).',
    );
  }

  PdfMetadata readMetadata(PdfPickedFile file) {
    final document = _openDocument(file);
    final info = document.documentInformation;
    final metadata = PdfMetadata(
      title: info.title,
      author: info.author,
      subject: info.subject,
      keywords: info.keywords,
      creator: info.creator,
    );
    document.dispose();
    return metadata;
  }

  Future<PdfOperationResult> editMetadata({
    required PdfPickedFile file,
    required PdfMetadata metadata,
  }) async {
    final document = _openDocument(file);
    final info = document.documentInformation;
    info.title = metadata.title;
    info.author = metadata.author;
    info.subject = metadata.subject;
    info.keywords = metadata.keywords;
    info.creator = metadata.creator;
    return _saveSyncfusion(
      document,
      'metadata',
      message: 'Updated PDF metadata.',
    );
  }

  Future<PdfOperationResult> comparePdfs(
    PdfPickedFile first,
    PdfPickedFile second, {
    double dpi = 150,
  }) async {
    final diffs = <PdfOperationResult>[];
    var page = 0;
    await for (final rasterA in Printing.raster(first.bytes, dpi: dpi)) {
      img.Image? imageB;
      await for (final rasterB in Printing.raster(
        second.bytes,
        pages: [page],
        dpi: dpi,
      )) {
        imageB = await _decodeRaster(rasterB);
        break;
      }
      final imageA = await _decodeRaster(rasterA);
      final diff = _diffImages(imageA, imageB);
      diffs.add(
        _result(
          'diff_page_${page + 1}',
          Uint8List.fromList(img.encodePng(diff)),
          PdfOutputFormat.png,
        ),
      );
      page++;
    }
    return _zipResults(
      diffs,
      'compare',
      message: 'Generated $page visual diff page(s).',
    );
  }

  Future<PdfOperationResult> flattenPdf(PdfPickedFile file) async {
    final document = _openDocument(file);
    document.form.flattenAllFields();
    for (var index = 0; index < document.pages.count; index++) {
      document.pages[index].annotations.flattenAllAnnotations();
    }
    return _saveSyncfusion(
      document,
      'flatten',
      message: 'Flattened forms and annotations.',
    );
  }

  Future<PdfOperationResult> _templateCrop(
    PdfPickedFile file, {
    required Rect cropRect,
    required PdfPageSelection selection,
  }) async {
    final source = _openDocument(file);
    final output = sf.PdfDocument();
    for (var index = 0; index < source.pages.count; index++) {
      final sourcePage = source.pages[index];
      if (!selection.contains(index)) {
        _copyPage(source, output, index);
        continue;
      }
      output.pageSettings.size = Size(cropRect.width, cropRect.height);
      final page = output.pages.add();
      page.graphics.drawPdfTemplate(
        sourcePage.createTemplate(),
        Offset(-cropRect.left, -cropRect.top),
        sourcePage.size,
      );
    }
    source.dispose();
    return _saveSyncfusion(
      output,
      'crop',
      message: 'Cropped selected pages using PDF templates.',
    );
  }

  Future<PdfOperationResult> _rasterCrop(
    PdfPickedFile file, {
    required Rect cropRect,
    required PdfPageSelection selection,
    required double dpi,
  }) async {
    final source = _openDocument(file);
    final sizes = [
      for (var index = 0; index < source.pages.count; index++)
        source.pages[index].size,
    ];
    source.dispose();
    final document = pw.Document();
    var page = 0;
    await for (final raster in Printing.raster(file.bytes, dpi: dpi)) {
      final decoded = await _decodeRaster(raster);
      final size = sizes[page];
      final image = selection.contains(page)
          ? _cropImage(decoded, cropRect, size)
          : decoded;
      _addImagePage(document, image);
      page++;
    }
    return _result(
      'crop_raster',
      await document.save(),
      PdfOutputFormat.pdf,
      message: 'Raster-cropped $page page(s).',
    );
  }

  Future<PdfOperationResult> _overlayRedact(
    PdfPickedFile file, {
    required List<PdfPlacement> areas,
  }) async {
    final document = _openDocument(file);
    for (final area in areas) {
      final page = document.pages[_validPage(document, area.pageIndex)];
      page.graphics.drawRectangle(
        brush: sf.PdfSolidBrush(sf.PdfColor(0, 0, 0)),
        bounds: area.bounds,
      );
    }
    return _saveSyncfusion(
      document,
      'redact_overlay',
      message: 'Added visual redaction overlays.',
    );
  }

  Future<PdfOperationResult> _secureRasterRedact(
    PdfPickedFile file, {
    required List<PdfPlacement> areas,
    required double dpi,
  }) async {
    final source = _openDocument(file);
    final sizes = [
      for (var index = 0; index < source.pages.count; index++)
        source.pages[index].size,
    ];
    source.dispose();
    final byPage = <int, List<Rect>>{};
    for (final area in areas) {
      byPage.putIfAbsent(area.pageIndex, () => <Rect>[]).add(area.bounds);
    }
    final document = pw.Document();
    var page = 0;
    await for (final raster in Printing.raster(file.bytes, dpi: dpi)) {
      final decoded = await _decodeRaster(raster);
      for (final area in byPage[page] ?? const <Rect>[]) {
        _fillImageRect(decoded, area, sizes[page]);
      }
      _addImagePage(document, decoded);
      page++;
    }
    return _result(
      'redact_secure',
      await document.save(),
      PdfOutputFormat.pdf,
      message: 'Rasterized the document so redacted content is destroyed.',
    );
  }

  Future<PdfOperationResult> _rasterCompress(
    PdfPickedFile file, {
    required double dpi,
    required int jpegQuality,
  }) async {
    final document = pw.Document();
    var page = 0;
    await for (final raster in Printing.raster(file.bytes, dpi: dpi)) {
      final image = await _decodeRaster(raster);
      _addImagePage(document, image, jpegQuality: jpegQuality);
      page++;
    }
    return _result(
      'compress_raster',
      await document.save(),
      PdfOutputFormat.pdf,
      message: 'Raster-compressed $page page(s).',
    );
  }

  sf.PdfDocument _openDocument(PdfPickedFile file, {String? password}) {
    return sf.PdfDocument(inputBytes: file.bytes, password: password);
  }

  void _copyPage(sf.PdfDocument source, sf.PdfDocument output, int index) {
    final sourcePage = source.pages[index];
    output.pageSettings.size = sourcePage.size;
    final page = output.pages.add();
    page.graphics.drawPdfTemplate(
      sourcePage.createTemplate(),
      Offset.zero,
      sourcePage.size,
    );
  }

  int _validPage(sf.PdfDocument document, int pageIndex) {
    return pageIndex.clamp(0, document.pages.count - 1).toInt();
  }

  Future<PdfOperationResult> _saveSyncfusion(
    sf.PdfDocument document,
    String operation, {
    String? message,
  }) async {
    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return _result(operation, bytes, PdfOutputFormat.pdf, message: message);
  }

  PdfOperationResult _result(
    String operation,
    Uint8List bytes,
    PdfOutputFormat format, {
    String? message,
  }) {
    return PdfOperationResult(
      name: 'dexor_${operation}_${DateTime.now().millisecondsSinceEpoch}',
      bytes: bytes,
      format: format,
      message: message,
    );
  }

  Future<PdfOperationResult> _zipResults(
    List<PdfOperationResult> results,
    String operation, {
    String? message,
  }) async {
    final archive = Archive();
    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      archive.addFile(ArchiveFile.bytes(result.saveName, result.bytes));
    }
    final bytes = ZipEncoder().encodeBytes(archive);
    return _result(operation, bytes, PdfOutputFormat.zip, message: message);
  }

  sf.PdfPageRotateAngle _rotationForDegrees(int degrees) {
    final normalized = ((degrees % 360) + 360) % 360;
    return switch (normalized) {
      90 => sf.PdfPageRotateAngle.rotateAngle90,
      180 => sf.PdfPageRotateAngle.rotateAngle180,
      270 => sf.PdfPageRotateAngle.rotateAngle270,
      _ => sf.PdfPageRotateAngle.rotateAngle0,
    };
  }

  Future<PdfOperationResult> _imageResultFromRaster(
    PdfRaster raster, {
    required String operation,
    required PdfOutputFormat format,
    required int jpegQuality,
  }) async {
    if (format == PdfOutputFormat.jpg) {
      final image = await _decodeRaster(raster);
      return _result(
        operation,
        Uint8List.fromList(img.encodeJpg(image, quality: jpegQuality)),
        PdfOutputFormat.jpg,
      );
    }
    return _result(operation, await raster.toPng(), PdfOutputFormat.png);
  }

  Future<img.Image> _decodeRaster(PdfRaster raster) async {
    final decoded = img.decodePng(await raster.toPng());
    if (decoded == null) {
      throw StateError('Could not decode rendered PDF page.');
    }
    return decoded;
  }

  img.Image _cropImage(img.Image image, Rect pdfRect, Size pdfPageSize) {
    final x = (pdfRect.left * image.width / pdfPageSize.width)
        .round()
        .clamp(0, image.width - 1)
        .toInt();
    final y = (pdfRect.top * image.height / pdfPageSize.height)
        .round()
        .clamp(0, image.height - 1)
        .toInt();
    final width = (pdfRect.width * image.width / pdfPageSize.width)
        .round()
        .clamp(1, image.width - x)
        .toInt();
    final height = (pdfRect.height * image.height / pdfPageSize.height)
        .round()
        .clamp(1, image.height - y)
        .toInt();
    return img.copyCrop(image, x: x, y: y, width: width, height: height);
  }

  void _fillImageRect(img.Image image, Rect pdfRect, Size pdfPageSize) {
    final x1 = (pdfRect.left * image.width / pdfPageSize.width)
        .round()
        .clamp(0, image.width - 1)
        .toInt();
    final y1 = (pdfRect.top * image.height / pdfPageSize.height)
        .round()
        .clamp(0, image.height - 1)
        .toInt();
    final x2 = ((pdfRect.right) * image.width / pdfPageSize.width)
        .round()
        .clamp(0, image.width - 1)
        .toInt();
    final y2 = ((pdfRect.bottom) * image.height / pdfPageSize.height)
        .round()
        .clamp(0, image.height - 1)
        .toInt();
    img.fillRect(
      image,
      x1: math.min(x1, x2),
      y1: math.min(y1, y2),
      x2: math.max(x1, x2),
      y2: math.max(y1, y2),
      color: img.ColorRgb8(0, 0, 0),
    );
  }

  void _addImagePage(
    pw.Document document,
    img.Image image, {
    int? jpegQuality,
  }) {
    final bytes = jpegQuality == null
        ? Uint8List.fromList(img.encodePng(image))
        : Uint8List.fromList(img.encodeJpg(image, quality: jpegQuality));
    final pdfImage = pw.MemoryImage(bytes);
    document.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  img.Image _diffImages(img.Image imageA, img.Image? imageB) {
    final width = math.max(imageA.width, imageB?.width ?? 0);
    final height = math.max(imageA.height, imageB?.height ?? 0);
    final diff = img.Image(width: width, height: height);
    img.fill(diff, color: img.ColorRgb8(255, 255, 255));
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final hasA = x < imageA.width && y < imageA.height;
        final hasB = imageB != null && x < imageB.width && y < imageB.height;
        if (!hasA || !hasB) {
          diff.setPixel(x, y, img.ColorRgb8(255, 0, 0));
          continue;
        }
        final a = imageA.getPixel(x, y);
        final b = imageB.getPixel(x, y);
        final same = a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
        diff.setPixel(x, y, same ? a : img.ColorRgb8(255, 0, 0));
      }
    }
    return diff;
  }

  String _fieldType(sf.PdfField field) {
    if (field is sf.PdfTextBoxField) return 'text';
    if (field is sf.PdfCheckBoxField) return 'checkbox';
    if (field is sf.PdfComboBoxField) return 'combo';
    if (field is sf.PdfRadioButtonListField) return 'radio';
    if (field is sf.PdfListBoxField) return 'list';
    if (field is sf.PdfSignatureField) return 'signature';
    return 'field';
  }

  String _fieldValue(sf.PdfField field) {
    try {
      if (field is sf.PdfTextBoxField) return field.text;
      if (field is sf.PdfCheckBoxField) return field.isChecked.toString();
      if (field is sf.PdfComboBoxField) return field.selectedValue;
      if (field is sf.PdfRadioButtonListField) return field.selectedValue;
      if (field is sf.PdfListBoxField) return field.selectedValues.join(', ');
    } catch (_) {
      return '';
    }
    return '';
  }

  void _setFieldValue(sf.PdfField field, String value) {
    try {
      if (field is sf.PdfTextBoxField) {
        field.text = value;
      } else if (field is sf.PdfCheckBoxField) {
        field.isChecked =
            value.toLowerCase() == 'true' ||
            value == '1' ||
            value.toLowerCase() == 'yes';
      } else if (field is sf.PdfComboBoxField) {
        field.selectedValue = value;
      } else if (field is sf.PdfRadioButtonListField) {
        field.selectedValue = value;
      } else if (field is sf.PdfListBoxField) {
        field.selectedValues = value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Unsupported field values are skipped so one bad field does not abort the fill.
    }
  }
}
