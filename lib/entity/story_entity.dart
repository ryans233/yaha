class StoryEntity {
    String by;
    int descendants;
    int id;
    List<int> kids;
    int score;
    int time;
    String title;
    String type;
    String url;

    StoryEntity({this.by, this.descendants, this.id, this.kids, this.score, this.time, this.title, this.type, this.url});

    factory StoryEntity.fromJson(Map<String, dynamic> json) {
        return StoryEntity(
            by: json['by'],
            descendants: json['descendants'],
            id: json['id'],
            kids: json['kids'] != null ? new List<int>.from(json['kids']) : null,
            score: json['score'],
            time: json['time'],
            title: json['title'],
            type: json['type'],
            url: json['url'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['by'] = this.by;
        data['descendants'] = this.descendants;
        data['id'] = this.id;
        data['score'] = this.score;
        data['time'] = this.time;
        data['title'] = this.title;
        data['type'] = this.type;
        data['url'] = this.url;
        if (this.kids != null) {
            data['kids'] = this.kids;
        }
        return data;
    }
}