class PasswordModel {
  int? key;
  String? title;
  String? username;
  String? imageName;
  String? password;

  PasswordModel({
    this.key,
    this.title,
    this.imageName,
    this.username,
    this.password,
  });

  PasswordModel copyWith({
    int? key,
    String? title,
    String? imageName,
    String? username,
    String? password,
  }) {
    return PasswordModel(
      key: key ?? this.key,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map, {int? key}) {
    return PasswordModel(
      key: key,
      title: map['title'] as String?,
      imageName: map['imageName'] as String?,
      password: map['password'] as String?,
      username: map['username'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'imageName': imageName,
        'username': username,
        'password': password,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordModel && key != null && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
