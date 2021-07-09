/// user model
class UserFireBase {
  final String? uid;
  final String? name;
  final String? phone;
  final String? email;
  final bool? isEmailVerified;
  final String? image;
  final String? cover;
  final String? bio;
  UserFireBase({
    this.uid,
    this.name,
    this.phone,
    this.email,
    this.isEmailVerified,
    this.image,
    this.cover,
    this.bio,
  });

  factory UserFireBase.fromJson( Map<String, dynamic> jsonData) {
    return UserFireBase(
      uid: jsonData['uid'],
      bio: jsonData['bio'],
      name: jsonData['name'],
      phone: jsonData['phone'],
      email: jsonData['email'],
      image: jsonData['image'],
      cover: jsonData['cover'],
      isEmailVerified: jsonData['isEmailVerified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uid': uid,
      'isEmailVerified': isEmailVerified,
      'image': image,
      'cover' : cover,
      'bio': bio,
    };
  }
}
