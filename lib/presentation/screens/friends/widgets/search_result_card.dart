import 'package:flutter/material.dart';

class SearchResultCard extends StatelessWidget {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final VoidCallback onSendRequest;

  const SearchResultCard({
    super.key,
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? Text(displayName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 20))
              : null,
        ),
        title: Text(
          displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          email,
          style: theme.textTheme.bodySmall,
        ),
        trailing: FilledButton.icon(
          onPressed: onSendRequest,
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}
