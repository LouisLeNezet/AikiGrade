import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/page_layout.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../functions/technique_class.dart';
import '../../widgets/rating_emoticon.dart';
import '../../widgets/youtube_video_player.dart';
import '../../widgets/markdown_viewer.dart';
import 'package:logger/logger.dart';

class TechniqueDetailScreen extends StatelessWidget {
  final Technique technique;

  const TechniqueDetailScreen({super.key, required this.technique});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();

    logger.d(technique);
    logger.d(technique.links);

    final progression = technique.progression;
    final points = <FlSpot>[];
    final List<String> dates = [];
    for (int i = 0; i < progression.length; i++) {
      final entry = progression[i];
      points.add(FlSpot(i.toDouble(), (entry['rating'] as num).toDouble()));
      dates.add(entry['date'] ?? '');
    }

    return ScaffoldWithWideBottomPanel(
      body: PageLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${technique.waza} - ${technique.attack}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Center(
              child: Text(
                '${technique.technique}${technique.form.isNotEmpty ? ' - ${technique.form}' : ''}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expected at Grade: ${technique.grade}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            if (technique.markdown.isNotEmpty) ...[
              Center(
                child: Text(
                  'Notes:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              MarkdownViewer(
                assetPath: technique.markdown,
                imageWidth: 300,
                imageHeight: 300,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            if (technique.links.isNotEmpty) ...[
              Center(
                child: Text(
                  'Videos:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...technique.links.map(
                (link) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      YoutubeVideoPlayer(url: link),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (progression.isNotEmpty) ...[
              Text(
                'Progression:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    minY: 0,
                    maxY: 5,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            // Only show for integer values between 1 and 5
                            if (value >= 1 &&
                                value <= 5 &&
                                value == value.roundToDouble()) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: RatingEmoticon(
                                  rating: value.toInt(),
                                  showValue: false,
                                  iconSize: 20,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < dates.length) {
                              return Text(
                                dates[idx].split(' ').first,
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          interval: 1,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (progression.isEmpty) ...[
              Text(
                'No progression available.',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
