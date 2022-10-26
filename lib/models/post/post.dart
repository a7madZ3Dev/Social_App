/// post model
class Post {
  final String? uid;
  final String? postId;
  final String? name;
  final String? text;
  final String? userImage;
  final String? postImage;
  final DateTime? dateTime;

  Post({
    this.uid,
    this.postId,
    this.name,
    this.text,
    this.userImage,
    this.dateTime,
    this.postImage,
  });

  factory Post.fromJson(Map<String, dynamic> jsonData, String postId) {
    return Post(
      postId: postId,
      uid: jsonData['uid'],
      name: jsonData['name'],
      text: jsonData['text'],
      userImage: jsonData['image'],
      dateTime: jsonData['dateTime'].toDate(),
      postImage: jsonData['postImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'text': text,
      'postId': postId,
      'image': userImage,
      'dateTime': dateTime,
      'postImage': postImage,
    };
  }
}
