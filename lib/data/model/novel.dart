class Novel {
  String? id;
  final String title;
  final String description;
  final String cover;
  final String user_id;
  final String author;

  static const name = "novels";

  Novel({
    this.id,
    required this.title,
    required this.description,
    this.cover = "",
    required this.user_id,
    required this.author,
  });

  Novel copy({
    String? id,
    String? title,
    String? description,
    String? cover,
    String? user_id,
    String? author,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      user_id: user_id ?? this.user_id,
      author: author ?? this.author,
    );
  }

  //convert data to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      "description": description,
      'cover': cover,
      "user_id": user_id,
      "author": author,
    };
  }

  @override
  String toString() {
    return 'Novel{$id, $title, $description, $cover, $user_id, $author}';
  }

  // convert data from map to Novel object
  static Novel fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      cover: map['cover'],
      user_id: map['user_id'],
      author: map['author'],
    );
  }
}
