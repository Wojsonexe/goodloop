import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/providers/friend_provider.dart';
import 'search_result_card.dart';
import 'empty_state.dart';
import 'error_state.dart';

class SearchTab extends ConsumerWidget {
  final TextEditingController searchController;

  const SearchTab({super.key, required this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            controller: searchController,
            hintText: 'Search by email...',
            leading: const Icon(Icons.search),
            trailing: [
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
            ],
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            elevation: const WidgetStatePropertyAll(2),
          ),
        ),
        Expanded(
          child: searchResultsAsync.when(
            data: (users) {
              if (users.isEmpty && searchController.text.isNotEmpty) {
                return const EmptyState(
                  icon: Icons.person_search,
                  title: 'No users found',
                  subtitle: 'Try searching with a different email',
                );
              }

              if (users.isEmpty) {
                return const EmptyState(
                  icon: Icons.search,
                  title: 'Search for users',
                  subtitle: 'Enter an email to find friends',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return SearchResultCard(
                    uid: user['uid'] ?? '',
                    displayName: user['displayName'] ?? 'Unknown',
                    email: user['email'] ?? '',
                    photoUrl: user['photoUrl'],
                    onSendRequest: () async {
                      final service = ref.read(friendServiceProvider);
                      await service.sendFriendRequest(
                        user['uid'],
                        currentUser?.displayName ?? 'User',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Request sent to ${user['displayName']}'),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(error: error.toString()),
          ),
        ),
      ],
    );
  }
}
