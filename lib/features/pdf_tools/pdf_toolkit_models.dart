import 'dart:typed_data';
import 'dart:ui';

enum PdfToolId {
  create,
  merge,
  split,
  deletePages,
  rotate,
  rearrange,
  crop,
  addText,
  addImage,
  imageWatermark,
  textWatermark,
  pageNumbers,
  annotate,
  eSign,
  protect,
  unlock,
  redact,
  removeWatermark,
  compress,
  extractText,
  extractImages,
  fillForm,
  pdfToImages,
  imagesToPdf,
  pdfToTextFile,
  ocr,
  metadata,
  compare,
  flatten,
  viewer,
  pickShare,
}

enum PdfToolkitSection { organize, edit, security, convert, forms, viewer }

enum PdfOutputFormat { pdf, png, jpg, txt, zip }

enum PdfFidelityMode { preserveStructure, rasterized }

class PdfToolkitTool {
  const PdfToolkitTool({
    required this.id,
    required this.label,
    required this.description,
    required this.section,
    required this.tags,
  });

  final PdfToolId id;
  final String label;
  final String description;
  final PdfToolkitSection section;
  final List<String> tags;
}

class PdfPickedFile {
  const PdfPickedFile({required this.name, required this.bytes, this.path});

  final String name;
  final Uint8List bytes;
  final String? path;

  int get size => bytes.lengthInBytes;
}

class PdfOperationResult {
  const PdfOperationResult({
    required this.name,
    required this.bytes,
    required this.format,
    this.message,
  });

  final String name;
  final Uint8List bytes;
  final PdfOutputFormat format;
  final String? message;

  String get extension => switch (format) {
    PdfOutputFormat.pdf => 'pdf',
    PdfOutputFormat.png => 'png',
    PdfOutputFormat.jpg => 'jpg',
    PdfOutputFormat.txt => 'txt',
    PdfOutputFormat.zip => 'zip',
  };

  String get saveName {
    final lower = name.toLowerCase();
    return lower.endsWith('.$extension') ? name : '$name.$extension';
  }
}

class PdfPageSelection {
  const PdfPageSelection({
    this.pageIndex = 0,
    this.allPages = false,
    this.indices = const <int>[],
  });

  final int pageIndex;
  final bool allPages;
  final List<int> indices;

  bool contains(int index) {
    if (allPages) return true;
    if (indices.isEmpty) return index == pageIndex;
    return indices.contains(index);
  }
}

class PdfPlacement {
  const PdfPlacement({required this.pageIndex, required this.bounds});

  final int pageIndex;
  final Rect bounds;
}

class PdfFormFieldInfo {
  const PdfFormFieldInfo({
    required this.name,
    required this.type,
    required this.value,
  });

  final String name;
  final String type;
  final String value;
}

class PdfMetadata {
  const PdfMetadata({
    this.title = '',
    this.author = '',
    this.subject = '',
    this.keywords = '',
    this.creator = '',
  });

  final String title;
  final String author;
  final String subject;
  final String keywords;
  final String creator;
}

