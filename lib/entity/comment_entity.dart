import 'dart:core';

class CommentEntity {
    String by;
    int id;
    List<int> kids;
    int parent;
    String text;
    int time;
    String type;
    bool deleted;

    CommentEntity({this.by, this.id, this.kids, this.parent, this.text, this.time, this.type, this.deleted});

    factory CommentEntity.fromJson(Map<String, dynamic> json) {
        return CommentEntity(
            by: json['by'],
            id: json['id'],
            kids: json['kids'] != null ? new List<int>.from(json['kids']) : null,
            parent: json['parent'],
            text: json['text'],
            time: json['time'],
            type: json['type'],
            deleted: json['deleted']
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['by'] = this.by;
        data['id'] = this.id;
        data['parent'] = this.parent;
        data['text'] = this.text;
        data['time'] = this.time;
        data['type'] = this.type;
        if (this.kids != null) {
            data['kids'] = this.kids;
        }
        if (this.deleted != null) {
            data['deleted'] = this.deleted;
        }
        return data;
    }

    @override
  String toString() {
    return """{"by": $by, "id": $id, "kids": $kids, "parent": $parent, "text": $text, "time": $time, "type": $type, "deleted": $deleted}""";
  }
}