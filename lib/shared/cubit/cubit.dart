import "dart:io";

import 'package:bloc/bloc.dart';
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
        .then((value) async{
      if (value != null) {
        token = await FirebaseMessaging.instance.getToken();
        userId = value.user?.uid;
        emit(LogInSuccessState());
        CacheHelper.saveData(uid: userId);
        navigateAndReplacement(context, Home());
        BlocProvider.of<ChatCubit>(context).getUser();
        BlocProvider.of<ChatCubit>(context).getAllPosts();
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
    @required String? name,
    @required String? email,
    @required String? phone,
    @required String? uid,
    required BuildContext context,
  }) async {
    user = UserFireBase(
      name: name,
      email: email,
      phone: phone,
      uid: uid,
      isEmailVerified: false,
      bio: 'write your bio ..',
      image:
          'https://image.freepik.com/free-photo/cheerful-afro-american-female-blogger-posts-images-online-works-via-phone-laughs-funny-video-internet-has-fun-closes-eyes-wears-grey-jacket_273609-43339.jpg',
      cover:
          'https://image.freepik.com/free-photo/photo-attractive-bearded-young-man-with-cherful-expression-makes-okay-gesture-with-both-hands-likes-something-dressed-red-casual-t-shirt-poses-against-white-wall-gestures-indoor_273609-16239.jpg',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(user.toMap())
        .then((value) {
      BlocProvider.of<ChatCubit>(context).userFireBase = user;
      BlocProvider.of<ChatCubit>(context).getAllPosts();
      CacheHelper.saveData(uid: uid);
      emit(CreateUserSuccessState());
      // navigateAndReplacement(context, Home());
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
        await createUser(
            name: name,
            email: email,
            phone: phone,
            uid: value.user?.uid,
            context: context);
        navigateAndReplacement(context, Home());
      }
    }).catchError((error) {
      emit(RegisterErrorState(error: error.toString()));
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
}

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(ChatInitialState());

  /// get object from cubit class
  static ChatCubit get(context) => BlocProvider.of<ChatCubit>(context);

  DatabaseService databaseService = DatabaseService();
  List<UserFireBase> users = [];
  UserFireBase? userFireBase;
  List<int> comments = [];
  List<Post> posts = [];
  List<int> likes = [];
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
    Map<String, dynamic>? data = snapshot.data()!;
    return UserFireBase.fromJson(data);
  }

  /// get user data
  void getUser() {
    if (userId == null || userId == '') {
      print('no user Id data');
      return;
    } else {
      print('bring data now');
      emit(ChatGetUserLoadingState());
      databaseService.getUserData().then((value) {
        userFireBase = userDataFromSnapshot(value);
        emit(ChatGetUserSuccessState());
      }).catchError((error) {
        emit(ChatGetUserErrorState(error: error.toString()));
        print(error.toString());
      });
    }
  }

  /// reFormat data in UserFireBase
  List<UserFireBase> usersDataFromSnapshot(QuerySnapshot snapshot) {
    List<UserFireBase> users = [];
    snapshot.docs.forEach((user) {
      Map<String, dynamic>? data = user.data();

      /// firebase add space in the front of uid for user !!
      if (data['uid'].toString().trim() != userId) {
        users.add(UserFireBase.fromJson(data));
      } else {
        print('can\'t add current user');
      }
    });
    return users;
  }

  /// get all users data
  void getAllUsers() {
    if (userId == null || userId == '') {
      print('no user Id found');
      return;
    } else {
      print('bring all users data now');
      emit(ChatGetAllUsersLoadingState());
      databaseService.getAllUsersData().then((value) {
        users = usersDataFromSnapshot(value);
        emit(ChatGetAllUsersSuccessState());
      }).catchError((error) {
        emit(ChatGetAllUsersErrorState());
        print(error.toString());
      });
    }
  }

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
        .then((value) {
      getUser();
      emit(ChatUpdateProfileSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(ChatUpdateProfileErrorState());
    });
  }

  /// get All Posts and likes and comments
  void getAllPosts() {
    posts = [];
    likes = [];
    comments = [];
    emit(ChatGetPostsLoadingState());
    databaseService.getPosts().then((postsValue) {
      var postsNumber = postsValue.docs.length;
      postsValue.docs.forEach((element) {
        element.reference.collection('likes').get().then((likesValue) {
          likes.add(likesValue.docs.length);
          posts.add(Post.fromJson(element.data(), element.id));
        }).then((value) {
          element.reference.collection('comments').get().then((commentValue) {
            comments.add(commentValue.docs.length);
          }).then((value) {
            if (comments.length == postsNumber) {
              emit(ChatGetPostsSuccessState());
            }
          });
        });
      });
    }).catchError((error) {
      emit(ChatGetPostsErrorState());
    });
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
      )
          .then((value) {
        emit(ChatNewPostSuccessState());
        postImage = null;
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
          .then((value) {
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
        .then((value) {
      emit(ChatLikePostSuccessState());
    }).catchError((error) {
      emit(ChatLikePostErrorState());
      print(error.toString());
    });
  }

  /// initial index
  int selectedPageIndex = 0;

  /// change number for pages
  void changeIndex(int index) {
    selectedPageIndex = index;
    if (index == 1) {
      if (users.isEmpty) {
        getAllUsers();
      } else
        print('users list is available');
    }

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

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  /// get object from cubit class
  static AppCubit get(context) => BlocProvider.of<AppCubit>(context);

  bool isDark = false;

  /// change theme mode
  void changeAppMode() {
    // isDark = !isDark;
    // CacheHelper.saveData(
    //   key: kIsDark,
    //   value: isDark,
    // ).then((value) => emit(AppChangeModeState()));
  }

  /// get theme mode
  void getAppMode() {
    // CacheHelper.getData(key: kIsDark).then((value) {
    //   isDark = value;
    //   emit(AppChangeModeState());
    // });
  }
}
