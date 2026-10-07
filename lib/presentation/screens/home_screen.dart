import 'package:connectme_app/injection.dart';
import 'package:connectme_app/presentation/blocs/auth_cubit.dart';
import 'package:connectme_app/presentation/blocs/post_cubit.dart';
import 'package:connectme_app/presentation/screens/map_screen.dart';
import 'package:connectme_app/presentation/screens/profile_screen.dart';
import 'package:connectme_app/presentation/widgets/post_card.dart';
import 'package:connectme_app/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the PostCubit and start loading posts right away.
    return BlocProvider<PostCubit>(
      create: (_) => sl<PostCubit>()..loadPosts(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // Loading: show a spinner
          if (state is PostLoading || state is PostInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error: show the message and a retry button
          if (state is PostError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<PostCubit>().loadPosts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loaded: show the list of posts
          final posts = (state as PostLoaded).posts;
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(post: posts[index]),
          );
        },
      ),
    );
  }

  // Biometric gate: the profile only opens if the fingerprint check passes.
  Future<void> _openProfile(BuildContext context) async {
    final isVerified = await sl<BiometricService>().authenticate();
    if (!context.mounted) return;

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fingerprint check failed, or no fingerprint is set up on this device.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // Opens a small form, then asks the cubit to create the post.
  Future<void> _showCreatePostDialog(BuildContext context) async {
    final postCubit = context.read<PostCubit>();
    final formKey = GlobalKey<FormState>();
    String postContent = '';

    final shouldPost = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Post'),
        content: Form(
          key: formKey,
          child: TextFormField(
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(hintText: "What's on your mind?"),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Post cannot be empty'
                : null,
            // The Form collects the text, so there's no controller to dispose.
            onSaved: (value) => postContent = value!.trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (shouldPost != true) return; // user pressed Cancel

    final errorMessage = await postCubit.addPost(postContent);
    if (errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
