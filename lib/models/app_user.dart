/// โครงสร้าง Collection: users  (uid, name, email, role)
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' | 'operator'

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: (m['uid'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        role: (m['role'] ?? 'operator') as String,
      );

  Map<String, dynamic> toMap() =>
      {'uid': uid, 'name': name, 'email': email, 'role': role};
}
