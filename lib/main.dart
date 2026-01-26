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
                      color: Colors.white.withOpacity(0.85),
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

  @override
  Widget build(BuildContext context) {
    final saved = SavedQuotesStore.saved;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('♥️Saved Quotes'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/saved_main.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child:
                        saved.isEmpty
                            ? const Center(child: Text('No saved quotes'))
                            : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: saved.length,
                              itemBuilder: (context, index) {
                                final item = saved[index];
                                return GestureDetector(
                                  onTap: () => _openDetail(context, item),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(width: 2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.favorite, size: 28),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(item.savedAt),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
                    child: const Text(
                      '❤️',
                      style: TextStyle(fontSize: 28),
                    ),
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
