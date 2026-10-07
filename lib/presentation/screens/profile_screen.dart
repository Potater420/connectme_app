import 'dart:convert';

import 'package:connectme_app/injection.dart';
import 'package:connectme_app/presentation/blocs/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _changePhoto(BuildContext context) async {
    final errorMessage = await context.read<ProfileCubit>().updatePhoto();
    if (errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as ProfileLoaded;
          final user = loaded.user;
          final avatarRadius = MediaQuery.of(context).size.width * 0.18;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFF5151C6),
                  backgroundImage: user.photoBase64 == null
                      ? null
                      : MemoryImage(base64Decode(user.photoBase64!)),
                  child: user.photoBase64 == null
                      ? Icon(
                          Icons.person,
                          size: avatarRadius,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _changePhoto(context),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Change photo'),
                ),
                const SizedBox(height: 24),
                _InfoTile(
                  icon: Icons.person,
                  label: 'Full name',
                  value: user.fullName.isEmpty ? 'No name set' : user.fullName,
                ),
                _InfoTile(icon: Icons.email, label: 'Email', value: user.email),
                _InfoTile(
                  icon: Icons.phone_android,
                  label: 'Device',
                  value: loaded.deviceModel,
                ),
                _InfoTile(
                  icon: Icons.android,
                  label: 'OS version',
                  value: loaded.osVersion,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One row of profile info. Used four times, so it's written once.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5151C6)),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
