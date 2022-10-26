import "dart:io";

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../cubit/states.dart';
import '../network/remote/auth.dart';
import '../../models/user/user.dart';
import '../../layout/home_layout.dart';
import '../../../models/post/post.dart';
import '../../modules/feeds/feeds.dart';
import '../../modules/users/users.dart';
import '../../modules/chats/chats.dart';
import '../../modules/settings/settings.dart';
import '../../shared/network/remote/data.dart';
import '../../shared/components/constants.dart';
import '../../shared/components/components.dart';
import '../../shared/network/local/image_pic.dart';
import '../../shared/styles/styles/icon_broken.dart';
import '../../shared/network/local/cache_helper.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  /// get object from cubit class
  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  bool isPassword = true;
  late UserFireBase user;

  /// change state of password field
  void changeState() {
    isPassword = !isPassword;
    emit(AuthChangePasswordState());
  }

  /// for login the user
  void userLogin(BuildContext context, String email, String password) {
    emit(LogInLoadingState());
    Auth()
        .logIn(
      email: email,
      password: password,
    )
        .then((value) async {
      if (value != null) {
        token = await FirebaseMessaging.instance.getToken();
        userId = value.user?.uid;
        BlocProvider.of<ChatCubit>(context).getUser();
        BlocProvider.of<ChatCubit>(context).getAllPosts();
        BlocProvider.of<ChatCubit>(context).getAllUsers();
        emit(LogInSuccessState());
        navigateAndReplacement(context, Home());
        CacheHelper.saveData(uid: userId);
      }
    }).catchError((error) {
      emit(LogInErrorState(error: error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message, textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      print(error.toString());
    }, test: (e) => e is FirebaseAuthException).catchError((error) {
      emit(LogInErrorState(error: error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not retrieve data. Please try again later.',
              textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      print(error.toString());
    }, test: (e) => e is SocketException);
  }

  /// create user object
  Future<void> createUser({
    required String? name,
    required String? email,
    required String? phone,
    required String? uid,
    required BuildContext context,
  }) async {
    user = UserFireBase(
      name: name,
      email: email,
      phone: phone,
      uid: uid,
      isEmailVerified: false,
      bio: 'write your bio ..',
      image: kDefaultUserImage,
      cover: kDefaultUserCoverImage,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(user.toMap())
        .then((val) {
      BlocProvider.of<ChatCubit>(context).getAllPosts();
      BlocProvider.of<ChatCubit>(context).getAllUsers();
      BlocProvider.of<ChatCubit>(context).userFireBase = user;
      emit(CreateUserSuccessState());
    }).catchError((error) {
      emit(CreateUserErrorState(error: error.toString()));
    });
  }

  /// for register a user
  void userRegister(BuildContext context, String email, String password,
      String phone, String name) {
    emit(RegisterLoadingState());
    Auth()
        .signUp(
      email: email,
      password: password,
    )
        .then((value) async {
      if (value != null) {
        userId = value.user?.uid;
        token = await FirebaseMessaging.instance.getToken();
        createUser(
                name: name,
                email: email,
                phone: phone,
                uid: value.user?.uid,
                context: context)
            .then((_) {
          navigateAndReplacement(context, Home());
          CacheHelper.saveData(uid: userId);
        });
      }
    }).catchError((error) {
      emit(RegisterErrorState(error: error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.toString(), textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      print(error.toString());
    }, test: (e) => e is FirebaseAuthException).catchError((error) {
      emit(LogInErrorState(error: error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not retrieve data. Please try again later.',
              textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      print(error.toString());
    }, test: (e) => e is SocketException);
  }
}

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(ChatInitialState());

  /// get object from cubit class
  static ChatCubit get(context) => BlocProvider.of<ChatCubit>(context);

  DatabaseService databaseService = DatabaseService();
  List<UserFireBase> users = [];
  List<UserFireBase> userChats = [];
  UserFireBase? userFireBase;
  List<int> comments = [];
  List<Post> posts = [];
  List<int> likes = [];
  List<Future<int>> likesFutures = [];
  List<Future<int>> commentsFutures = [];
  File? profileImage;
  File? coverImage;
  File? postImage;
  String? phone;
  String? name;
  String? bio;

  /// get image
  void takeImage({String? image}) {
    GetImage().pickImage().then((value) {
      if (value != null) {
        switch (image) {
          case 'profile':
            profileImage = value;
            break;
          case 'cover':
            coverImage = value;
            break;
          case 'post':
            postImage = value;
            break;
          default:
            print(' no part match ');
        }
        emit(ChatImagePickedSuccessState());
      }
    }).catchError((error) {
      print(error.toString());
      emit(ChatImagePickedErrorState());
    });
  }

  /// delete image
  void deleteImage() {
    postImage = null;
    emit(ChatDeleteImageNewPostState());
  }

  /// reFormat data in UserFireBase
  UserFireBase userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data()! as Map<String, dynamic>;
    return UserFireBase.fromJson(data);
  }

  /// get user data
  void getUser() async {
    if (userId == null || userId == '') {
      String val = await CacheHelper.getData();
      if (val == '') {
        print('Will not get user data because no user Id data');
        return;
      }
    } else {
      print('bring data now');
      emit(ChatGetUserLoadingState());
      databaseService.getUserData().then((value) {
        userFireBase = userDataFromSnapshot(value);
        emit(ChatGetUserSuccessState());
      }).catchError((error) {
        print(error.toString());
        emit(ChatGetUserErrorState(error: error.toString()));
      });
    }
  }

  /// reFormat data in list of UserFireBase
  List<UserFireBase> usersDataFromSnapshot(QuerySnapshot snapshot) {
    List<UserFireBase> users = [];
    snapshot.docs.forEach((user) {
      Map<String, dynamic>? data = user.data() as Map<String, dynamic>;

      /// just add other users
      if (data['uid'].toString().trim() != userId) {
        users.add(UserFireBase.fromJson(data));
      } else {
        print('can\'t add current user');
      }
    });
    return users;
  }

  /// get all users data
  void getAllUsers() async {
    if (userId == null || userId == '') {
      String val = await CacheHelper.getData();
      if (val == '') {
        print('Will not get All Users data because no user Id found');
        return;
      }
    } else {
      print('bring all users data now');
      emit(ChatGetAllUsersLoadingState());
      databaseService.getAllUsersData().then((value) {
        users = usersDataFromSnapshot(value);
        emit(ChatGetAllUsersSuccessState());
      }).catchError((error) {
        print(error.toString());
        emit(ChatGetAllUsersErrorState());
      });
    }
  }

  // /// reFormat data in list of User Fire Base
  // List<UserFireBase> userChatsDataFromSnapshot(QuerySnapshot snapshot) {
  //   List<UserFireBase> userChats = [];
  //   if (users.isNotEmpty) {
  //     snapshot.docs.forEach((element) {
  //       UserFireBase chatUser =
  //           users.firstWhere((user) => user.uid == element.id);
  //       userChats.add(chatUser);
  //     });
  //   }
  //   return userChats;
  // }

  // /// get all user chats
  // void getUserChats() {
  //   print('bring all chats data now');
  //   emit(ChatGetAllUserChatsLoadingState());
  //   databaseService.getAllUserChatsData().then((value) {
  //     userChats = userChatsDataFromSnapshot(value);
  //     emit(ChatGetAllUserChatsSuccessState());
  //   }).catchError((error) {
  //     print(error.toString());
  //     emit(ChatGetAllUserChatsErrorState());
  //   });
  // }

  /// update image profile
  void updateProfile(BuildContext context) {
    emit(ChatUpdateProfileLoadingState());
    databaseService
        .updateData(
      context: context,
      image: profileImage,
      cover: coverImage,
      phone: phone,
      name: name,
      bio: bio,
    )
        .then((_) {
      getUser();
      emit(ChatUpdateProfileSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ChatUpdateProfileErrorState());
    });
  }

  /// get All Posts and likes and comments
  void getAllPosts() async {
    if (userId == null || userId == '') {
      String val = await CacheHelper.getData();
      if (val == '') {
        print('Will not get All Posts data because no user Id found');
        return;
      }
    } else {
      posts = [];
      likes = [];
      comments = [];
      likesFutures = [];
      commentsFutures = [];
      emit(ChatGetPostsLoadingState());
      databaseService.getPosts().then((postsValue) async {
        var postsNumber = postsValue.docs.length;

        postsValue.docs.forEach((element) {
          posts.add(Post.fromJson(
              element.data() as Map<String, dynamic>, element.id));

          likesFutures.add(FirebaseFirestore.instance
              .collection('posts')
              .doc(element.id)
              .collection('likes')
              .get()
              .then((value) => value.docs.length));

          commentsFutures.add(FirebaseFirestore.instance
              .collection('posts')
              .doc(element.id)
              .collection('comments')
              .get()
              .then((value) => value.docs.length));
        });

        likes = await Future.wait(likesFutures);
        comments = await Future.wait(commentsFutures);
        if (comments.length == postsNumber) {
          emit(ChatGetPostsSuccessState());
        }
        // element.reference.collection('likes').get().then((likesValue) {
        //   likes.add(likesValue.docs.length);
        //   posts.add(Post.fromJson(
        //       element.data() as Map<String, dynamic>, element.id));
        // }).then((value) {
        //   element.reference.collection('comments').get().then((commentValue) {
        //     comments.add(commentValue.docs.length);
        //   }).then((_) {
        //     if (comments.length == postsNumber) {
        //       emit(ChatGetPostsSuccessState());
        //     }
        //   });
        // });
        // });
      }).catchError((error) {
        emit(ChatGetPostsErrorState());
      });
    }
  }

  /// add post
  void addPost(BuildContext context, String? postContent) {
    if (postImage == null && postContent == null) {
      print('Empty Data');
      return;
    } else {
      emit(ChatNewPostLoadingState());
      databaseService
          .createPost(
        context: context,
        postImage: postImage,
        postContent: postContent,
        userFireBase: userFireBase!,
      )
          .then((_) {
        emit(ChatNewPostSuccessState());
        postImage = null;
        getAllPosts();
      }).catchError((error) {
        print(error.toString());
        emit(ChatNewPostErrorState());
      });
    }
  }

  /// add comment
  void addComment(String? commentContent, String postUid) {
    if (commentContent!.isEmpty) {
      print('Empty Data');
      return;
    } else {
      emit(ChatNewCommentLoadingState());
      databaseService
          .createComment(
        postUid: postUid,
        userUid: userFireBase!.uid!,
        commentText: commentContent,
      )
          .then((_) {
        emit(ChatNewCommentSuccessState());
      }).catchError((error) {
        print(error.toString());
        emit(ChatNewCommentErrorState());
      });
    }
  }

  /// like post
  void doLike(String postUid) {
    databaseService
        .likePost(postUid: postUid, userUid: userFireBase!.uid!)
        .then((_) {
      emit(ChatLikePostSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ChatLikePostErrorState());
    });
  }

  /// initial index
  int selectedPageIndex = 0;

  /// change number for pages
  void changeIndex(int index) {
    selectedPageIndex = index;
    emit(ChatChangeBottomNavBarState());
  }

  /// screens
  final List<Map<String, dynamic>> screens = [
    {
      'screen': FeedsScreen(),
      'title': 'Home',
    },
    {
      'screen': ChatsScreen(),
      'title': 'Chats',
    },
    {
      'screen': UsersScreen(),
      'title': 'Users',
    },
    {
      'screen': SettingsScreen(),
      'title': 'Settings',
    },
  ];

  /// tabs for nav bar
  List<BottomNavigationBarItem> getBottomNavBarList() {
    List<BottomNavigationBarItem> bottomItem = [
      BottomNavigationBarItem(
        icon: Icon(IconBroken.Home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(IconBroken.Chat),
        label: 'Chats',
      ),
      BottomNavigationBarItem(
        icon: Icon(IconBroken.User),
        label: 'Users',
      ),
      BottomNavigationBarItem(
        icon: Icon(IconBroken.Setting),
        label: 'Settings',
      ),
    ];
    return bottomItem;
  }
}

// class AppCubit extends Cubit<AppStates> {
//   AppCubit() : super(AppInitialState());

//   /// get object from cubit class
//   static AppCubit get(context) => BlocProvider.of<AppCubit>(context);

//   bool isDark = false;

//   /// change theme mode
//   void changeAppMode() {
//     isDark = !isDark;
//     CacheHelper.saveData(
//       key: kIsDark,
//       value: isDark,
//     ).then((value) => emit(AppChangeModeState()));
//   }

//   /// get theme mode
//   void getAppMode() {
//     CacheHelper.getData(key: kIsDark).then((value) {
//       isDark = value;
//       emit(AppChangeModeState());
//     });
//   }
// }
