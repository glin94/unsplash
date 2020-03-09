class Photo {
  String id;
  String desc;
  String altDesc;
  String createdAt;
  Map<String, dynamic> user;
  Map<String, dynamic> urls;
  
  Photo(
      {this.id, this.desc, this.altDesc, this.createdAt, this.user, this.urls});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
        id: json['id'],
        desc: json['description'],
        altDesc: json['alt_description'],
        createdAt: json['created_at'],
        user: json['user'],
        urls: json['urls']);
  }
}
