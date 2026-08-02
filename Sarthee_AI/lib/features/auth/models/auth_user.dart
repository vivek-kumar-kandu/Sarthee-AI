class AuthUser {
  final String uid;
  final String? email;
  final String? name;
  final String? photo;

  AuthUser({required this.uid, this.email, this.name, this.photo});

  factory AuthUser.fromFirebase(dynamic user) {
    return AuthUser(
      uid: user.uid,

      email: user.email,

      name: user.displayName,

      photo: user.photoURL,
    );
  }
}
