class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
    );
  }

  String get initials {
    if (fullName.isEmpty) return "U";
    List<String> nameParts = fullName.trim().split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}".toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }
}