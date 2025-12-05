import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goodloop/domain/providers/friend_provider.dart';
import 'request_card.dart';
import 'empty_state.dart';
import 'error_state.dart';

class RequestsTab extends ConsumerWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsStreamProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No pending requests',
            subtitle: 'Friend requests will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return RequestCard(
              uid: request['fromUid'] ?? '',
              displayName: request['fromName'] ?? 'Unknown',
              photoUrl: request['photoUrl'],
              onAccept: () async {
                final service = ref.read(friendServiceProvider);
                await service.acceptFriendRequest(
                  request['fromUid'],
                  request['fromName'],
                  currentUser?.displayName ?? 'User',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend request accepted!')),
                  );
                }
              },
              onReject: () async {
                final service = ref.read(friendServiceProvider);
                await service.rejectFriendRequest(request['fromUid']);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend request rejected')),
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState(error: error.toString()),
    );
  }
}
