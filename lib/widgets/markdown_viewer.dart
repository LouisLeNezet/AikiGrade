import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class MarkdownViewer extends StatelessWidget {
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

  Future<String> _loadMarkdown() async {
    if (markdownData != null) {
      return markdownData!;
    }

    if (assetPath != null) {
      try {
        return await rootBundle.loadString(assetPath!);
      } catch (e) {
        return 'Error loading markdown file: $e';
      }
    }

    return '';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final logger = Logger();
      logger.e('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load markdown.'));
        }

        return MarkdownBody(
          data: snapshot.data!,
          onTapLink: (text, href, title) async {
            if (href != null) {
              await _launchUrl(href);
            }
          },
          imageBuilder: (uri, title, alt) {
            return Center(
              child: Image.asset(
                uri.toString(),
                width: imageWidth,
                height: imageHeight,
              ),
            );
          },
          styleSheet: MarkdownStyleSheet.fromTheme(
            Theme.of(context),
          ).copyWith(p: const TextStyle(fontSize: 16)),
        );
      },
    );
  }
}
