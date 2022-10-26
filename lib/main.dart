// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import './layout/home_layout.dart';
import './shared/cubit/cubit.dart';
import './modules/login/login.dart';
import './shared/styles/themes.dart';
import './shared/bloc_observer.dart';
import './shared/components/constants.dart';
import './shared/components/components.dart';
import './shared/network/local/cache_helper.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  userId = await CacheHelper.getData();
  if (userId != null || userId != '') {
    token = await FirebaseMessaging.instance.getToken();
    print(token);
  }

  /// when the app in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    print('on message');
    print(event.data.toString());
    showToast(
      text: 'on message',
      state: ToastStates.SUCCESS,
    );
  });

  /// when click on notification to open app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
    print('on message opened app');
    print(event.data.toString());
    showToast(
      text: 'on message opened app',
      state: ToastStates.SUCCESS,
    );
  });

  /// when the app run in background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp(userId));
}

/// handle the operation in background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('on background message');
  print(message.data.toString());
  showToast(
    text: 'on background message',
    state: ToastStates.SUCCESS,
  );
}

class MyApp extends StatelessWidget {
  final String uId;
  MyApp(this.uId);

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (BuildContext context) => AuthCubit()),
        BlocProvider<ChatCubit>(
          create: (BuildContext context) => ChatCubit()
            ..getUser()
            ..getAllPosts()
            ..getAllUsers(),
        ),
      ],
      child: MaterialApp(
        title: 'Social App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: (uId == null || uId == '') ? LogInScreen() : Home(),
      ),
    );
  }
}
