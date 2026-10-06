import 'package:connect_me_community_app/domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    super.photoBase64,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoBase64: json['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        if (photoBase64 != null) 'photoBase64': photoBase64,
      };
}

/// BUILDER PATTERN: builds a UserModel step by step. Each setter returns the
/// builder itself, so calls chain. Only the fields we actually set are filled
/// in (name and email from sign-up), and the photo stays null until uploaded.
class UserModelBuilder {
  String _uid = '';
  String _fullName = '';
  String _email = '';
  String? _photoBase64;

  UserModelBuilder setUid(String uid) {
    _uid = uid;
    return this;
  }

  UserModelBuilder setFullName(String fullName) {
    _fullName = fullName;
    return this;
  }

  UserModelBuilder setEmail(String email) {
    _email = email;
    return this;
  }

  UserModelBuilder setPhotoBase64(String photoBase64) {
    _photoBase64 = photoBase64;
    return this;
  }

  UserModel build() => UserModel(
        uid: _uid,
        fullName: _fullName,
        email: _email,
        photoBase64: _photoBase64,
      );
}