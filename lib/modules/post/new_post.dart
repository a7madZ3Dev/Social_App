import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/styles/icon_broken.dart';

class NewPostScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? postContent;

  @override
  Widget build(BuildContext context) {
    ChatCubit chatCubit = ChatCubit.get(context);
    return BlocConsumer<ChatCubit, ChatStates>(
      listener: (BuildContext context, ChatStates state) {
        if (state is ChatNewPostSuccessState) {
          postContent = null;
          Navigator.of(context).pop();
        }
      },
      builder: (BuildContext context, ChatStates state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: appBar(
            leading: true,
            actions: true,
            automaticallyImplyLeading: false,
            onPressed: () {
              Navigator.of(context).pop();
              chatCubit.deleteImage();
              postContent = null;
            },
            actionsList: [
              defaultTextButton(
                onPressed: () {
                  formKey.currentState!.save();
                  chatCubit.addPost(context, postContent);
                },
                label: 'Post',
              ),
            ],
          ),
          body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is ChatNewPostLoadingState)
                      Padding(
                        key: UniqueKey(),
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: LinearProgressIndicator(),
                      ),
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0.0),
                          child: CircleAvatar(
                            radius: 28.0,
                            backgroundImage: NetworkImage(
                              chatCubit.userFireBase!.image!,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatCubit.userFireBase!.name!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                      height: 1.3,
                                    ),
                              ),
                              Text(
                                'public',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty)
                          postContent = value;
                      },
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            "What is on your mind ${chatCubit.userFireBase!.name} ?",
                      ),
                    ),
                    if (chatCubit.postImage != null)
                      Stack(
                        alignment:
                            Alignment.topRight, // for the iconButton on image
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 150.0,
                            width: double.infinity,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: FileImage(chatCubit.postImage!),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () {
                                chatCubit.deleteImage();
                              },
                              icon: Icon(
                                IconBroken.Delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                chatCubit.takeImage(image: 'post');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Icon(
                                      IconBroken.Image,
                                      color: Theme.of(context).primaryColor,
                                      size: 20.0,
                                    ),
                                  ),
                                  Text(
                                    'add photos',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: defaultTextButton(
                                label: '# tags',
                                isUpperCase: false,
                                onPressed: () {},
                                ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}
