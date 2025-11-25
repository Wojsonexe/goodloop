// lib/presentation/screens/daily_challenge/daily_challenge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// Model Daily Challenge
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int points;
  final DateTime date;
  final bool isCompleted;
  final Color color;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    required this.date,
    this.isCompleted = false,
    required this.color,
  });
}

// Generator Daily Challenges
class DailyChallengeGenerator {
  static final List<Map<String, dynamic>> _challenges = [
    {
      'title': 'Uśmiech dla nieznajomych',
      'description': 'Uśmiechnij się szczerze do 5 nieznajomych osób',
      'emoji': '😊',
      'points': 10,
      'color': Colors.pink,
    },
    {
      'title': 'Eko-Wojownik',
      'description': 'Nie używaj plastiku przez cały dzień',
      'emoji': '♻️',
      'points': 25,
      'color': Colors.green,
    },
    {
      'title': 'Telefon do bliskich',
      'description': 'Zadzwoń do osoby, z którą dawno nie rozmawiałeś',
      'emoji': '📞',
      'points': 15,
      'color': Colors.blue,
    },
    {
      'title': 'Compliment Day',
      'description': 'Powiedz szczery komplement 3 różnym osobom',
      'emoji': '💝',
      'points': 15,
      'color': Colors.purple,
    },
    {
      'title': 'Random Act of Kindness',
      'description': 'Zrób coś miłego dla przypadkowej osoby',
      'emoji': '🎁',
      'points': 20,
      'color': Colors.orange,
    },
    {
      'title': 'Dzień bez social mediów',
      'description': 'Nie zaglądaj na social media przez 24h',
      'emoji': '📵',
      'points': 30,
      'color': Colors.red,
    },
    {
      'title': 'Pomoc w domu',
      'description': 'Zrób coś w domu bez proszenia',
      'emoji': '🏠',
      'points': 15,
      'color': Colors.teal,
    },
    {
      'title': 'Książka zamiast telefonu',
      'description': 'Przeczytaj 30 stron książki',
      'emoji': '📚',
      'points': 20,
      'color': Colors.indigo,
    },
    {
      'title': 'Healthy Day',
      'description': 'Jedz tylko zdrowe jedzenie przez cały dzień',
      'emoji': '🥗',
      'points': 25,
      'color': Colors.lightGreen,
    },
    {
      'title': 'Kreatywność',
      'description': 'Stwórz coś własnoręcznie (rysunek, wiersz, etc)',
      'emoji': '🎨',
      'points': 20,
      'color': Colors.amber,
    },
  ];

  static DailyChallenge generateForToday() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);

    final challenge = _challenges[random.nextInt(_challenges.length)];

    return DailyChallenge(
      id: 'daily_$seed',
      title: challenge['title'],
      description: challenge['description'],
      emoji: challenge['emoji'],
      points: challenge['points'],
      color: challenge['color'],
      date: today,
    );
  }
}

// Provider
final dailyChallengeProvider = Provider<DailyChallenge>((ref) {
  return DailyChallengeGenerator.generateForToday();
});

// Screen
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(dailyChallengeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Wyzwanie Dnia'),
        backgroundColor: challenge.color,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [challenge.color.withValues(alpha: 0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Animated Emoji
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _rotateAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: challenge.color.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    challenge.emoji,
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Title
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: challenge.color,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          challenge.description,
                          style: const TextStyle(fontSize: 18, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Points Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              challenge.color,
                              challenge.color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: challenge.color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '+${challenge.points} punktów',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Timer
                      _buildTimeRemaining(),

                      const SizedBox(height: 30),

                      // Tips
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: challenge.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: challenge.color.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: challenge.color),
                                const SizedBox(width: 10),
                                const Text(
                                  'Wskazówki',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '• Zrób zdjęcie jako dowód\n'
                              '• Podziel się w feedzie\n'
                              '• Inspiruj innych do działania',
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Complete Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isCompleted ? null : _completeChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCompleted ? Colors.grey : challenge.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: _isCompleted ? 0 : 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isCompleted ? 'Ukończone! 🎉' : 'Ukończ Wyzwanie',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = midnight.difference(now);

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orange),
          const SizedBox(width: 10),
          Text(
            'Zostało: ${hours}h ${minutes}m',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _completeChallenge() {
    setState(() {
      _isCompleted = true;
    });

    // Confetti animation
    _controller.reset();
    _controller.forward();

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '🎉 Gratulacje!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ukończyłeś dzisiejsze wyzwanie!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '+${ref.read(dailyChallengeProvider).points}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'punktów',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Super!'),
              ),
            ],
          ),
    );
  }
}
