import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(const RumiDaysApp());

class RumiDaysApp extends StatelessWidget {
  const RumiDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RumiDays',
      theme: ThemeData(useMaterial3: true),
      home: const LaunchScreen(),
    );
  }
}

class Quote {
  final String text;
  final String? author;

  Quote({required this.text, this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: (json['text'] ?? '').toString(),
      author: json['author']?.toString(),
    );
  }
}

class QuoteRepository {
  static List<Quote>? _cache;

  static Future<List<Quote>> loadQuotes() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/quotes.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cache =
        decoded
            .map((e) => Quote.fromJson(e as Map<String, dynamic>))
            .where((q) => q.text.trim().isNotEmpty)
            .toList();
    return _cache!;
  }

  static Future<Quote> randomQuote() async {
    final list = await loadQuotes();
    final rnd = Random();
    return list[rnd.nextInt(list.length)];
  }
}

class SavedQuote {
  final Quote quote;
  final DateTime savedAt;

  SavedQuote({required this.quote, required this.savedAt});
}

class SavedQuotesStore {
  static final List<SavedQuote> saved = [];

  static void add(Quote quote) {
    saved.insert(0, SavedQuote(quote: quote, savedAt: DateTime.now()));
  }

  static void remove(SavedQuote item) {
    saved.remove(item);
  }
}

/// (A) Launch / Start 카드
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/launch.png', fit: BoxFit.cover),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodayQuoteScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "The door is always open",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, height: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// (B) Today’s quote 화면
class TodayQuoteScreen extends StatefulWidget {
  const TodayQuoteScreen({super.key});

  @override
  State<TodayQuoteScreen> createState() => _TodayQuoteScreenState();
}

class _TodayQuoteScreenState extends State<TodayQuoteScreen> {
  static const List<String> _backgrounds = [
    'assets/img/main_1.png',
    'assets/img/main_2.png',
    'assets/img/main_3.png',
    'assets/img/main_4.png',
    'assets/img/main_5.png',
  ];

  final Random _random = Random();
  Quote? quote;
  bool loading = true;
  String background = _backgrounds.first;

  @override
  void initState() {
    super.initState();
    _loadRandom();
  }

  Future<void> _loadRandom() async {
    setState(() => loading = true);
    final q = await QuoteRepository.randomQuote();
    setState(() {
      quote = q;
      loading = false;
      background = _backgrounds[_random.nextInt(_backgrounds.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final quoteText = quote?.text ?? '';
    final author = quote?.author;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadRandom, // 새 문구 뽑기 (랜덤)
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(background, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child:
                        loading
                            ? const Center(child: CircularProgressIndicator())
                            : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    quoteText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (author != null &&
                                      author.trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      "— $author",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      final current = quote;
                      if (current == null || current.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No quote yet')),
                        );
                        return;
                      }

                      SavedQuotesStore.add(current);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedMainScreen(),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// (C) Premium(결제) 화면
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Unlock Premium Features'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/purchase.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Save quotes & access your collection.",
                          style: TextStyle(fontSize: 18, height: 1.4),
                        ),
                        SizedBox(height: 16),
                        _FeatureTile(
                          icon: Icons.bookmark,
                          text: "Save your favorite quotes",
                        ),
                        _FeatureTile(
                          icon: Icons.list,
                          text: "View saved quotes anytime",
                        ),
                        _FeatureTile(
                          icon: Icons.delete_outline,
                          text: "Manage your collection",
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedMainScreen(),
                          ),
                        );
                      },
                      child: const Text("Go Premium"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Not now"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}

/// (D) Saved main 화면
class SavedMainScreen extends StatefulWidget {
  const SavedMainScreen({super.key});

  @override
  State<SavedMainScreen> createState() => _SavedMainScreenState();
}

class _SavedMainScreenState extends State<SavedMainScreen> {
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  Future<void> _openDetail(BuildContext context, SavedQuote quote) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SavedDetailScreen(item: quote)),
    );
    setState(() {});
  }

  static const List<Color> _tileColors = [
    Color(0xFFF28C4C),
    Color(0xFFDCBCA8),
    Color(0xFF75605A),
    Color(0xFF4F3D39),
    Color(0xFF84706A),
  ];

  static const List<IconData> _tileIcons = [
    Icons.home,
    Icons.ac_unit,
    Icons.badge_outlined,
    Icons.landscape,
    Icons.favorite,
  ];

  double _tileHeightForIndex(int index) {
    switch (index % 5) {
      case 0:
      case 3:
        return 260;
      case 1:
      case 2:
        return 150;
      default:
        return 170;
    }
  }

  bool _isWideTile(int index) => index % 5 == 4;

  @override
  Widget build(BuildContext context) {
    final saved = SavedQuotesStore.saved;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Saved Quotes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/saved_main.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child:
                saved.isEmpty
                    ? const Center(child: Text('No saved quotes'))
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        final halfWidth =
                            (constraints.maxWidth - (spacing * 3)) / 2;
                        final fullWidth = constraints.maxWidth - (spacing * 2);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: List.generate(saved.length, (index) {
                              final item = saved[index];
                              final isWide = _isWideTile(index);

                              return SizedBox(
                                width: isWide ? fullWidth : halfWidth,
                                child: _SavedMosaicTile(
                                  height: _tileHeightForIndex(index),
                                  color:
                                      _tileColors[index % _tileColors.length],
                                  icon: _tileIcons[index % _tileIcons.length],
                                  dateText: _formatDate(item.savedAt),
                                  onTap: () => _openDetail(context, item),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _SavedMosaicTile extends StatelessWidget {
  const _SavedMosaicTile({
    required this.height,
    required this.color,
    required this.icon,
    required this.dateText,
    required this.onTap,
  });

  final double height;
  final Color color;
  final IconData icon;
  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: foreground, size: 28)),
            Positioned(
              left: 12,
              bottom: 10,
              child: Text(
                dateText,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// (E) Saved detail 화면
class SavedDetailScreen extends StatelessWidget {
  const SavedDetailScreen({super.key, required this.item});
  final SavedQuote item;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete saved quote?'),
            content: const Text('Do you want to delete the saved quote?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No, keep save it'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, delete it'),
              ),
            ],
          ),
    );

    if (ok == true) {
      if (!context.mounted) return;
      SavedQuotesStore.remove(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/saved_detail.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.quote.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, height: 1.5),
                        ),
                        if (item.quote.author != null &&
                            item.quote.author!.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            "— ${item.quote.author}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: const Text('❤️', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// (D) Saved quotes 리스트 화면 + (E) Delete confirm dialog
class SavedQuotesScreen extends StatefulWidget {
  const SavedQuotesScreen({super.key});

  @override
  State<SavedQuotesScreen> createState() => _SavedQuotesScreenState();
}

class _SavedQuotesScreenState extends State<SavedQuotesScreen> {
  // TODO: DB로 교체
  final List<String> saved = [
    "You are brave",
    "Paid feature 3",
    "Paid feature 1",
  ];

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete quote?"),
            content: const Text("Are you sure you want to delete it?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
    );

    if (ok == true) {
      setState(() => saved.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Saved Rumi Quotes")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: saved.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    saved[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
