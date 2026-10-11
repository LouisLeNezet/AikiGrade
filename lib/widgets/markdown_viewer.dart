import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

/// Displays markdown, either given directly (`markdownData`) or loaded from
/// an asset (`assetPath`). If both are given, `markdownData` wins.
class MarkdownViewer extends StatefulWidget {
  final String? assetPath;
  final String? markdownData;
  final double imageWidth;
  final double imageHeight;

  const MarkdownViewer({
    super.key,
    this.assetPath,
    this.markdownData,
    this.imageWidth = 300,
    this.imageHeight = 300,
  });

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  static final Logger _logger = Logger();

  /// Only used when the markdown comes from an asset.
  Future<String>? _assetFuture;

  @override
  void initState() {
    super.initState();
    _prepareAssetFuture();
  }

  @override
  void didUpdateWidget(covariant MarkdownViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload only when the content source really changed.
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.markdownData != widget.markdownData) {
      _prepareAssetFuture();
    }
  }

  void _prepareAssetFuture() {
    final path = widget.assetPath;
    _assetFuture = (widget.markdownData == null && path != null)
        ? _loadAsset(path)
        : null;
  }

  Future<String> _loadAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e, stack) {
      _logger.e(
        'Could not load markdown asset $path',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<void> _launchUrl(String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null) {
      _logger.e('Invalid link: $href');
      return;
    }

    try {
      // No canLaunchUrl check: on Android 11+ it returns false unless the
      // scheme is declared in <queries> in AndroidManifest.xml, even when
      // the link could be opened.
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _logger.e('Could not launch $href');
      }
    } catch (e) {
      _logger.e('Could not launch $href', error: e);
    }
  }

  Widget _buildMarkdown(BuildContext context, String data) {
    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) async {
        if (href != null) {
          await _launchUrl(href);
        }
      },
      imageBuilder: (uri, title, alt) {
        return Center(
          child: Image.asset(
            uri.toString(),
            width: widget.imageWidth,
            height: widget.imageHeight,
            fit: BoxFit.contain,
            semanticLabel: alt,
            errorBuilder: (context, error, stack) =>
                const Icon(Icons.broken_image_outlined),
          ),
        );
      },
      styleSheet: MarkdownStyleSheet.fromTheme(
        Theme.of(context),
      ).copyWith(p: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Content already in memory: no need for a future at all.
    final data = widget.markdownData;
    if (data != null) {
      return _buildMarkdown(context, data);
    }

    final future = _assetFuture;
    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load markdown.'));
        }

        return _buildMarkdown(context, snapshot.data ?? '');
      },
    );
  }
}
