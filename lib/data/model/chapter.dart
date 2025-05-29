  class Chapter {
    int? id;
    final String novel_id;
    final int index;
    final String title;
    final String content;
    final List<String>? images;

    static const name = "chapters";

    Chapter({
      this.id,
      required this.novel_id,
      required this.index,
      required this.title,
      required this.content,
      this.images,
    });

    Chapter copy({
      int? id,
      String? novel_id,
      int? index,
      String? title,
      String? content,
      List<String>? images,
    }) {
      return Chapter(
        id: id ?? this.id,
        novel_id: novel_id ?? this.novel_id,
        index: index ?? this.index,
        title: title ?? this.title,
        content: content ?? this.content,
        images: images ?? this.images,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'novel_id': novel_id,
        "index": index,
        'title': title,
        'content': content,
        'images': images,
      };
    }

    @override
    String toString() {
      return 'Chapter{id: $id, novel_id: $novel_id, index: $index, title: $title, content: $content, images: $images';
    }

    static Chapter fromMap(Map<String, dynamic> map) {
      final images = (map['images'] as List<dynamic>).map((item) => item.toString()).toList();
      return Chapter(
        id: map['id'],
        novel_id: map['novel_id'],
        index: map["index"],
        title: map['title'],
        content: map['content'],
        images: images,
      );
    }
  }
