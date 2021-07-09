import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder/conditional_builder.dart';

import '../../models/user/user.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../modules/chat_details/chat_details.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatStates>(
        listener: (BuildContext context, ChatStates state) {},
        builder: (BuildContext context, ChatStates state) {
          ChatCubit chatCubit = ChatCubit.get(context);

          return ConditionalBuilder(
            condition:
                chatCubit.users.length > 0 && chatCubit.userFireBase != null,
            fallback: (context) => Center(child: CircularProgressIndicator()),
            builder: (context) => ListView.separated(
              physics: BouncingScrollPhysics(),
              itemCount: chatCubit.users.length,
              itemBuilder: (BuildContext context, int index) =>
                  buildChatItem(context, chatCubit.users[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  myDivider(),
            ),
          );
        });
  }
}

Widget buildChatItem(BuildContext context, UserFireBase userFireBase) {
  return InkWell(
    onTap: () {
      navigateTo(
          context,
          ChatsDetailsScreen(
            receiverUser: userFireBase,
          ));
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: CircleAvatar(
              radius: 28.0,
              backgroundImage: NetworkImage(
                userFireBase.image!,
              ),
            ),
          ),
          Expanded(
            child: Text(
              userFireBase.name.toString(),
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
