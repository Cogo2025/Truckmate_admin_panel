class Admin {
  final String id;
  final String username;
  final bool isFirstLogin;
  final DateTime? lastLogin;

  Admin({
    required this.id,
    required this.username,
    required this.isFirstLogin,
    this.lastLogin,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
    );
  }
}
