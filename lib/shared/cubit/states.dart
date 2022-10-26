/// auth states
abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

/// password view
class AuthChangePasswordState extends AuthStates {}

/// log in
class LogInLoadingState extends AuthStates {}

class LogInSuccessState extends AuthStates {}

class LogInErrorState extends AuthStates {
  final String error;
  LogInErrorState({
    required this.error,
  });
}

/// register
class RegisterLoadingState extends AuthStates {}

class RegisterSuccessState extends AuthStates {}

class RegisterErrorState extends AuthStates {
  final String error;
  RegisterErrorState({
    required this.error,
  });
}

/// create user
class CreateUserSuccessState extends AuthStates {}

class CreateUserErrorState extends AuthStates {
  final String error;
  CreateUserErrorState({
    required this.error,
  });
}

/// all operations states
abstract class ChatStates {}

class ChatInitialState extends ChatStates {}

/// for get user data
class ChatGetUserLoadingState extends ChatStates {}

class ChatGetUserSuccessState extends ChatStates {}

class ChatGetUserErrorState extends ChatStates {
  final String error;
  ChatGetUserErrorState({
    required this.error,
  });
}

/// for get all user data
class ChatGetAllUsersLoadingState extends ChatStates {}

class ChatGetAllUsersSuccessState extends ChatStates {}

class ChatGetAllUsersErrorState extends ChatStates {}

/// for get all user data
class ChatGetAllUserChatsLoadingState extends ChatStates {}

class ChatGetAllUserChatsSuccessState extends ChatStates {}

class ChatGetAllUserChatsErrorState extends ChatStates {}

/// bottom navBar
class ChatChangeBottomNavBarState extends ChatStates {}

/// for profile and cover image state
class ChatImagePickedSuccessState extends ChatStates {}

class ChatImagePickedErrorState extends ChatStates {}

/// update profile
class ChatUpdateProfileLoadingState extends ChatStates {}

class ChatUpdateProfileSuccessState extends ChatStates {}

class ChatUpdateProfileErrorState extends ChatStates {}

/// add post
class ChatNewPostLoadingState extends ChatStates {}

class ChatNewPostSuccessState extends ChatStates {}

class ChatNewPostErrorState extends ChatStates {}

/// delete image from post or comment
class ChatDeleteImageNewPostState extends ChatStates {}

/// get all posts
class ChatGetPostsLoadingState extends ChatStates {}

class ChatGetPostsSuccessState extends ChatStates {}

class ChatGetPostsErrorState extends ChatStates {}

/// update likes
class ChatLikePostSuccessState extends ChatStates {}

class ChatLikePostErrorState extends ChatStates {}

/// add comment
class ChatNewCommentLoadingState extends ChatStates {}

class ChatNewCommentSuccessState extends ChatStates {}

class ChatNewCommentErrorState extends ChatStates {}

/// class for theme mode
abstract class AppStates {}

class AppInitialState extends AppStates {}

class AppChangeModeState extends AppStates {}
