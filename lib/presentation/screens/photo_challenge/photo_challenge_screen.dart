// lib/presentation/screens/photo_challenge/photo_challenge_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';

// Dodaj do pubspec.yaml:
// image_picker: ^1.0.7

class PhotoChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int points;
  final String? photoUrl;
  final bool isCompleted;

  PhotoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    this.photoUrl,
    this.isCompleted = false,
  });
}

class PhotoChallengeScreen extends StatefulWidget {
  const PhotoChallengeScreen({super.key});

  @override
  State<PhotoChallengeScreen> createState() => _PhotoChallengeScreenState();
}

class _PhotoChallengeScreenState extends State<PhotoChallengeScreen> {
  final List<PhotoChallenge> _challenges = [
    PhotoChallenge(
      id: '1',
      title: 'Czysty Park',
      description: 'Zrób zdjęcie zebranych śmieci z parku',
      emoji: '🌳',
      points: 25,
    ),
    PhotoChallenge(
      id: '2',
      title: 'Uśmiech nieznajomego',
      description: 'Zrób selfie z osobą, której pomogłeś',
      emoji: '😊',
      points: 20,
    ),
    PhotoChallenge(
      id: '3',
      title: 'Eko-Zakupy',
      description: 'Pokaż swoje zakupy bez plastiku',
      emoji: '♻️',
      points: 15,
    ),
    PhotoChallenge(
      id: '4',
      title: 'Zdrowy Posiłek',
      description: 'Sfotografuj zdrowy posiłek, który przygotowałeś',
      emoji: '🥗',
      points: 15,
    ),
    PhotoChallenge(
      id: '5',
      title: 'Book Reading',
      description: 'Zrób zdjęcie książki, którą czytasz',
      emoji: '📚',
      points: 10,
    ),
    PhotoChallenge(
      id: '6',
      title: 'Pomoc w domu',
      description: 'Pokaż jak pomogłeś w pracach domowych',
      emoji: '🏠',
      points: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Wyzwania Fotograficzne'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _challenges.length,
          itemBuilder: (context, index) {
            return _buildPhotoChallengeCard(_challenges[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPhotoChallengeCard(PhotoChallenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        challenge.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${challenge.points} pkt',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    challenge.isCompleted
                        ? Icons.check_circle
                        : Icons.camera_alt_outlined,
                    color: challenge.isCompleted ? Colors.green : Colors.teal,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              if (challenge.photoUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(challenge.photoUrl!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetails(PhotoChallenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoChallengeDetailSheet(
        challenge: challenge,
        onPhotoTaken: (path) {
          setState(() {});
        },
      ),
    );
  }
}

class PhotoChallengeDetailSheet extends StatelessWidget {
  final PhotoChallenge challenge;
  final Function(String) onPhotoTaken;

  const PhotoChallengeDetailSheet({
    super.key,
    required this.challenge,
    required this.onPhotoTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            challenge.emoji,
            style: const TextStyle(fontSize: 60),
          ),

          const SizedBox(height: 16),
          Text(
            challenge.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '+${challenge.points} punktów',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Wskazówki',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Zrób wyraźne zdjęcie\n'
                  '• Pokaż kontekst sytuacji\n'
                  '• Bądź kreatywny!',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
