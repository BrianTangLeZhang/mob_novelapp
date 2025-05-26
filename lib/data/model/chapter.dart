class Chapter {
  int? id;
  final int novel;
  final int index;
  final String name;
  final String content;
  final List<String>? images;

  Chapter({
    this.id,
    required this.novel,
    required this.index,
    required this.name,
    required this.content,
    this.images,
  });

  Chapter copy({
    int? id,
    int? novel,
    int? index,
    String? name,
    String? content,
    List<String>? images,
  }) {
    return Chapter(
      id: id ?? this.id,
      novel: novel ?? this.novel,
      index: index ?? this.index,
      name: name ?? this.name,
      content: content ?? this.content,
      images: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'novel': novel,
      'name': name,
      'content': content,
      'images': images,
    };
  }

  @override
  String toString() {
    return 'Chapter{id: $id, novel: $novel, index: $index, name: $name, content: $content, images: $images';
  }

  static Chapter fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      novel: map['novel'],
      index: map["index"],
      name: map['name'],
      content: map['content'],
      images: map['images'],
    );
  }
}
