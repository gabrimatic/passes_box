class PasswordModel {
  int? id;
  String? title;
  String? username;
  String? imageName;
  String? password;

  PasswordModel({
    this.id,
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
      id: id ?? this.id,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'] as int?,
      title: map['title'] as String?,
      imageName: map['imageName'] as String?,
      password: map['password'] as String?,
      username: map['username'] as String?,
    );
  }

  Map<String, dynamic> toMap() => (id == null)
      ? {
          'title': title,
          'imageName': imageName,
          'username': username,
          'password': password,
        }
      : {
          'id': id,
          'title': title,
          'username': username,
          'imageName': imageName,
          'password': password,
        };
}

/*
class PasswordModelAdapter extends TypeAdapter<PasswordModel> {
  @override
  read(BinaryReader reader) => PasswordModel(
      group: reader.read(), title: reader.read(), password: reader.read());

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, PasswordModel obj) {
    writer.write(obj.title);
    writer.write(obj.password);
    writer.write(obj.group);
  }
}
*/
