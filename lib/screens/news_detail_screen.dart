import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../services/news_service.dart';
import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem item;
  final NewsCategory category;

  const NewsDetailScreen({
    super.key,
    required this.item,
    required this.category,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final Future<List<String>> _summary;

  @override
  void initState() {
    super.initState();
    _summary = NewsService.summarize(widget.item, widget.category);
  }

  Future<void> _openOriginal() async {
    final ok = await launchUrl(
      Uri.parse(widget.item.link),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('원문을 열지 못했어'),
          backgroundColor: TouriColors.cocoaDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: TouriAppBar(
        title: widget.category.label,
        subtitle: widget.item.source,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _HeroImage(category: widget.category),
            const SizedBox(height: 18),
            Text(
              widget.item.title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: TouriColors.cocoaDark,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              _metaText,
              style: const TextStyle(
                color: TouriColors.dim,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: _summary,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const _SummaryLoading();
                }
                final lines = snap.data ?? const <String>[];
                return _SummaryBox(lines: lines);
              },
            ),
            if (widget.item.summary.isNotEmpty) ...[
              const SizedBox(height: 18),
              _DescriptionBox(text: widget.item.summary),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _openOriginal,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('원문 보기'),
              style: FilledButton.styleFrom(
                backgroundColor: TouriColors.touriPink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _metaText {
    final date = widget.item.publishedAt;
    final dateText = date == null ? '최근 기사' : '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    return '${widget.item.source} · $dateText';
  }
}

class _HeroImage extends StatelessWidget {
  final NewsCategory category;
  const _HeroImage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: TouriColors.mistPink,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        _imagePath(category),
        height: 158,
        fit: BoxFit.contain,
      ),
    );
  }

  static String _imagePath(NewsCategory category) {
    final file = switch (category.id) {
      'manifestation' => 'manifest',
      'csat' => 'education',
      _ => category.id,
    };
    return 'assets/character/news_categories/$file.png';
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 130,
      child: Center(child: CircularProgressIndicator(color: TouriColors.touriPink)),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final List<String> lines;
  const _SummaryBox({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: TouriColors.touriPink, size: 18),
              SizedBox(width: 8),
              Text(
                '토우리 3줄 요약',
                style: TextStyle(
                  color: TouriColors.cocoaDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final line in lines.take(3)) ...[
            Text(
              '• $line',
              style: const TextStyle(
                color: TouriColors.cocoa,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final String text;
  const _DescriptionBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: TouriColors.dim,
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
