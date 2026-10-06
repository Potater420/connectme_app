import 'dart:convert';
import 'dart:io';

import 'package:connect_me_community_app/data/models/user_model.dart';
import 'package:connect_me_community_app/domain/entities/user.dart';
import 'package:connect_me_community_app/services/auth_service.dart';
import 'package:connect_me_community_app/services/firestore_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

sealed class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final AppUser user;
  final String deviceModel;
  final String osVersion;
  ProfileLoaded({
    required this.user,
    required this.deviceModel,
    required this.osVersion,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileCubit(this._authService, this._firestoreService)
      : super(ProfileLoading());

  Future<void> loadProfile() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        emit(ProfileError('You are not signed in.'));
        return;
      }

      final photoBase64 = await _firestoreService.getUserPhoto(firebaseUser.uid);
      final deviceInfo = await _readDeviceInfo();

      // Builder pattern in use: only the fields we have are set.
      final builder = UserModelBuilder()
          .setUid(firebaseUser.uid)
          .setFullName(firebaseUser.displayName ?? '')
          .setEmail(firebaseUser.email ?? '');
      if (photoBase64 != null) builder.setPhotoBase64(photoBase64);

      emit(ProfileLoaded(
        user: builder.build(),
        deviceModel: deviceInfo.model,
        osVersion: deviceInfo.os,
      ));
    } catch (_) {
      emit(ProfileError('Could not load your profile. Please try again.'));
    }
  }

  /// Picks a gallery image, saves it to Firestore, and updates the screen.
  /// Returns an error message to show, or null if it worked (or was cancelled).
  Future<String?> updatePhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return null;

    try {
      // Small, compressed image so it fits in a Firestore document (1 MiB max).
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 400,
      );
      if (pickedImage == null) return null; // user cancelled

      final photoBase64 = base64Encode(await pickedImage.readAsBytes());
      await _firestoreService.saveUserPhoto(current.user.uid, photoBase64);

      final updatedUser = UserModelBuilder()
          .setUid(current.user.uid)
          .setFullName(current.user.fullName)
          .setEmail(current.user.email)
          .setPhotoBase64(photoBase64)
          .build();

      emit(ProfileLoaded(
        user: updatedUser,
        deviceModel: current.deviceModel,
        osVersion: current.osVersion,
      ));
      return null;
    } catch (_) {
      return 'Could not update your photo. Please try again.';
    }
  }

  Future<({String model, String os})> _readDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return (
        model: '${info.manufacturer} ${info.model}',
        os: 'Android ${info.version.release} (SDK ${info.version.sdkInt})',
      );
    }
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return (
        model: info.utsname.machine,
        os: '${info.systemName} ${info.systemVersion}',
      );
    }
    return (model: 'Unknown device', os: 'Unknown OS');
  }
}