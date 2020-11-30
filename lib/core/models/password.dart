class PasswordModel {
  int id;
  String title;
  String imageName;
  String password;

  PasswordModel({
    this.id,
    this.title,
    this.imageName,
    this.password,
  });

  PasswordModel copyWith({
    int id,
    String title,
    String imageName,
    String password,
  }) {
    return new PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'PasswordModel{id: $id, title: $title, imageName: $imageName, password: $password}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          imageName == other.imageName &&
          password == other.password);

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ imageName.hashCode ^ password.hashCode;

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return new PasswordModel(
      id: map['id'] as int,
      title: map['title'] as String,
      imageName: map['imageName'] as String,
      password: map['password'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return (id == null)
        ? {
            'title': this.title,
            'imageName': this.imageName,
            'password': this.password,
          }
        : {
            'id': this.id,
            'title': this.title,
            'imageName': this.imageName,
            'password': this.password,
          };
  }
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
