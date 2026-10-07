class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String? photoBase64; // optional: only set after a photo is uploaded

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoBase64,
  });
}
