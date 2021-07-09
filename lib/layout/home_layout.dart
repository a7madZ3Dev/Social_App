import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conditional_builder/conditional_builder.dart';

import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';
import '../../modules/login/login.dart';
import '../../modules/post/new_post.dart';
import '../shared/components/components.dart';
import '../shared/styles/styles/icon_broken.dart';
import '../../shared/network/local/cache_helper.dart';
import '../../modules/notifications/notifications.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// for know is keyboard is open or not to choise either build floatingButton or not
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return BlocConsumer<ChatCubit, ChatStates>(
      listener: (BuildContext context, ChatStates state) {},
      builder: (BuildContext context, ChatStates state) {
        ChatCubit chatCubit = ChatCubit.get(context);

        /// when click on notification to open app
        
        // FirebaseMessaging.onMessageOpenedApp.listen((event) {
        //   print('on message opened app');
        //   print(event.data.toString());
        //   // showToast(
        //   //   text: 'on message opened app',
        //   //   state: ToastStates.SUCCESS,
        //   // );
        //   chatCubit.changeIndex(3);
        // });

        return Scaffold(
          /// not work to avoid pop up floatingButton
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title:
                Text(chatCubit.screens[chatCubit.selectedPageIndex]['title']),
            centerTitle: false,
            titleSpacing: 10.0,
            actions: [
              IconButton(
                onPressed: () {
                  navigateTo(context, NotificationsScreen());
                },
                icon: Icon(IconBroken.Notification),
              ),
              IconButton(
                onPressed: () async {
                  chatCubit.users.clear();
                  await FirebaseAuth.instance.signOut();
                  navigateAndFinish(context, LogInScreen());
                  CacheHelper.deleteData();
                },
                icon: Icon(IconBroken.Logout),
              ),
            ],
          ),
          body: ConditionalBuilder(
            condition: state is! ChatGetUserLoadingState,
            builder: (BuildContext ctx) {
              return chatCubit.screens[chatCubit.selectedPageIndex]['screen'];
            },
            fallback: (BuildContext context) => Center(
              child: CircularProgressIndicator(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: chatCubit.changeIndex,
            currentIndex: chatCubit.selectedPageIndex,
            items: chatCubit.getBottomNavBarList(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton:
              keyboardIsOpened || chatCubit.selectedPageIndex == 1 ? null : FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        navigateTo(context, NewPostScreen());
                      },
                      child: Icon(IconBroken.Plus),
                      tooltip: 'add',
                    ),
        );
      },
    );
  }
}



/// for send message for verified

// if (!FirebaseAuth.instance.currentUser!.emailVerified)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       color: Colors.grey.withOpacity(0.3),
//                       height: 50.0,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: Icon(Icons.info_outline),
//                           ),
//                           Expanded(
//                             child: Text(
//                               'Please verify your email !',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 17.0,
//                               ),
//                             ),
//                           ),
//                           // Spacer(),
//                           SizedBox(
//                             width: 10.0,
//                           ),
//                           defaultTextButton(
//                             onPressed: () async {
//                               await FirebaseAuth.instance.currentUser
//                                   ?.sendEmailVerification()
//                                   .then((value) {
//                                 showToast(
//                                     text: 'check your email',
//                                     state: ToastStates.SUCCESS);
//                               }).catchError((error) {
//                                 ScaffoldMessenger.of(ctx).showSnackBar(
//                                   SnackBar(
//                                     content: Text(error.message,
//                                         textAlign: TextAlign.center),
//                                     backgroundColor: Theme.of(ctx).primaryColor,
//                                   ),
//                                 );
//                                 print(error.toString());
//                               });
//                             },
//                             label: 'send',
//                           ),
//                         ],
//                       ),
//                     )
