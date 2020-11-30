/*
class CategoryModel {
  int id;
  String title;
  String imageName;

  CategoryModel({
    this.id,
    this.title,
    this.imageName,
  });

  CategoryModel copyWith({
    int id,
    String title,
    String imageName,
  }) {
    return new CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
    );
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, title: $title, imageName: $imageName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          imageName == other.imageName);

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ imageName.hashCode;

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return new CategoryModel(
      id: map['id'] as int,
      title: map['title'] as String,
      imageName: map['imageName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'imageName': this.imageName,
    };
  }
}
*/