const pdfToolkitTools = <PdfToolkitTool>[
  PdfToolkitTool(
    id: PdfToolId.create,
    label: 'Create PDF',
    description: 'Build a text PDF with a table.',
    section: PdfToolkitSection.organize,
    tags: ['create', 'new'],
  ),
  PdfToolkitTool(
    id: PdfToolId.merge,
    label: 'Merge PDFs',
    description: 'Combine multiple PDFs in order.',
    section: PdfToolkitSection.organize,
    tags: ['merge', 'combine'],
  ),
  PdfToolkitTool(
    id: PdfToolId.split,
    label: 'Split PDF',
    description: 'Extract a page range or chunks.',
    section: PdfToolkitSection.organize,
    tags: ['split', 'extract pages'],
  ),
  PdfToolkitTool(
    id: PdfToolId.deletePages,
    label: 'Delete Pages',
    description: 'Remove selected pages.',
    section: PdfToolkitSection.organize,
    tags: ['delete', 'remove pages'],
  ),
  PdfToolkitTool(
    id: PdfToolId.rotate,
    label: 'Rotate Pages',
    description: 'Rotate selected or all pages.',
    section: PdfToolkitSection.organize,
    tags: ['rotate'],
  ),
  PdfToolkitTool(
    id: PdfToolId.rearrange,
    label: 'Rearrange Pages',
    description: 'Save pages in a new order.',
    section: PdfToolkitSection.organize,
    tags: ['reorder', 'organize'],
  ),
  PdfToolkitTool(
    id: PdfToolId.crop,
    label: 'Crop PDF',
    description: 'Crop pages using preserve or raster mode.',
    section: PdfToolkitSection.edit,
    tags: ['crop'],
  ),
  PdfToolkitTool(
    id: PdfToolId.addText,
    label: 'Add Text',
    description: 'Place text on a page.',
    section: PdfToolkitSection.edit,
    tags: ['text'],
  ),
  PdfToolkitTool(
    id: PdfToolId.addImage,
    label: 'Add Image',
    description: 'Place an image on a page.',
    section: PdfToolkitSection.edit,
    tags: ['image'],
  ),
  PdfToolkitTool(
    id: PdfToolId.imageWatermark,
    label: 'Image Watermark',
    description: 'Add a centered image watermark.',
    section: PdfToolkitSection.edit,
    tags: ['watermark'],
  ),
  PdfToolkitTool(
    id: PdfToolId.textWatermark,
    label: 'Text Watermark',
    description: 'Add a removable named text layer.',
    section: PdfToolkitSection.edit,
    tags: ['watermark'],
  ),
  PdfToolkitTool(
    id: PdfToolId.pageNumbers,
    label: 'Page Numbers',
    description: 'Add page numbering.',
    section: PdfToolkitSection.edit,
    tags: ['number'],
  ),
  PdfToolkitTool(
    id: PdfToolId.annotate,
    label: 'Annotate PDF',
    description: 'Add highlight and rectangle notes.',
    section: PdfToolkitSection.edit,
    tags: ['annotate', 'highlight'],
  ),
  PdfToolkitTool(
    id: PdfToolId.eSign,
    label: 'eSign PDF',
    description: 'Draw and place a visual signature.',
    section: PdfToolkitSection.edit,
    tags: ['sign', 'signature'],
  ),
  PdfToolkitTool(
    id: PdfToolId.protect,
    label: 'Password Protect',
    description: 'Encrypt with open and owner passwords.',
    section: PdfToolkitSection.security,
    tags: ['password', 'encrypt'],
  ),
  PdfToolkitTool(
    id: PdfToolId.unlock,
    label: 'Unlock PDF',
    description: 'Save a decrypted copy when password is known.',
    section: PdfToolkitSection.security,
    tags: ['password', 'decrypt'],
  ),
  PdfToolkitTool(
    id: PdfToolId.redact,
    label: 'Redact PDF',
    description: 'Overlay or securely rasterize redactions.',
    section: PdfToolkitSection.security,
    tags: ['redact'],
  ),
  PdfToolkitTool(
    id: PdfToolId.removeWatermark,
    label: 'Remove Watermark',
    description: 'Remove Dexor-created named layers.',
    section: PdfToolkitSection.security,
    tags: ['watermark', 'remove'],
  ),
  PdfToolkitTool(
    id: PdfToolId.compress,
    label: 'Compress PDF',
    description: 'Compress streams or rasterize pages.',
    section: PdfToolkitSection.security,
    tags: ['compress'],
  ),
  PdfToolkitTool(
    id: PdfToolId.extractText,
    label: 'Extract Text',
    description: 'Extract selectable PDF text.',
    section: PdfToolkitSection.convert,
    tags: ['extract', 'text'],
  ),
  PdfToolkitTool(
    id: PdfToolId.extractImages,
    label: 'Extract Page Images',
    description: 'Rasterize pages to PNG files.',
    section: PdfToolkitSection.convert,
    tags: ['image', 'extract'],
  ),
  PdfToolkitTool(
    id: PdfToolId.pdfToImages,
    label: 'PDF to JPG/PNG',
    description: 'Render pages to image files.',
    section: PdfToolkitSection.convert,
    tags: ['convert', 'jpg', 'png'],
  ),
  PdfToolkitTool(
    id: PdfToolId.imagesToPdf,
    label: 'Images to PDF',
    description: 'Create one PDF from images.',
    section: PdfToolkitSection.convert,
    tags: ['image', 'pdf'],
  ),
  PdfToolkitTool(
    id: PdfToolId.pdfToTextFile,
    label: 'PDF to Text File',
    description: 'Export extracted text as TXT.',
    section: PdfToolkitSection.convert,
    tags: ['txt', 'text'],
  ),
  PdfToolkitTool(
    id: PdfToolId.ocr,
    label: 'OCR',
    description: 'Recognize text from scans or images.',
    section: PdfToolkitSection.convert,
    tags: ['ocr', 'scan'],
  ),
  PdfToolkitTool(
    id: PdfToolId.compare,
    label: 'Compare PDFs',
    description: 'Generate raster visual diffs.',
    section: PdfToolkitSection.convert,
    tags: ['diff', 'compare'],
  ),
  PdfToolkitTool(
    id: PdfToolId.fillForm,
    label: 'Fill PDF Form',
    description: 'Fill supported form fields.',
    section: PdfToolkitSection.forms,
    tags: ['form', 'fill'],
  ),
  PdfToolkitTool(
    id: PdfToolId.metadata,
    label: 'Metadata Editor',
    description: 'Read and edit document metadata.',
    section: PdfToolkitSection.forms,
    tags: ['metadata'],
  ),
  PdfToolkitTool(
    id: PdfToolId.flatten,
    label: 'Flatten PDF',
    description: 'Flatten forms and annotations.',
    section: PdfToolkitSection.forms,
    tags: ['flatten'],
  ),
  PdfToolkitTool(
    id: PdfToolId.viewer,
    label: 'PDF Viewer',
    description: 'Preview PDFs with pinch zoom.',
    section: PdfToolkitSection.viewer,
    tags: ['viewer', 'preview'],
  ),
  PdfToolkitTool(
    id: PdfToolId.pickShare,
    label: 'Pick & Share',
    description: 'Open, save, and share outputs.',
    section: PdfToolkitSection.viewer,
    tags: ['share', 'open'],
  ),
];

PdfToolkitTool toolForId(PdfToolId id) {
  return pdfToolkitTools.firstWhere((tool) => tool.id == id);
}
