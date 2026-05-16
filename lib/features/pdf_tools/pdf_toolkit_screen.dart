import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:signature/signature.dart';

import 'pdf_file_service.dart';
import 'pdf_operations_service.dart';
import 'pdf_toolkit_models.dart';

class PdfToolkitScreen extends StatefulWidget {
  const PdfToolkitScreen({super.key, this.initialTool = PdfToolId.create});

  final PdfToolId initialTool;

  @override
  State<PdfToolkitScreen> createState() => _PdfToolkitScreenState();
}

class _PdfToolkitScreenState extends State<PdfToolkitScreen>
    with SingleTickerProviderStateMixin {
  static const _sections = PdfToolkitSection.values;

  final PdfFileService _files = const PdfFileService();
  final PdfOperationsService _pdf = const PdfOperationsService();
  late final TabController _tabController;
  late PdfToolId _selectedTool;

  PdfPickedFile? _primaryPdf;
  PdfPickedFile? _comparePdf;
  List<PdfPickedFile> _pdfs = const <PdfPickedFile>[];
  List<PdfPickedFile> _images = const <PdfPickedFile>[];
  PdfOperationResult? _result;
  String _textOutput = '';
  String _status = '';
  bool _busy = false;

  PdfFidelityMode _mode = PdfFidelityMode.preserveStructure;
  PdfOutputFormat _imageFormat = PdfOutputFormat.png;
  bool _allPages = true;
  bool _flattenAfterFill = true;
  bool _allowPrinting = true;
  bool _allowCopying = false;
  int _degrees = 90;
  PdfPlacement _placement = const PdfPlacement(
    pageIndex: 0,
    bounds: Rect.fromLTWH(72, 96, 220, 90),
  );
  List<PdfFormFieldInfo> _formFields = const <PdfFormFieldInfo>[];

  final _titleController = TextEditingController(text: 'Dexor PDF');
  final _bodyController = TextEditingController(
    text: 'This PDF was created fully on device.',
  );
  final _toolTextController = TextEditingController(text: 'Draft');
  final _passwordController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _layerController = TextEditingController(text: 'dexor_watermark_text');
  final _pagesController = TextEditingController(text: '1');
  final _orderController = TextEditingController(text: '1,2,3');
  final _startPageController = TextEditingController(text: '1');
  final _endPageController = TextEditingController(text: '1');
  final _targetPageController = TextEditingController(text: '1');
  final _fontSizeController = TextEditingController(text: '16');
  final _formValuesController = TextEditingController();
  final _metadataTitleController = TextEditingController();
  final _metadataAuthorController = TextEditingController();
  final _metadataSubjectController = TextEditingController();
  final _metadataKeywordsController = TextEditingController();
  final _metadataCreatorController = TextEditingController(text: 'Dexor');
  final _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
    _selectedTool = widget.initialTool;
    _tabController = TabController(
      length: _sections.length,
      vsync: this,
      initialIndex: toolForId(widget.initialTool).section.index,
    )..addListener(_syncSelectedToolToTab);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_syncSelectedToolToTab)
      ..dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _toolTextController.dispose();
    _passwordController.dispose();
    _ownerPasswordController.dispose();
    _layerController.dispose();
    _pagesController.dispose();
    _orderController.dispose();
    _startPageController.dispose();
    _endPageController.dispose();
    _targetPageController.dispose();
    _fontSizeController.dispose();
    _formValuesController.dispose();
    _metadataTitleController.dispose();
    _metadataAuthorController.dispose();
    _metadataSubjectController.dispose();
    _metadataKeywordsController.dispose();
    _metadataCreatorController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _syncSelectedToolToTab() {
    if (_tabController.indexIsChanging) return;
    final section = _sections[_tabController.index];
    if (toolForId(_selectedTool).section == section) return;
    setState(() {
      _selectedTool = pdfToolkitTools
          .firstWhere((tool) => tool.section == section)
          .id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Toolkit'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Organize'),
            Tab(text: 'Edit'),
            Tab(text: 'Security'),
            Tab(text: 'Convert/OCR'),
            Tab(text: 'Forms/Metadata'),
            Tab(text: 'Viewer/Share'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final section in _sections) _buildSection(context, section),
          ],
        ),
      ),
      bottomNavigationBar: _busy
          ? LinearProgressIndicator(color: theme.colorScheme.primary)
          : null,
    );
  }

  Widget _buildSection(BuildContext context, PdfToolkitSection section) {
    final tools = pdfToolkitTools
        .where((tool) => tool.section == section)
        .toList(growable: false);
    final activeTool = toolForId(_selectedTool).section == section
        ? toolForId(_selectedTool)
        : tools.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tool in tools)
                    ChoiceChip(
                      label: Text(tool.label),
                      selected: _selectedTool == tool.id,
                      onSelected: _busy
                          ? null
                          : (_) => setState(() {
                              _selectedTool = tool.id;
                              _result = null;
                              _textOutput = '';
                              _status = '';
                            }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildControls(context, activeTool),
                        const SizedBox(height: 16),
                        _buildPreviewAndOutput(context, activeTool),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildControls(context, activeTool),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildPreviewAndOutput(context, activeTool),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, PdfToolkitTool tool) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          title: tool.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tool.description),
              const SizedBox(height: 12),
              _buildFilePickers(tool.id),
              const SizedBox(height: 12),
              _buildToolOptions(tool.id),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy || !_canRun(tool.id) ? null : _runSelectedTool,
                icon: Icon(_runIcon(tool.id)),
                label: Text(_runLabel(tool.id)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewAndOutput(BuildContext context, PdfToolkitTool tool) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_usesPlacement(tool.id))
          _Panel(
            title: 'Preview Placement',
            child: Column(
              children: [
                _PlacementEditor(
                  placement: _placement,
                  onChanged: (placement) =>
                      setState(() => _placement = placement),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _targetPageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target page',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        if (tool.id == PdfToolId.eSign)
          _Panel(
            title: 'Signature',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _signatureController.clear,
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
        if (tool.id == PdfToolId.viewer && _primaryPdf?.path != null)
          _Panel(
            title: 'Viewer',
            child: SizedBox(
              height: 520,
              child: _PdfxFileViewer(path: _primaryPdf!.path!),
            ),
          ),
        _Panel(title: 'Output', child: _buildOutput(context)),
      ],
    );
  }

  Widget _buildFilePickers(PdfToolId tool) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_needsPrimaryPdf(tool))
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _pickPrimaryPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_primaryPdf == null ? 'Select PDF' : _primaryPdf!.name),
          ),
        if (_needsMultiplePdfs(tool))
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _pickPdfs,
            icon: const Icon(Icons.library_books_outlined),
            label: Text(
              _pdfs.isEmpty ? 'Select PDFs' : '${_pdfs.length} PDFs selected',
            ),
          ),
        if (_needsImages(tool))
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _pickImages,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _images.isEmpty
                  ? 'Select images'
                  : '${_images.length} image(s) selected',
            ),
          ),
        if (_needsSecondPdf(tool))
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _pickComparePdf,
            icon: const Icon(Icons.compare_outlined),
            label: Text(
              _comparePdf == null ? 'Select compare PDF' : _comparePdf!.name,
            ),
          ),
      ],
    );
  }

  Widget _buildToolOptions(PdfToolId tool) {
    final commonPageInput = TextField(
      controller: _pagesController,
      decoration: const InputDecoration(
        labelText: 'Pages',
        helperText: 'Use 1,3-5. Leave as 1 for one-page tools.',
        border: OutlineInputBorder(),
      ),
    );

    switch (tool) {
      case PdfToolId.create:
        return Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case PdfToolId.merge:
        return _FileList(
          files: _pdfs,
          onReorder: _reorderPickedPdf,
          onRemove: _removePickedPdf,
        );
      case PdfToolId.split:
        return Row(
          children: [
            Expanded(child: _numberField(_startPageController, 'Start page')),
            const SizedBox(width: 12),
            Expanded(child: _numberField(_endPageController, 'End page')),
          ],
        );
      case PdfToolId.deletePages:
        return commonPageInput;
      case PdfToolId.rotate:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: _allPages,
              onChanged: (value) => setState(() => _allPages = value),
              title: const Text('Rotate all pages'),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_allPages) commonPageInput,
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _degrees,
              decoration: const InputDecoration(
                labelText: 'Rotation',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 90, child: Text('90 degrees')),
                DropdownMenuItem(value: 180, child: Text('180 degrees')),
                DropdownMenuItem(value: 270, child: Text('270 degrees')),
              ],
              onChanged: (value) => setState(() => _degrees = value ?? 90),
            ),
          ],
        );
      case PdfToolId.rearrange:
        return TextField(
          controller: _orderController,
          decoration: const InputDecoration(
            labelText: 'New page order',
            helperText: 'Example: 3,1,2',
            border: OutlineInputBorder(),
          ),
        );
      case PdfToolId.crop:
      case PdfToolId.redact:
      case PdfToolId.compress:
        return _modePicker(tool);
      case PdfToolId.addText:
        return Column(
          children: [
            TextField(
              controller: _toolTextController,
              decoration: const InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fontSizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Font size',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case PdfToolId.addImage:
        return const Text(
          'Select an image, then drag the placement box to position it.',
        );
      case PdfToolId.imageWatermark:
        return const Text(
          'Select a watermark image. It will be centered on every page.',
        );
      case PdfToolId.textWatermark:
        return Column(
          children: [
            TextField(
              controller: _toolTextController,
              decoration: const InputDecoration(
                labelText: 'Watermark text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _layerController,
              decoration: const InputDecoration(
                labelText: 'Layer name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case PdfToolId.pageNumbers:
        return const Text(
          'Page numbers are added at the bottom center of every page.',
        );
      case PdfToolId.annotate:
        return TextField(
          controller: _toolTextController,
          decoration: const InputDecoration(
            labelText: 'Annotation note',
            border: OutlineInputBorder(),
          ),
        );
      case PdfToolId.eSign:
        return const Text(
          'Draw a visual signature and place it with the preview box.',
        );
      case PdfToolId.protect:
        return Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Open password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ownerPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Owner password (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              value: _allowPrinting,
              onChanged: (value) =>
                  setState(() => _allowPrinting = value ?? true),
              title: const Text('Allow printing'),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _allowCopying,
              onChanged: (value) =>
                  setState(() => _allowCopying = value ?? false),
              title: const Text('Allow copying text'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case PdfToolId.unlock:
        return TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Current password',
            border: OutlineInputBorder(),
          ),
        );
      case PdfToolId.removeWatermark:
        return TextField(
          controller: _layerController,
          decoration: const InputDecoration(
            labelText: 'Layer name',
            border: OutlineInputBorder(),
          ),
        );
      case PdfToolId.extractText:
      case PdfToolId.extractImages:
        return const Text(
          'Output stays local. Multi-page images are returned as a ZIP.',
        );
      case PdfToolId.pdfToImages:
        return DropdownButtonFormField<PdfOutputFormat>(
          initialValue: _imageFormat,
          decoration: const InputDecoration(
            labelText: 'Image format',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: PdfOutputFormat.png, child: Text('PNG')),
            DropdownMenuItem(value: PdfOutputFormat.jpg, child: Text('JPG')),
          ],
          onChanged: (value) =>
              setState(() => _imageFormat = value ?? PdfOutputFormat.png),
        );
      case PdfToolId.imagesToPdf:
        return _FileList(
          files: _images,
          onReorder: _reorderPickedImage,
          onRemove: _removePickedImage,
        );
      case PdfToolId.pdfToTextFile:
        return const Text('Extracted selectable text is saved as a TXT file.');
      case PdfToolId.ocr:
        return const Text(
          'Select a PDF scan or one image. OCR uses on-device ML Kit.',
        );
      case PdfToolId.compare:
        return const Text(
          'Visual differences are highlighted in red and bundled as PNG files in a ZIP.',
        );
      case PdfToolId.fillForm:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _primaryPdf == null || _busy ? null : _loadFormFields,
              icon: const Icon(Icons.list_alt),
              label: const Text('List form fields'),
            ),
            if (_formFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final field in _formFields)
                Text('${field.name} (${field.type}) = ${field.value}'),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _formValuesController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Field values',
                helperText: 'One per line: fieldName=value',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              value: _flattenAfterFill,
              onChanged: (value) =>
                  setState(() => _flattenAfterFill = value ?? true),
              title: const Text('Flatten after fill'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case PdfToolId.metadata:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _primaryPdf == null || _busy ? null : _readMetadata,
              icon: const Icon(Icons.manage_search),
              label: const Text('Read metadata'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metadataTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metadataAuthorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metadataSubjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metadataKeywordsController,
              decoration: const InputDecoration(
                labelText: 'Keywords',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metadataCreatorController,
              decoration: const InputDecoration(
                labelText: 'Creator',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case PdfToolId.flatten:
        return const Text(
          'Flattening burns form fields and annotations into the page content.',
        );
      case PdfToolId.viewer:
        return const Text(
          'Select a PDF with a file path to preview it inside Dexor.',
        );
      case PdfToolId.pickShare:
        return const Text(
          'Use output actions here after any PDF operation: save, share, or open.',
        );
    }
  }

  Widget _modePicker(PdfToolId tool) {
    final label = tool == PdfToolId.redact
        ? 'Redaction mode'
        : tool == PdfToolId.compress
        ? 'Compression mode'
        : 'Crop mode';
    return Column(
      children: [
        DropdownButtonFormField<PdfFidelityMode>(
          initialValue: _mode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: PdfFidelityMode.preserveStructure,
              child: Text('Preserve structure'),
            ),
            DropdownMenuItem(
              value: PdfFidelityMode.rasterized,
              child: Text('Rasterized / destructive'),
            ),
          ],
          onChanged: (value) => setState(
            () => _mode = value ?? PdfFidelityMode.preserveStructure,
          ),
        ),
        if (tool == PdfToolId.redact)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: _pagesController,
              decoration: const InputDecoration(
                labelText: 'Redaction page',
                helperText: 'Uses the first page number entered here.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOutput(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_status.isNotEmpty)
          Text(
            _status,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (_result != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_result!.saveName} - ${_formatBytes(_result!.bytes.lengthInBytes)}',
          ),
          if (_result!.message != null) Text(_result!.message!),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _files.saveResult(_result!),
                icon: const Icon(Icons.save_alt),
                label: const Text('Save'),
              ),
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _files.shareResult(_result!),
                icon: const Icon(Icons.ios_share),
                label: const Text('Share'),
              ),
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _files.openResult(_result!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
              ),
            ],
          ),
        ],
        if (_textOutput.isNotEmpty) ...[
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: _textOutput),
            readOnly: true,
            minLines: 8,
            maxLines: 16,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _textOutput));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Text copied.')));
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy text'),
            ),
          ),
        ],
        if (_result == null && _textOutput.isEmpty && _status.isEmpty)
          const Text(
            'Run a tool to see generated files, text, or status here.',
          ),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _pickPrimaryPdf() async {
    final picked = await _files.pickPdf();
    if (picked == null) return;
    setState(() {
      _primaryPdf = picked;
      _result = null;
      _status = 'Selected ${picked.name}.';
      try {
        _endPageController.text = _pdf.pageCount(picked).toString();
      } catch (_) {
        _endPageController.text = '1';
      }
    });
  }

  Future<void> _pickComparePdf() async {
    final picked = await _files.pickPdf();
    if (picked == null) return;
    setState(() => _comparePdf = picked);
  }

  Future<void> _pickPdfs() async {
    final picked = await _files.pickPdfs();
    if (picked.isEmpty) return;
    setState(() => _pdfs = picked);
  }

  Future<void> _pickImages() async {
    final picked = await _files.pickImages();
    if (picked.isEmpty) return;
    setState(() => _images = picked);
  }

  void _reorderPickedPdf(int oldIndex, int newIndex) {
    setState(() => _pdfs = _moved(_pdfs, oldIndex, newIndex));
  }

  void _removePickedPdf(int index) {
    setState(() => _pdfs = [..._pdfs]..removeAt(index));
  }

  void _reorderPickedImage(int oldIndex, int newIndex) {
    setState(() => _images = _moved(_images, oldIndex, newIndex));
  }

  void _removePickedImage(int index) {
    setState(() => _images = [..._images]..removeAt(index));
  }

  List<PdfPickedFile> _moved(
    List<PdfPickedFile> files,
    int oldIndex,
    int newIndex,
  ) {
    final copy = [...files];
    final item = copy.removeAt(oldIndex);
    copy.insert(newIndex.clamp(0, copy.length).toInt(), item);
    return copy;
  }

  Future<void> _runSelectedTool() async {
    setState(() {
      _busy = true;
      _result = null;
      _textOutput = '';
      _status = '';
    });
    try {
      final tool = _selectedTool;
      final output = await _runTool(tool);
      if (!mounted) return;
      setState(() {
        if (output != null) {
          _result = output;
          _status = output.message ?? 'Done.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<PdfOperationResult?> _runTool(PdfToolId tool) async {
    switch (tool) {
      case PdfToolId.create:
        return _pdf.createPdf(
          title: _titleController.text,
          body: _bodyController.text,
        );
      case PdfToolId.merge:
        return _pdf.mergePdfs(_pdfs);
      case PdfToolId.split:
        return _pdf.splitPdf(
          _requirePdf(),
          startPage:
              _parsePositiveInt(_startPageController.text, fallback: 1) - 1,
          endPage: _parsePositiveInt(_endPageController.text, fallback: 1) - 1,
        );
      case PdfToolId.deletePages:
        return _pdf.deletePages(
          _requirePdf(),
          _parsePageList(_pagesController.text),
        );
      case PdfToolId.rotate:
        return _pdf.rotatePages(
          _requirePdf(),
          selection: PdfPageSelection(
            allPages: _allPages,
            indices: _parsePageList(_pagesController.text),
          ),
          degrees: _degrees,
        );
      case PdfToolId.rearrange:
        return _pdf.rearrangePages(
          _requirePdf(),
          _parsePageList(_orderController.text),
        );
      case PdfToolId.crop:
        return _pdf.cropPdf(
          _requirePdf(),
          cropRect: _placement.bounds,
          mode: _mode,
        );
      case PdfToolId.addText:
        return _pdf.addText(
          file: _requirePdf(),
          text: _toolTextController.text,
          placement: _currentPlacement(),
          fontSize: _parseDouble(_fontSizeController.text, fallback: 16),
        );
      case PdfToolId.addImage:
        return _pdf.addImage(
          file: _requirePdf(),
          image: _requireImage(),
          placement: _currentPlacement(),
        );
      case PdfToolId.imageWatermark:
        return _pdf.addImageWatermark(
          file: _requirePdf(),
          image: _requireImage(),
        );
      case PdfToolId.textWatermark:
        return _pdf.addTextWatermark(
          file: _requirePdf(),
          text: _toolTextController.text,
          layerName: _layerController.text.trim().isEmpty
              ? 'dexor_watermark_text'
              : _layerController.text.trim(),
        );
      case PdfToolId.pageNumbers:
        return _pdf.addPageNumbers(_requirePdf());
      case PdfToolId.annotate:
        return _pdf.annotatePdf(
          file: _requirePdf(),
          note: _toolTextController.text,
          placement: _currentPlacement(),
        );
      case PdfToolId.eSign:
        final signature = await _signatureController.toPngBytes();
        if (signature == null || signature.isEmpty) {
          throw ArgumentError('Draw a signature first.');
        }
        return _pdf.eSignPdf(
          file: _requirePdf(),
          signaturePng: signature,
          placement: _currentPlacement(),
        );
      case PdfToolId.protect:
        return _pdf.protectPdf(
          file: _requirePdf(),
          userPassword: _passwordController.text,
          ownerPassword: _ownerPasswordController.text,
          allowPrinting: _allowPrinting,
          allowCopying: _allowCopying,
        );
      case PdfToolId.unlock:
        return _pdf.unlockPdf(
          file: _requirePdf(),
          password: _passwordController.text,
        );
      case PdfToolId.redact:
        return _pdf.redactPdf(
          file: _requirePdf(),
          areas: [_currentPlacement(pageFallback: _firstParsedPage())],
          mode: _mode,
        );
      case PdfToolId.removeWatermark:
        return _pdf.removeWatermarkLayer(
          file: _requirePdf(),
          layerName: _layerController.text.trim().isEmpty
              ? 'dexor_watermark_text'
              : _layerController.text.trim(),
        );
      case PdfToolId.compress:
        return _pdf.compressPdf(_requirePdf(), mode: _mode);
      case PdfToolId.extractText:
        final text = await _pdf.extractText(_requirePdf());
        setState(() => _textOutput = text);
        return null;
      case PdfToolId.extractImages:
        return _pdf.extractImages(_requirePdf());
      case PdfToolId.fillForm:
        return _pdf.fillForm(
          file: _requirePdf(),
          values: _parseKeyValues(_formValuesController.text),
          flattenAfterFill: _flattenAfterFill,
        );
      case PdfToolId.pdfToImages:
        return _pdf.pdfToImages(_requirePdf(), format: _imageFormat);
      case PdfToolId.imagesToPdf:
        return _pdf.imagesToPdf(_images);
      case PdfToolId.pdfToTextFile:
        return _pdf.pdfToTextFile(_requirePdf());
      case PdfToolId.ocr:
        if (_primaryPdf != null) {
          final text = await _pdf.ocrPdf(_primaryPdf!);
          setState(() => _textOutput = text);
          return null;
        }
        final text = await _pdf.ocrImage(_requireImage());
        setState(() => _textOutput = text);
        return null;
      case PdfToolId.metadata:
        return _pdf.editMetadata(
          file: _requirePdf(),
          metadata: _metadataFromControllers(),
        );
      case PdfToolId.compare:
        return _pdf.comparePdfs(
          _requirePdf(),
          _comparePdf ?? (throw ArgumentError('Select a compare PDF.')),
        );
      case PdfToolId.flatten:
        return _pdf.flattenPdf(_requirePdf());
      case PdfToolId.viewer:
        setState(
          () => _status = _primaryPdf?.path == null
              ? 'Select a file-backed PDF to view.'
              : 'Viewer loaded.',
        );
        return null;
      case PdfToolId.pickShare:
        setState(
          () =>
              _status = 'Use Save, Share, or Open after generating an output.',
        );
        return null;
    }
  }

  Future<void> _loadFormFields() async {
    setState(() => _busy = true);
    try {
      final fields = _pdf.listFormFields(_requirePdf());
      setState(() {
        _formFields = fields;
        _status = fields.isEmpty
            ? 'No fillable form fields found.'
            : 'Found ${fields.length} form field(s).';
      });
    } catch (error) {
      setState(() => _status = 'Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _readMetadata() async {
    setState(() => _busy = true);
    try {
      final metadata = _pdf.readMetadata(_requirePdf());
      _metadataTitleController.text = metadata.title;
      _metadataAuthorController.text = metadata.author;
      _metadataSubjectController.text = metadata.subject;
      _metadataKeywordsController.text = metadata.keywords;
      _metadataCreatorController.text = metadata.creator;
      setState(() => _status = 'Metadata loaded.');
    } catch (error) {
      setState(() => _status = 'Error: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  PdfPickedFile _requirePdf() {
    final file = _primaryPdf;
    if (file == null) throw ArgumentError('Select a PDF first.');
    return file;
  }

  PdfPickedFile _requireImage() {
    if (_images.isEmpty) throw ArgumentError('Select at least one image.');
    return _images.first;
  }

  bool _canRun(PdfToolId tool) {
    if (tool == PdfToolId.merge) return _pdfs.length >= 2;
    if (tool == PdfToolId.imagesToPdf) return _images.isNotEmpty;
    if (tool == PdfToolId.ocr) return _primaryPdf != null || _images.isNotEmpty;
    if (_needsSecondPdf(tool) && _comparePdf == null) return false;
    if (_needsPrimaryPdf(tool) && _primaryPdf == null) return false;
    if (_needsImages(tool) && _images.isEmpty && tool != PdfToolId.ocr) {
      return false;
    }
    return true;
  }

  bool _needsPrimaryPdf(PdfToolId tool) {
    return switch (tool) {
      PdfToolId.create || PdfToolId.merge || PdfToolId.imagesToPdf => false,
      PdfToolId.ocr => _images.isEmpty,
      PdfToolId.pickShare => false,
      _ => true,
    };
  }

  bool _needsMultiplePdfs(PdfToolId tool) => tool == PdfToolId.merge;

  bool _needsImages(PdfToolId tool) {
    return switch (tool) {
      PdfToolId.addImage ||
      PdfToolId.imageWatermark ||
      PdfToolId.imagesToPdf ||
      PdfToolId.ocr => true,
      _ => false,
    };
  }

  bool _needsSecondPdf(PdfToolId tool) => tool == PdfToolId.compare;

  bool _usesPlacement(PdfToolId tool) {
    return switch (tool) {
      PdfToolId.crop ||
      PdfToolId.addText ||
      PdfToolId.addImage ||
      PdfToolId.annotate ||
      PdfToolId.eSign ||
      PdfToolId.redact => true,
      _ => false,
    };
  }

  IconData _runIcon(PdfToolId tool) {
    return switch (tool) {
      PdfToolId.viewer => Icons.visibility,
      PdfToolId.extractText || PdfToolId.ocr => Icons.text_snippet_outlined,
      PdfToolId.metadata => Icons.edit_document,
      _ => Icons.play_arrow,
    };
  }

  String _runLabel(PdfToolId tool) {
    return switch (tool) {
      PdfToolId.viewer => 'Load viewer',
      PdfToolId.metadata => 'Save metadata',
      PdfToolId.extractText => 'Extract text',
      PdfToolId.ocr => 'Run OCR',
      PdfToolId.pickShare => 'Ready',
      _ => 'Run ${toolForId(tool).label}',
    };
  }

  PdfPlacement _currentPlacement({int? pageFallback}) {
    return PdfPlacement(
      pageIndex:
          pageFallback ??
          _parsePositiveInt(_targetPageController.text, fallback: 1) - 1,
      bounds: _placement.bounds,
    );
  }

  int _firstParsedPage() {
    final pages = _parsePageList(_pagesController.text);
    return pages.isEmpty ? 0 : pages.first;
  }

  List<int> _parsePageList(String raw) {
    final pages = <int>{};
    for (final token in raw.split(',')) {
      final part = token.trim();
      if (part.isEmpty) continue;
      if (part.contains('-')) {
        final halves = part.split('-');
        final start = _parsePositiveInt(halves.first, fallback: 1);
        final end = _parsePositiveInt(
          halves.length > 1 ? halves.last : halves.first,
          fallback: start,
        );
        for (
          var page = math.min(start, end);
          page <= math.max(start, end);
          page++
        ) {
          pages.add(page - 1);
        }
      } else {
        pages.add(_parsePositiveInt(part, fallback: 1) - 1);
      }
    }
    return pages.where((page) => page >= 0).toList(growable: false)..sort();
  }

  Map<String, String> _parseKeyValues(String raw) {
    final values = <String, String>{};
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final separator = trimmed.contains('=')
          ? trimmed.indexOf('=')
          : trimmed.indexOf(':');
      if (separator <= 0) continue;
      values[trimmed.substring(0, separator).trim()] = trimmed
          .substring(separator + 1)
          .trim();
    }
    return values;
  }

  PdfMetadata _metadataFromControllers() {
    return PdfMetadata(
      title: _metadataTitleController.text,
      author: _metadataAuthorController.text,
      subject: _metadataSubjectController.text,
      keywords: _metadataKeywordsController.text,
      creator: _metadataCreatorController.text,
    );
  }

  int _parsePositiveInt(String raw, {required int fallback}) {
    final parsed = int.tryParse(raw.trim());
    if (parsed == null || parsed <= 0) return fallback;
    return parsed;
  }

  double _parseDouble(String raw, {required double fallback}) {
    return double.tryParse(raw.trim()) ?? fallback;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FileList extends StatelessWidget {
  const _FileList({
    required this.files,
    required this.onReorder,
    required this.onRemove,
  });

  final List<PdfPickedFile> files;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Text('No files selected.');
    }
    return Column(
      children: [
        for (var index = 0; index < files.length; index++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.drag_indicator),
            title: Text(files[index].name),
            subtitle: Text(
              '${(files[index].size / 1024).toStringAsFixed(1)} KB',
            ),
            trailing: Wrap(
              spacing: 2,
              children: [
                IconButton(
                  onPressed: index == 0
                      ? null
                      : () => onReorder(index, index - 1),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  onPressed: index == files.length - 1
                      ? null
                      : () => onReorder(index, index + 1),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  onPressed: () => onRemove(index),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlacementEditor extends StatelessWidget {
  const _PlacementEditor({required this.placement, required this.onChanged});

  static const _pageWidth = 595.0;
  static const _pageHeight = 842.0;

  final PdfPlacement placement;
  final ValueChanged<PdfPlacement> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 360.0);
        final height = width * _pageHeight / _pageWidth;
        final scale = width / _pageWidth;
        final rect = placement.bounds;
        return Center(
          child: GestureDetector(
            onPanUpdate: (details) {
              final next = rect.shift(
                Offset(details.delta.dx / scale, details.delta.dy / scale),
              );
              onChanged(
                PdfPlacement(
                  pageIndex: placement.pageIndex,
                  bounds: Rect.fromLTWH(
                    next.left.clamp(0, _pageWidth - rect.width).toDouble(),
                    next.top.clamp(0, _pageHeight - rect.height).toDouble(),
                    rect.width,
                    rect.height,
                  ),
                ),
              );
            },
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PageGridPainter(
                        theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.left * scale,
                    top: rect.top * scale,
                    width: rect.width * scale,
                    height: rect.height * scale,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${rect.left.round()}, ${rect.top.round()}\n${rect.width.round()} x ${rect.height.round()} pt',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PageGridPainter extends CustomPainter {
  const _PageGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = size.width / 4; x < size.width; x += size.width / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = size.height / 4; y < size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PageGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PdfxFileViewer extends StatefulWidget {
  const _PdfxFileViewer({required this.path});

  final String path;

  @override
  State<_PdfxFileViewer> createState() => _PdfxFileViewerState();
}

class _PdfxFileViewerState extends State<_PdfxFileViewer> {
  late pdfx.PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = pdfx.PdfControllerPinch(
      document: pdfx.PdfDocument.openFile(widget.path),
    );
  }

  @override
  void didUpdateWidget(covariant _PdfxFileViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _controller.dispose();
      _controller = pdfx.PdfControllerPinch(
        document: pdfx.PdfDocument.openFile(widget.path),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pdfx.PdfViewPinch(controller: _controller);
  }
}
