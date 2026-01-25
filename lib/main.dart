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

/// (A) Launch / Start 카드
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                      // TODO: (무료/유료) 분기
                      final isPremium = false;

                      if (!isPremium) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PremiumScreen(),
                          ),
                        );
                        return;
                      }

                      // TODO: 저장 처리 (local DB)
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Saved!')));
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
      appBar: AppBar(title: const Text('Unlock Premium Features')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Save quotes & access your collection.",
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            const SizedBox(height: 16),
            const _FeatureTile(
              icon: Icons.bookmark,
              text: "Save your favorite quotes",
            ),
            const _FeatureTile(
              icon: Icons.list,
              text: "View saved quotes anytime",
            ),
            const _FeatureTile(
              icon: Icons.delete_outline,
              text: "Manage your collection",
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  // TODO: in_app_purchase 연결 (iOS: StoreKit / Android: Billing)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase flow TODO')),
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
