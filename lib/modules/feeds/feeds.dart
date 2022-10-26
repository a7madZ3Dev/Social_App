import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import '../../shared/cubit/cubit.dart';
import '../../../models/post/post.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/constants.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/styles/icon_broken.dart';

class FeedsScreen extends StatelessWidget {
  final TextEditingController inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatStates>(
        listener: (BuildContext context, ChatStates state) {},
        builder: (BuildContext context, ChatStates state) {
          ChatCubit chatCubit = ChatCubit.get(context);

          return ConditionalBuilder(
            condition: chatCubit.posts.length > 0 &&
                chatCubit.userFireBase != null &&
                chatCubit.likes.length > 0 &&
                chatCubit.comments.length > 0,
            fallback: (context) => Center(child: CircularProgressIndicator()),
            builder: (context) => SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    elevation: 5.0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          kHeader,
                          fit: BoxFit.cover,
                          height: 220.0,
                          width: double.infinity,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              height: 220.0,
                            );
                          },
                        ),
                        Text(
                          'Communicate with friends',
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                        )
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return buildPostItem(context, chatCubit.posts[index],
                          index, chatCubit, state);
                    },
                    itemCount: chatCubit.posts.length,
                    shrinkWrap: true,
                  )
                ],
              ),
            ),
          );
        });
  }
}

Widget buildPostItem(BuildContext context, Post post, int index,
    ChatCubit chatCubit, ChatStates state) {
  final TextEditingController inputController = TextEditingController();

  return Card(
    margin: EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
    elevation: 5.0,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
                child: CircleAvatar(
                  radius: 28.0,
                  backgroundImage: NetworkImage(
                    post.userImage!,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name!,
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    height: 1.3,
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 3.0,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 16.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat.yMMMd().add_Hms().format(post.dateTime!),
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 23.0,
                height: 23.0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'more',
                  onPressed: () {},
                  icon: Icon(
                    IconBroken.More_Circle,
                    size: 23.0,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: myDivider(),
          ),
          if (post.text != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                post.text!,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 5.0),
          //   child: Container(
          //     child: Wrap(
          //       spacing: 5.0,
          //       children: [
          //         defaultHashButton(
          //             label: '#software', isUpperCase: false, onPressed: () {}),
          //       ],
          //     ),
          //   ),
          // ),
          if (post.postImage != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Image.network(
                  post.postImage!,
                  fit: BoxFit.cover,
                  height: 200.0,
                  width: double.infinity,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Container(
                      height: 200.0,
                    );
                  },
                ),
              ),
            ),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Icon(
                        IconBroken.Heart,
                        color: Colors.red,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      chatCubit.likes[index].toString(),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Icon(
                        IconBroken.Chat,
                        color: Colors.amber,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      // '50 comments',
                      '${chatCubit.comments[index]}  comments',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: myDivider(),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 2.0, 12.0, 2.0),
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundImage: NetworkImage(
                    chatCubit.userFireBase!.image!,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 38.0,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    cursorColor: Theme.of(context).primaryColor,
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment ...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.0,
                      ),
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                  onTap: () {
                    chatCubit.addComment(inputController.text, post.postId!);
                    if (state is ChatNewCommentSuccessState)
                      inputController.clear();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(
                          IconBroken.Upload,
                          color: Colors.green,
                          size: 18.0,
                        ),
                      ),
                      Text(
                        'Add',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  chatCubit.doLike(post.postId!);
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(
                        IconBroken.Heart,
                        color: Colors.red,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      'Like',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
