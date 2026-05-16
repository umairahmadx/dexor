import 'package:flutter/material.dart';

import '../models/tool_entry.dart';

class ToolRegistry {
  const ToolRegistry._();

  static const homeRoute = '/';
  static const preferencesRoute = '/preferences';

  static final List<ToolEntry> all = [
    // Developer tools.
    _tool(
      'json-formatter',
      'JSON Formatter',
      'Format, minify, validate JSON.',
      Icons.data_object,
      'Dev Tools',
      '/dev/json-formatter',
      ['json', 'format', 'minify', 'validate'],
    ),
    _tool(
      'base64',
      'Base64 Encoder',
      'Encode or decode Base64 text and files.',
      Icons.swap_horiz,
      'Dev Tools',
      '/dev/base64',
      ['base64', 'encode', 'decode', 'file'],
    ),
    _tool(
      'url-parser',
      'URL Parser',
      'Inspect and rebuild URLs.',
      Icons.link,
      'Dev Tools',
      '/dev/url-parser',
      ['url', 'uri', 'parse', 'query'],
    ),
    _tool(
      'html-entities',
      'HTML Entities',
      'Escape and unescape HTML entities.',
      Icons.html,
      'Dev Tools',
      '/dev/html-entities',
      ['html', 'entities', 'escape'],
    ),
    _tool(
      'regex',
      'Regex Tester',
      'Test regular expressions with live matches.',
      Icons.search,
      'Dev Tools',
      '/dev/regex',
      ['regex', 'pattern', 'match'],
    ),
    _tool(
      'jwt',
      'JWT Decoder',
      'Inspect JWT header, payload, and signature.',
      Icons.verified_user_outlined,
      'Dev Tools',
      '/dev/jwt',
      ['jwt', 'base64url', 'token'],
    ),
    _tool(
      'diff',
      'Diff Viewer',
      'Compare text and generate diffs.',
      Icons.compare,
      'Dev Tools',
      '/dev/diff',
      ['diff', 'compare', 'patch'],
    ),
    _tool(
      'yaml-json',
      'YAML ↔ JSON',
      'Convert between YAML and JSON.',
      Icons.transform,
      'Dev Tools',
      '/dev/yaml-json',
      ['yaml', 'json', 'convert'],
    ),
    _tool(
      'uuid',
      'UUID Generator',
      'Generate v1, v4, and v7 UUIDs.',
      Icons.fingerprint,
      'Dev Tools',
      '/dev/uuid',
      ['uuid', 'guid', 'v4', 'v7'],
    ),

    // Text / data.
    _tool(
      'hasher',
      'String Hasher',
      'Hash text and compare digests.',
      Icons.fingerprint,
      'Text / Data',
      '/text/hasher',
      ['hash', 'md5', 'sha', 'digest'],
    ),
    _tool(
      'tokens',
      'Token Generator',
      'Generate secure tokens and passwords.',
      Icons.password,
      'Text / Data',
      '/text/tokens',
      ['token', 'password', 'entropy'],
    ),
    _tool(
      'lorem',
      'Lorem Ipsum',
      'Generate placeholder content.',
      Icons.format_align_left,
      'Text / Data',
      '/text/lorem',
      ['lorem', 'ipsum', 'placeholder'],
    ),
    _tool(
      'markdown',
      'Markdown Preview',
      'Render markdown locally.',
      Icons.article_outlined,
      'Text / Data',
      '/text/markdown',
      ['markdown', 'preview', 'render'],
    ),
    _tool(
      'text-diff',
      'Text Diff',
      'Highlight textual changes.',
      Icons.compare_arrows,
      'Text / Data',
      '/text/diff',
      ['diff', 'text', 'changes'],
    ),
    _tool(
      'word-count',
      'Word Counter',
      'Count words, chars, lines, and sentences.',
      Icons.format_list_numbered,
      'Text / Data',
      '/text/word-count',
      ['count', 'words', 'lines'],
    ),
    _tool(
      'case',
      'Case Converter',
      'Convert casing styles.',
      Icons.text_format,
      'Text / Data',
      '/text/case',
      ['case', 'camel', 'snake', 'kebab'],
    ),
    _tool(
      'unicode',
      'Unicode Inspector',
      'Inspect code points and glyph metadata.',
      Icons.emoji_symbols_outlined,
      'Text / Data',
      '/text/unicode',
      ['unicode', 'codepoint', 'glyph'],
    ),

    // Image utilities.
    _tool(
      'image-resizer',
      'Image Resizer',
      'Resize and re-encode images.',
      Icons.photo_size_select_large_outlined,
      'Image',
      '/image/resizer',
      ['image', 'resize', 'compress'],
    ),
    _tool(
      'svg-optimizer',
      'SVG Optimizer',
      'Minify and clean SVG markup.',
      Icons.image_outlined,
      'Image',
      '/image/svg-optimizer',
      ['svg', 'optimize', 'minify'],
    ),
    _tool(
      'color-picker',
      'Color Picker',
      'Convert and sample colors.',
      Icons.colorize,
      'Image',
      '/image/color-picker',
      ['color', 'hex', 'rgb', 'hsl'],
    ),
    _tool(
      'image-converter',
      'Image Converter',
      'Convert between image formats.',
      Icons.image,
      'Image',
      '/image/convert',
      ['convert', 'png', 'jpg', 'webp'],
    ),
    _tool(
      'exif',
      'EXIF Viewer',
      'Inspect image metadata.',
      Icons.info_outline,
      'Image',
      '/image/exif',
      ['exif', 'metadata', 'photo'],
    ),
    _tool(
      'qr',
      'QR Generator',
      'Generate QR codes locally.',
      Icons.qr_code_2,
      'Image',
      '/image/qr',
      ['qr', 'barcode', 'scan'],
    ),

    // PDF tools.
    _tool(
      'pdf-toolkit',
      'PDF Toolkit',
      'Create, edit, secure, convert, OCR, fill forms, and share PDFs on device.',
      Icons.dashboard_customize_outlined,
      'PDF',
      '/pdf/toolkit',
      [
        'pdf',
        'create',
        'merge',
        'split',
        'delete',
        'rotate',
        'rearrange',
        'crop',
        'watermark',
        'annotate',
        'esign',
        'signature',
        'password',
        'unlock',
        'redact',
        'compress',
        'extract',
        'ocr',
        'scan',
        'form',
        'forms',
        'metadata',
        'compare',
        'flatten',
        'viewer',
        'share',
      ],
      isNew: true,
    ),
    _tool(
      'pdf-merge',
      'PDF Merge',
      'Combine PDF documents in the toolkit.',
      Icons.picture_as_pdf_outlined,
      'PDF',
      '/pdf/merge',
      ['pdf', 'merge', 'combine', 'toolkit'],
    ),
    _tool(
      'pdf-split',
      'PDF Split',
      'Split PDF pages in the toolkit.',
      Icons.call_split,
      'PDF',
      '/pdf/split',
      ['pdf', 'split', 'delete', 'rearrange', 'toolkit'],
    ),
    _tool(
      'pdf-rotate',
      'PDF Rotate',
      'Rotate selected or all PDF pages.',
      Icons.rotate_right,
      'PDF',
      '/pdf/rotate',
      ['pdf', 'rotate', 'organize', 'toolkit'],
    ),
    _tool(
      'img-to-pdf',
      'Image → PDF',
      'Create PDFs from images.',
      Icons.insert_drive_file_outlined,
      'PDF',
      '/pdf/img-to-pdf',
      ['pdf', 'image', 'jpg', 'png', 'convert'],
    ),
    _tool(
      'pdf-to-img',
      'PDF → Image',
      'Render PDFs into JPG or PNG images.',
      Icons.image_search_outlined,
      'PDF',
      '/pdf/to-img',
      ['pdf', 'image', 'render', 'jpg', 'png', 'extract'],
    ),
    _tool(
      'pdf-compress',
      'PDF Compress',
      'Reduce PDF size locally.',
      Icons.compress,
      'PDF',
      '/pdf/compress',
      ['pdf', 'compress', 'raster', 'optimize'],
    ),
    _tool(
      'pdf-watermark',
      'PDF Watermark',
      'Add or remove Dexor-created watermark layers.',
      Icons.water_drop_outlined,
      'PDF',
      '/pdf/watermark',
      ['pdf', 'watermark', 'remove', 'layer'],
    ),
    _tool(
      'pdf-extract',
      'PDF Extract Text',
      'Extract text and OCR scanned PDFs.',
      Icons.text_snippet_outlined,
      'PDF',
      '/pdf/extract-text',
      ['pdf', 'extract', 'text', 'ocr', 'metadata', 'forms'],
    ),

    // Security and hash.
    _tool(
      'crypto-hasher',
      'Crypto Hasher',
      'Hash content with crypto algorithms.',
      Icons.security,
      'Security',
      '/security/hasher',
      ['hash', 'crypto', 'sha'],
    ),
    _tool(
      'password',
      'Password Generator',
      'Generate secure passwords.',
      Icons.key,
      'Security',
      '/security/password',
      ['password', 'generate', 'secure'],
    ),
    _tool(
      'strength',
      'Password Strength',
      'Estimate password strength.',
      Icons.speed,
      'Security',
      '/security/strength',
      ['password', 'strength', 'entropy'],
    ),
    _tool(
      'cert',
      'Certificate Inspector',
      'Inspect PEM and DER certificates.',
      Icons.verified_outlined,
      'Security',
      '/security/cert',
      ['cert', 'pem', 'der', 'x509'],
    ),

    // Network tools.
    _tool(
      'curl',
      'cURL Builder',
      'Build and reverse cURL commands.',
      Icons.terminal,
      'Network',
      '/network/curl',
      ['curl', 'http', 'headers'],
    ),
    _tool(
      'headers',
      'Headers Inspector',
      'Inspect request and response headers.',
      Icons.receipt_long_outlined,
      'Network',
      '/network/headers',
      ['headers', 'http', 'request'],
    ),
    _tool(
      'ip',
      'IP Info',
      'View local IP and GeoIP metadata.',
      Icons.travel_explore,
      'Network',
      '/network/ip',
      ['ip', 'geoip', 'network'],
    ),
    _tool(
      'port',
      'Port Scanner',
      'Check local and remote ports.',
      Icons.radar,
      'Network',
      '/network/port-scanner',
      ['port', 'scan', 'tcp'],
    ),

    // Encoding tools.
    _tool(
      'hex',
      'Hex Converter',
      'Convert text and bytes to hex.',
      Icons.tag,
      'Encoding',
      '/encode/hex',
      ['hex', 'bytes', 'ascii'],
    ),
    _tool(
      'unicode-escape',
      'Unicode Escape',
      'Convert to and from escapes.',
      Icons.code_outlined,
      'Encoding',
      '/encode/unicode',
      ['unicode', 'escape'],
    ),
    _tool(
      'morse',
      'Morse Code',
      'Encode and decode Morse.',
      Icons.graphic_eq,
      'Encoding',
      '/encode/morse',
      ['morse', 'code', 'audio'],
    ),
    _tool(
      'binary',
      'Binary Converter',
      'Convert to and from binary.',
      Icons.view_week_outlined,
      'Encoding',
      '/encode/binary',
      ['binary', 'bit', 'base2'],
    ),

    // Colors.
    _tool(
      'palette',
      'Palette Generator',
      'Create rich color palettes.',
      Icons.palette,
      'Colors',
      '/colors/palette',
      ['palette', 'scheme', 'shade'],
    ),
    _tool(
      'contrast',
      'Contrast Checker',
      'Measure WCAG contrast ratios.',
      Icons.visibility,
      'Colors',
      '/colors/contrast',
      ['contrast', 'wcag', 'accessibility'],
    ),
    _tool(
      'gradient',
      'Gradient Builder',
      'Build gradients visually.',
      Icons.gradient,
      'Colors',
      '/colors/gradient',
      ['gradient', 'blend', 'css'],
    ),
    _tool(
      'tailwind',
      'Tailwind Colors',
      'Browse Tailwind-style palettes.',
      Icons.color_lens_outlined,
      'Colors',
      '/colors/tailwind',
      ['tailwind', 'palette', 'css'],
    ),

    // Date and time.
    _tool(
      'unix',
      'Unix Timestamp',
      'Convert timestamps and dates.',
      Icons.schedule,
      'Date / Time',
      '/datetime/unix',
      ['unix', 'timestamp', 'date'],
    ),
    _tool(
      'cron',
      'Cron Parser',
      'Parse cron schedules.',
      Icons.calendar_month_outlined,
      'Date / Time',
      '/datetime/cron',
      ['cron', 'schedule', 'time'],
    ),
    _tool(
      'timezone',
      'Timezone Converter',
      'Convert across IANA time zones.',
      Icons.public,
      'Date / Time',
      '/datetime/timezone',
      ['timezone', 'iana', 'clock'],
    ),
    _tool(
      'duration',
      'Duration Calculator',
      'Calculate intervals and deltas.',
      Icons.timelapse,
      'Date / Time',
      '/datetime/duration',
      ['duration', 'interval', 'elapsed'],
    ),
  ];

  static List<String> get categories =>
      all.map((entry) => entry.category).toSet().toList()..sort();

  static List<ToolEntry> byCategory(String category) =>
      all.where((entry) => entry.category == category).toList(growable: false);

  static List<ToolEntry> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return all;
    }

    final results = all
        .where((entry) {
          final haystack = [
            entry.name,
            entry.description,
            entry.category,
            ...entry.tags,
          ].join(' ').toLowerCase();
          return haystack.contains(normalized);
        })
        .toList(growable: false);

    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  static ToolEntry? byRoute(String route) {
    for (final entry in all) {
      if (entry.route == route) {
        return entry;
      }
    }
    return null;
  }

  static final List<ToolEntry> recentSeed = [
    byRoute('/dev/json-formatter')!,
    byRoute('/dev/base64')!,
    byRoute('/dev/uuid')!,
  ];
}

ToolEntry _tool(
  String id,
  String name,
  String description,
  IconData icon,
  String category,
  String route,
  List<String> tags, {
  bool isNew = false,
  Color? accentOverride,
}) {
  return ToolEntry(
    id: id,
    name: name,
    description: description,
    icon: icon,
    category: category,
    route: route,
    tags: tags,
    isNew: isNew,
    accentOverride: accentOverride,
  );
}
