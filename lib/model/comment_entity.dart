import 'dart:core';

class CommentEntity {
    String by;
    int id;
    List<int> kids;
    int parent;
    String text;
    int time;
    String type;

    CommentEntity({this.by, this.id, this.kids, this.parent, this.text, this.time, this.type});

    factory CommentEntity.fromJson(Map<String, dynamic> json) {
        return CommentEntity(
            by: json['by'],
            id: json['id'],
            kids: json['kids'] != null ? new List<int>.from(json['kids']) : null,
            parent: json['parent'],
            text: json['text'],
            time: json['time'],
            type: json['type'],
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
        return data;
    }
}