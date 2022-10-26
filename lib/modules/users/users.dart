import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import '../../models/user/user.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../modules/chat_details/chat_details.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatCubit chatCubit = ChatCubit.get(context);
    return BlocConsumer<ChatCubit, ChatStates>(
      listener: (BuildContext context, ChatStates state) {},
      builder: (BuildContext context, ChatStates state) => ConditionalBuilder(
        condition: chatCubit.users.length > 0,
        fallback: (context) => Center(child: Text('No Users yet!')),
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return buildUserItem(context, chatCubit.users[index]);
            },
            separatorBuilder: (BuildContext context, int index) => myDivider(),
            itemCount: chatCubit.users.length,
          ),
        ),
      ),
    );
  }
}

Widget buildUserItem(BuildContext context, UserFireBase user) {
  return InkWell(
    onTap: (() => navigateTo(
          context,
          ChatsDetailsScreen(
            receiverUser: user,
          ),
        )),
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        backgroundImage: NetworkImage(
          user.image!,
        ),
      ),
      horizontalTitleGap: 8.0,
      title: Text(
        user.name!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: EdgeInsets.all(0.0),
    ),
  );
}
