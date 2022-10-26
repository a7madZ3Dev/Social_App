import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../shared/styles/styles/icon_broken.dart';

class ProfileScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatStates>(
        listener: (BuildContext context, ChatStates state) {
      if (state is ChatUpdateProfileSuccessState)
        showToast(text: 'Update Done', state: ToastStates.SUCCESS);
    }, builder: (BuildContext context, ChatStates state) {
      ChatCubit chatCubit = ChatCubit.get(context);

      return Scaffold(
          appBar: appBar(
            leading: true,
            actions: false,
            automaticallyImplyLeading: false,
            title: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).pop();
              chatCubit.profileImage = null;
              chatCubit.coverImage = null;
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state is ChatUpdateProfileLoadingState)
                      Padding(
                        key: UniqueKey(),
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: LinearProgressIndicator(),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 60.0,
                      ),
                      child: Stack(
                        alignment:
                            Alignment.topRight, // for the iconButton on image
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 150.0,
                            width: double.infinity,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: chatCubit.coverImage != null
                                    ? FileImage(chatCubit.coverImage!)
                                        as ImageProvider
                                    : NetworkImage(
                                        chatCubit.userFireBase!.cover!,
                                      ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              chatCubit.takeImage(image: 'cover');
                            },
                            icon: Icon(
                              IconBroken.Camera,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: -52.0,
                            left: MediaQuery.of(context).size.width / 2 - 60,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 52.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      chatCubit.takeImage(image: 'profile');
                                    },
                                    child: CircleAvatar(
                                      radius: 48.0,
                                      backgroundImage: chatCubit.profileImage !=
                                              null
                                          ? FileImage(chatCubit.profileImage!)
                                              as ImageProvider
                                          : NetworkImage(
                                              chatCubit.userFireBase!.image!,
                                            ),
                                    ),
                                  ),
                                  Icon(
                                    IconBroken.Camera,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 5.0,
                      ),
                      child: defaultFormField(
                          type: TextInputType.text,
                          label: 'Name',
                          validate: (String? value) {
                            if (value!.trim().isEmpty) {
                              return 'Name field must not be empty';
                            }
                            return null;
                          },
                          initialValue: chatCubit.userFireBase!.name,
                          prefix: IconBroken.Profile,
                          onSaved: (String? value) {
                            if (value != null) chatCubit.name = value;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 5.0,
                      ),
                      child: defaultFormField(
                          type: TextInputType.phone,
                          label: 'Phone',
                          validate: (String? value) {
                            if (value!.trim().isEmpty) {
                              return 'Phone field must not be empty';
                            }
                            return null;
                          },
                          initialValue: chatCubit.userFireBase!.phone,
                          prefix: IconBroken.Call,
                          onSaved: (String? value) {
                            if (value != null) chatCubit.phone = value;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 5.0,
                      ),
                      child: defaultFormField(
                          type: TextInputType.name,
                          label: 'Bio',
                          validate: (String? value) {
                            if (value!.trim().isEmpty) {
                              return 'bio field must not be empty';
                            }
                            return null;
                          },
                          initialValue: chatCubit.userFireBase!.bio,
                          textInputAction: TextInputAction.done,
                          prefix: IconBroken.Info_Circle,
                          onSaved: (value) {
                            if (value != null) chatCubit.bio = value;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      child: defaultButton(
                        function: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            chatCubit.updateProfile(context);
                          }
                        },
                        text: 'Update',
                        width: MediaQuery.of(context).size.width,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
    });
  }
}
