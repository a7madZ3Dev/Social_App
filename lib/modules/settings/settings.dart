import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../models/user/user.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../modules/profile/profile.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/styles/icon_broken.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatStates>(
      listener: (BuildContext context, ChatStates state) {},
      builder: (BuildContext context, ChatStates state) {
        UserFireBase userFireBase = ChatCubit.get(context).userFireBase!;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 55.0,
                ),
                child: Stack(
                  // overflow: Overflow.visible,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0),
                        ),
                      ),
                      child: Image.network(
                        userFireBase.cover!,
                        fit: BoxFit.cover,
                        height: 150.0,
                        width: double.infinity,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            height: 150.0,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -52.0,
                      left: MediaQuery.of(context).size.width / 2 - 60,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 52.0,
                        child: CircleAvatar(
                          radius: 48.0,
                          backgroundImage: NetworkImage(
                            userFireBase.image!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                userFireBase.name!.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                userFireBase.bio!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '101',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Text(
                              'Posts',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '20',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Text(
                              'Photos',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '700',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Text(
                              'Follower',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              '1k',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Text(
                              'Followings',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return EdgeInsets.all(8.0);
                          }
                          return EdgeInsets.all(8.0);
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.blue;
                          }
                          return Colors.white;
                        }),
                        overlayColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.grey.shade100;
                          }
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        navigateTo(context, ProfileScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Update',
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Icon(
                            IconBroken.Edit,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await FirebaseMessaging.instance
                            .subscribeToTopic('announcements');
                        showToast(
                          text: 'subscribed successfully',
                          state: ToastStates.SUCCESS,
                        );
                      },
                      child: Text(
                        'subscribe',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.blue;
                          }
                          return Colors.black12;
                        }),
                      ),
                      onPressed: () async {
                        await FirebaseMessaging.instance
                            .unsubscribeFromTopic('announcements');
                        showToast(
                          text: 'unsubscribed successfully',
                          state: ToastStates.SUCCESS,
                        );
                      },
                      child: Text(
                        'unsubscribe',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
