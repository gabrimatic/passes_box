import 'package:hive_flutter/hive_flutter.dart';
part 'password.g.dart';

@HiveType(typeId: 0)
class PasswordModel extends HiveObject {
  @HiveField(1)
  String? title;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String? imageName;

  @HiveField(4)
  String? password;

  PasswordModel({
    this.title,
    this.imageName,
    this.username,
    this.password,
  });

  PasswordModel copyWith({
    int? id,
    String? title,
    String? imageName,
    String? username,
    String? password,
  }) {
    return PasswordModel(
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
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
}
