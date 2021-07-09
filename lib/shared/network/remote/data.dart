import "dart:io";

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../cubit/cubit.dart';
import '../../../models/user/user.dart';
import '../../../models/post/post.dart';
import '../../components/constants.dart';
import '../../../models/message/message.dart';

class DatabaseService {
  /// users collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  /// posts collection reference
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('posts');

  /// posts collection reference
  final CollectionReference commentCollection =
      FirebaseFirestore.instance.collection('comments');

  /// get user data
  Future<DocumentSnapshot> getUserData() async {
    return await userCollection.doc(userId).get();
  }

  /// get all users data
  Future<QuerySnapshot> getAllUsersData() async {
    return await userCollection.get();
  }

  /// store new user data in fire base storage and fire base cloude
  Future<void> updateData({
    BuildContext? context,
    File? image,
    File? cover,
    String? name,
    String? bio,
    String? phone,
  }) async {
    String? urlImage;
    String? urlCover;
    UserFireBase userFireBase = ChatCubit.get(context).userFireBase!;

    if (image != null) {
      await FirebaseStorage.instance
          .ref()
          .child('users/${Uri.file(image.path).pathSegments.last}')
          .putFile(image)
          .then((value) async {
        urlImage = await value.ref.getDownloadURL();
      }).catchError((error) {
        print(error.toString());
      });
    }

    if (cover != null) {
      await FirebaseStorage.instance
          .ref()
          .child('users/${Uri.file(cover.path).pathSegments.last}')
          .putFile(cover)
          .then((value) async {
        urlCover = await value.ref.getDownloadURL();
      }).catchError((error) {
        print(error.toString());
      });
    }

    await userCollection.doc(userId).update({
      'image': urlImage ?? userFireBase.image,
      'cover': urlCover ?? userFireBase.cover,
      'phone': phone ?? userFireBase.phone,
      'name': name ?? userFireBase.name,
      'bio': bio ?? userFireBase.bio,
    });
  }

  /// get posts data
  Future<QuerySnapshot> getPosts() async {
    return await postCollection.orderBy('dateTime', descending: true).get();
  }

  /// create new post
  Future<void> createPost({
    BuildContext? context,
    File? postImage,
    String? postContent,
  }) async {
    String? urlImage;
    UserFireBase userFireBase = ChatCubit.get(context).userFireBase!;

    if (postImage != null) {
      await FirebaseStorage.instance
          .ref()
          .child('posts/${Uri.file(postImage.path).pathSegments.last}')
          .putFile(postImage)
          .then((value) async {
        urlImage = await value.ref.getDownloadURL();
      }).catchError((error) {
        print(error.toString());
      });
    }

    Post post = Post(
      image: userFireBase.image,
      name: userFireBase.name,
      uid: userFireBase.uid,
      postImage: urlImage ?? '',
      dateTime: DateTime.now(),
      text: postContent ?? '',
    );

    await postCollection.add(post.toMap());

    // await postCollection.add(post.toMap()).then(
    // (value) => postCollection.doc(value.id).update({'postId': value.id}),);
  }

  /// do like to the post
  Future<void> createComment(
      {required String postUid,
      required String userUid,
      required String commentText}) async {
    await postCollection.doc(postUid).collection('comments').doc(userUid).set({
      'postId': postUid,
      'userUid': userUid,
      'text': commentText,
    });
  }

  /// do like to the post
  Future<void> likePost({
    required String postUid,
    required String userUid,
  }) async {
    await postCollection
        .doc(postUid)
        .collection('likes')
        .doc(userUid)
        .set({'like': true});
  }

  /// create chat with user
  Future<void> createChatWithUser({
    required String? text,
    required String receiverUid,
  }) async {
    if (text == null || text.isEmpty) return;
    Message message = Message(
      dateTime: DateTime.now(),
      receiverId: receiverUid,
      senderId: userId!,
      text: text,
    );

    /// add the message in his chat (Reciver User)
    await userCollection
        .doc(receiverUid.trim())
        .collection('chats')
        .doc(userId!.trim())
        .collection('messages')
        .add(message.toMap());

    /// add the message in my chat (Sender User)
    await userCollection
        .doc(userId!.trim())
        .collection('chats')
        .doc(receiverUid.trim())
        .collection('messages')
        .add(message.toMap());

  }

  /// map shanshote to list of messages
  List<Message> _messagesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return Message.fromJson(data);
    }).toList();
  }

  /// get data chat with the user
  Stream<List<Message>> getChatDataWithUser({
    required String receiverUid,
  }) {
    return userCollection
        .doc(userId!.trim())
        .collection('chats')
        .doc(receiverUid.trim())
        .collection('messages')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(_messagesListFromSnapshot);
  }
}
