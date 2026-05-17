import 'package:flutter/material.dart';

import 'package:dexor/core/registry/tool_registry.dart';
import 'package:dexor/features/home/home_screen.dart';
import 'package:dexor/features/preferences/preferences_screen.dart';
import 'package:dexor/features/tools/tool_placeholder_screen.dart';
import 'package:dexor/features/developer_tools/json_formatter/json_formatter_screen.dart';
import 'package:dexor/features/developer_tools/base64_encoder/base64_screen.dart';
import 'package:dexor/features/developer_tools/uuid_generator/uuid_generator_screen.dart';
import 'package:dexor/features/developer_tools/url_parser/url_parser_screen.dart';
import 'package:dexor/features/text_data/string_hasher/string_hasher_screen.dart';
import 'package:dexor/features/text_data/case_converter/case_converter_screen.dart';
import 'package:dexor/features/text_data/word_counter/word_counter_screen.dart';
import 'package:dexor/features/text_data/lorem_ipsum/lorem_ipsum_screen.dart';
import 'package:dexor/features/encoding_tools/hex_converter/hex_converter_screen.dart';
import 'package:dexor/features/encoding_tools/binary_converter/binary_converter_screen.dart';
import 'package:dexor/features/developer_tools/regex_tester/regex_tester_screen.dart';
import 'package:dexor/features/developer_tools/html_entities/html_entities_screen.dart';
import 'package:dexor/features/developer_tools/jwt_decoder/jwt_decoder_screen.dart';
import 'package:dexor/features/developer_tools/yaml_to_json/yaml_to_json_screen.dart';
import 'package:dexor/features/text_data/token_generator/token_generator_screen.dart';
import 'package:dexor/features/image/color_picker/color_picker_screen.dart';
import 'package:dexor/features/image/image_resizer/image_resizer_screen.dart';
import 'package:dexor/features/image/image_compressor/image_compressor_screen.dart';
import 'package:dexor/features/image/image_converter/image_converter_screen.dart';
import 'package:dexor/features/image/background_remover/background_remover_screen.dart';
import 'package:dexor/features/image/image_rotator/image_rotator_screen.dart';
import 'package:dexor/features/image/ocr/ocr_screen.dart';
import 'package:dexor/features/image/qr_generator/qr_generator_screen.dart';
import 'package:dexor/features/image/social_media_resizer/social_media_resizer_screen.dart';
import 'package:dexor/features/image/batch_processor/batch_processor_screen.dart';
import 'package:dexor/features/image/svg_optimizer/svg_optimizer_screen.dart';
import 'package:dexor/features/image/exif_viewer/exif_viewer_screen.dart';
import 'package:dexor/features/colors/contrast_checker/contrast_checker_screen.dart';
import 'package:dexor/features/colors/palette_generator/palette_generator_screen.dart';
import 'package:dexor/features/datetime/unix_timestamp/unix_timestamp_screen.dart';
import 'package:dexor/features/security/password_strength/password_strength_screen.dart';
import 'package:dexor/features/pdf_tools/pdf_toolkit_models.dart';
import 'package:dexor/features/pdf_tools/pdf_toolkit_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? ToolRegistry.homeRoute;

    if (name == ToolRegistry.homeRoute) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const HomeScreen(),
      );
    }

    if (name == ToolRegistry.preferencesRoute) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PreferencesScreen(),
      );
    }

    if (name == '/dev/json-formatter') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const JsonFormatterScreen(),
      );
    }

    if (name == '/dev/base64') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const Base64Screen(),
      );
    }

    if (name == '/dev/uuid') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const UuidGeneratorScreen(),
      );
    }

    if (name == '/dev/url-parser') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const UrlParserScreen(),
      );
    }

    if (name == '/text/hasher') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const StringHasherScreen(),
      );
    }

    if (name == '/text/case') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const CaseConverterScreen(),
      );
    }

    if (name == '/text/word-count') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const WordCounterScreen(),
      );
    }

    if (name == '/text/lorem') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LoremIpsumScreen(),
      );
    }

    if (name == '/encode/hex') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const HexConverterScreen(),
      );
    }

    if (name == '/encode/binary') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const BinaryConverterScreen(),
      );
    }

    if (name == '/text/tokens') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PasswordGeneratorScreen(),
      );
    }

    if (name == '/dev/regex') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RegexTesterScreen(),
      );
    }

    if (name == '/dev/html-entities') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const HtmlEntitiesScreen(),
      );
    }

    if (name == '/dev/jwt') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const JwtDecoderScreen(),
      );
    }

    if (name == '/dev/yaml-json') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const YamlJsonScreen(),
      );
    }

    if (name == '/image/color-picker') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ColorPickerScreen(),
      );
    }

    if (name == '/image/svg-optimizer') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const SvgOptimizerScreen(),
      );
    }

    if (name == '/image/exif') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ExifViewerScreen(),
      );
    }

    if (name == '/image/resizer') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ImageResizerScreen(),
      );
    }

    if (name == '/image/compress') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ImageCompressorScreen(),
      );
    }

    if (name == '/image/convert') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ImageConverterScreen(),
      );
    }

    if (name == '/image/bg-remover') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const BackgroundRemoverScreen(),
      );
    }

    if (name == '/image/rotate') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ImageRotatorScreen(),
      );
    }

    if (name == '/image/ocr') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const OcrScreen(),
      );
    }

    if (name == '/image/qr') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const QrGeneratorScreen(),
      );
    }

    if (name == '/image/social-resizer') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const SocialMediaResizerScreen(),
      );
    }

    if (name == '/image/batch') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const BatchProcessorScreen(),
      );
    }

    if (name == '/colors/contrast') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ContrastCheckerScreen(),
      );
    }

    if (name == '/colors/palette') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PaletteGeneratorScreen(),
      );
    }

    if (name == '/datetime/unix') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const UnixTimestampScreen(),
      );
    }

    if (name == '/security/strength') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const PasswordStrengthScreen(),
      );
    }

    final pdfTool = _pdfToolForRoute(name);
    if (pdfTool != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => PdfToolkitScreen(initialTool: pdfTool),
      );
    }

    final entry = ToolRegistry.byRoute(name);
    if (entry != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ToolPlaceholderScreen(entry: entry),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(
          child: Text(
            'Unknown route. Use the command palette or home dashboard.',
          ),
        ),
      ),
    );
  }

  static PdfToolId? _pdfToolForRoute(String route) {
    return switch (route) {
      '/pdf/toolkit' => PdfToolId.create,
      '/pdf/merge' => PdfToolId.merge,
      '/pdf/split' => PdfToolId.split,
      '/pdf/rotate' => PdfToolId.rotate,
      '/pdf/img-to-pdf' => PdfToolId.imagesToPdf,
      '/pdf/to-img' => PdfToolId.pdfToImages,
      '/pdf/compress' => PdfToolId.compress,
      '/pdf/watermark' => PdfToolId.textWatermark,
      '/pdf/extract-text' => PdfToolId.extractText,
      _ => null,
    };
  }
}
