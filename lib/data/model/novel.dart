class Novel {
  int? id;
  final String title;
  final String description;
  final String cover;
  final String user_id;

  static const name = "novels";

  Novel({
    this.id,
    required this.title,
    required this.description,
    this.cover = "",
    required this.user_id,
  });

  Novel copy({
    int? id,
    String? title,
    String? description,
    String? cover,
    String? user_id,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      user_id: user_id ?? this.user_id,
    );
  }

  //convert data to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "description": description,
      'cover': cover,
      "user_id": user_id,
    };
  }

  @override
  String toString() {
    return 'Novel{$id, $title, $description, $cover, $user_id}';
  }

  // convert data from map to Novel object
  static Novel fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      cover: map['cover'],
      user_id: map['user_id'],
    );
  }
}
