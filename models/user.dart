class User {
  String name;
  String email;
  bool isAdmin;

  User({
    required this.name,
    required this.email,
  }) : isAdmin = false;

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        isAdmin = json['is_admin'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['is_admin'] = isAdmin;
    return data;
  }
}
