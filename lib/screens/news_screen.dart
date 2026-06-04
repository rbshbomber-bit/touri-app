import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/news_service.dart';
import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';
import 'news_detail_screen.dart';

/// 국내 뉴스/영성/manifestation 콘텐츠 허브.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  NewsCategory _selected = NewsCategory.all.first;

  void _open(NewsItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(item: item, category: _selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '뉴스', subtitle: '국내 뉴스 + 마음 돌봄'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '토우리 메뉴',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '국내 뉴스와 마음 돌봄 콘텐츠를 골라봐.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TouriColors.cocoa,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: TouriColors.cloudPink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('✦', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 88,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: NewsCategory.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final category = NewsCategory.all[i];
                  final active = category.id == _selected.id;
                  return _CategoryPill(
                    category: category,
                    active: active,
                    onTap: () => setState(() => _selected = category),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: _FeaturedHeader(category: _selected),
            ),
            Expanded(
              child: FutureBuilder<List<NewsItem>>(
                key: ValueKey(_selected.id),
                future: NewsService.fetch(_selected),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: TouriColors.touriPink),
                    );
                  }
                  if (snap.hasError) {
                    final items = NewsService.localFallback(_selected);
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _NewsCard(
                        item: items[i],
                        onTap: () => _open(items[i]),
                      ),
                    );
                  }
                  final items = snap.data ?? const <NewsItem>[];
                  if (items.isEmpty) {
                    return _ErrorState(
                      message: '표시할 뉴스가 아직 없어.',
                      onRetry: () => setState(() {}),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _NewsCard(
                      item: items[i],
                      onTap: () => _open(items[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final NewsCategory category;
  final bool active;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? TouriColors.touriPink : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 124,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? TouriColors.touriPink : TouriColors.cloudPink,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.label,
                style: TextStyle(
                  color: active ? Colors.white : TouriColors.cocoaDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                category.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white.withOpacity(0.85) : TouriColors.dim,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedHeader extends StatelessWidget {
  final NewsCategory category;
  const _FeaturedHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TouriColors.mistPink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: TouriColors.touriPink, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${category.label} 국내 흐름',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TouriColors.cocoaDark,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            '최근 14일',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TouriColors.dim,
                ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  const _NewsCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TouriColors.cloudPink),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: TouriColors.cloudPink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.article_outlined,
                  color: TouriColors.touriPink,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TouriColors.cocoaDark,
                            fontWeight: FontWeight.w900,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: TouriColors.touriPink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded,
                            color: TouriColors.dim, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('♡', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TouriColors.cocoa,
                  ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                '다시 불러오기',
                style: TextStyle(
                  color: TouriColors.touriPink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
