class PasswordModel {
  int? key;
  String? title;
  String? username;
  String? imageName;
  String? password;
  String? notes;
  String? url;
  String? totpSecret;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? passwordHistory;
  bool isDeleted;
  DateTime? deletedAt;

  PasswordModel({
    this.key,
    this.title,
    this.imageName,
    this.username,
    this.password,
    this.notes,
    this.url,
    this.totpSecret,
    this.createdAt,
    this.updatedAt,
    this.passwordHistory,
    this.isDeleted = false,
    this.deletedAt,
  });

  PasswordModel copyWith({
    int? key,
    String? title,
    String? imageName,
    String? username,
    String? password,
    String? notes,
    String? url,
    String? totpSecret,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? passwordHistory,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return PasswordModel(
      key: key ?? this.key,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      url: url ?? this.url,
      totpSecret: totpSecret ?? this.totpSecret,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordHistory: passwordHistory ?? this.passwordHistory,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map, {int? key}) {
    return PasswordModel(
      key: key,
      title: map['title'] as String?,
      imageName: map['imageName'] as String?,
      password: map['password'] as String?,
      username: map['username'] as String?,
      notes: map['notes'] as String?,
      url: map['url'] as String?,
      totpSecret: map['totpSecret'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      passwordHistory: (map['passwordHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'imageName': imageName,
        'username': username,
        'password': password,
        'notes': notes,
        'url': url,
        'totpSecret': totpSecret,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'passwordHistory': passwordHistory,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordModel && key != null && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
