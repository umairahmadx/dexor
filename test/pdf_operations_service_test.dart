import 'dart:typed_data';
import 'dart:ui';

import 'package:dexor/features/pdf_tools/pdf_operations_service.dart';
import 'package:dexor/features/pdf_tools/pdf_toolkit_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

void main() {
  const service = PdfOperationsService();

  test('creates PDFs and extracts text', () async {
    final created = await service.createPdf(
      title: 'Unit Test',
      body: 'Hello from Dexor',
    );
    final file = _picked('created.pdf', created.bytes);

    expect(service.pageCount(file), 1);
    final extracted = await service.extractText(file);
    expect(
      extracted.replaceAll(RegExp(r'\s+'), ' '),
      contains('Hello from Dexor'),
    );
  });

  test(
    'organizes pages with merge, split, delete, rotate, rearrange, and numbering',
    () async {
      final first = _picked(
        'first.pdf',
        _samplePdf(['First page', 'Second page']),
      );
      final second = _picked('second.pdf', _samplePdf(['Third page']));

      final merged = await service.mergePdfs([first, second]);
      final mergedFile = _picked('merged.pdf', merged.bytes);
      expect(service.pageCount(mergedFile), 3);

      final split = await service.splitPdf(
        mergedFile,
        startPage: 1,
        endPage: 1,
      );
      expect(service.pageCount(_picked('split.pdf', split.bytes)), 1);

      final deleted = await service.deletePages(mergedFile, [0]);
      expect(service.pageCount(_picked('deleted.pdf', deleted.bytes)), 2);

      final rotated = await service.rotatePages(
        mergedFile,
        selection: const PdfPageSelection(allPages: true),
        degrees: 90,
      );
      expect(service.pageCount(_picked('rotated.pdf', rotated.bytes)), 3);

      final rearranged = await service.rearrangePages(mergedFile, [2, 0]);
      expect(service.pageCount(_picked('rearranged.pdf', rearranged.bytes)), 2);

      final numbered = await service.addPageNumbers(mergedFile);
      expect(
        await service.extractText(_picked('numbered.pdf', numbered.bytes)),
        contains('Page 1 of 3'),
      );
    },
  );

  test('edits metadata', () async {
    final input = _picked('metadata.pdf', _samplePdf(['Metadata']));
    final edited = await service.editMetadata(
      file: input,
      metadata: const PdfMetadata(
        title: 'Dexor Title',
        author: 'Dexor Author',
        subject: 'PDF tools',
        keywords: 'pdf,dexor',
        creator: 'Dexor',
      ),
    );

    final metadata = service.readMetadata(_picked('edited.pdf', edited.bytes));
    expect(metadata.title, 'Dexor Title');
    expect(metadata.author, 'Dexor Author');
  });

  test('fills and flattens form fields', () async {
    final input = _picked('form.pdf', _formPdf());
    final fields = service.listFormFields(input);
    expect(fields.single.name, 'full_name');

    final filled = await service.fillForm(
      file: input,
      values: const {'full_name': 'Ada Lovelace'},
      flattenAfterFill: true,
    );
    final filledFile = _picked('filled.pdf', filled.bytes);
    expect(service.listFormFields(filledFile), isEmpty);
    expect(await service.extractText(filledFile), contains('Ada Lovelace'));
  });

  test('protects and unlocks with a known password', () async {
    final input = _picked('secure.pdf', _samplePdf(['Secret']));
    final protected = await service.protectPdf(
      file: input,
      userPassword: 'test1234',
    );
    final unlocked = await service.unlockPdf(
      file: _picked('protected.pdf', protected.bytes),
      password: 'test1234',
    );

    expect(service.pageCount(_picked('unlocked.pdf', unlocked.bytes)), 1);
  });
}

PdfPickedFile _picked(String name, Uint8List bytes) {
  return PdfPickedFile(name: name, bytes: bytes);
}

Uint8List _samplePdf(List<String> pageTexts) {
  final document = sf.PdfDocument();
  for (final text in pageTexts) {
    final page = document.pages.add();
    page.graphics.drawString(
      text,
      sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 16),
      bounds: const Rect.fromLTWH(40, 40, 420, 40),
    );
  }
  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}

Uint8List _formPdf() {
  final document = sf.PdfDocument();
  final page = document.pages.add();
  page.graphics.drawString(
    'Full name:',
    sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 14),
    bounds: const Rect.fromLTWH(40, 40, 120, 24),
  );
  document.form.fields.add(
    sf.PdfTextBoxField(
      page,
      'full_name',
      const Rect.fromLTWH(150, 40, 220, 24),
    ),
  );
  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}
