class Novel {
  int? id;
  final String title;
  final String description;
  final String cover;

  static const name = "novels";

  Novel({
    this.id,
    required this.title,
    required this.description,
    this.cover = "",
  });

  Novel copy({int? id, String? title, String? description, String? cover}) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
    );
  }

  //convert data to map
  Map<String, dynamic> toMap() {
    return {'title': title, "description": description, 'cover': cover};
  }

  @override
  String toString() {
    return 'Novel{$id, $title, $description, $cover}';
  }

  // convert data from map to Novel object
  static Novel fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      cover: map['cover'],
    );
  }
}
