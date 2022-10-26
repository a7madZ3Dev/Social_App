import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import '../../shared/cubit/cubit.dart';
import '../../modules/login/login.dart';
import '../../shared/cubit/states.dart';
import '../../shared/components/components.dart';

final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

class RegisterScreen extends StatelessWidget {
  late String email;
  late String password;
  late String phone;
  late String name;

  @override
  Widget build(BuildContext context) {
    AuthCubit authCubit = AuthCubit.get(context);
    return BlocConsumer<AuthCubit, AuthStates>(listener: (context, state) {
      if (state is CreateUserSuccessState) {
        // showToast(
        //   text: 'Registered successfully',
        //   state: ToastStates.SUCCESS,
        // );
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: registerFormKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGISTER',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      'Register now to communicate with friends',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 30.0),
                    defaultFormField(
                      type: TextInputType.name,
                      validate: (String? value) {
                        if (value!.isEmpty) {
                          return 'Name field must not be empty';
                        }
                        return null;
                      },
                      label: 'Name',
                      prefix: Icons.person,
                      onSaved: (String? value) {
                        if (value != null) name = value;
                      },
                    ),
                    SizedBox(height: 15.0),
                    defaultFormField(
                      type: TextInputType.phone,
                      validate: (String? value) {
                        if (value!.isEmpty) {
                          return 'Phone field must not be empty';
                        }
                        return null;
                      },
                      label: 'Phone',
                      prefix: Icons.phone_android_rounded,
                      onSaved: (String? value) {
                        if (value != null) phone = value;
                      },
                    ),
                    SizedBox(height: 15.0),
                    defaultFormField(
                      type: TextInputType.emailAddress,
                      validate: (String? value) {
                        if (value!.isEmpty) {
                          return 'Email field must not be empty';
                        }
                        return null;
                      },
                      label: 'Email Address',
                      prefix: Icons.email_outlined,
                      onSaved: (String? value) {
                        if (value != null) email = value;
                      },
                    ),
                    SizedBox(height: 15.0),
                    defaultFormField(
                        type: TextInputType.visiblePassword,
                        isPassword: authCubit.isPassword,
                        textInputAction: TextInputAction.done,
                        suffix: authCubit.isPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixPressed: () {
                          authCubit.changeState();
                        },
                        validate: (String? value) {
                          if (value!.isEmpty) {
                            return 'Password field must not be empty';
                          }
                          return null;
                        },
                        label: 'Password',
                        prefix: Icons.lock_open_outlined,
                        onSaved: (String? value) {
                          if (value != null) password = value;
                        },
                        onSubmit: (value) {
                          if (registerFormKey.currentState!.validate()) {
                            registerFormKey.currentState!.save();
                            authCubit.userRegister(
                                context, email, password, phone, name);
                          }
                        }),
                    SizedBox(height: 15.0),
                    ConditionalBuilder(
                      condition: state is! RegisterLoadingState,
                      builder: (BuildContext context) => defaultButton(
                        function: () {
                          if (registerFormKey.currentState!.validate()) {
                            registerFormKey.currentState!.save();
                            authCubit.userRegister(
                                context, email, password, phone, name);
                          }
                        },
                        text: 'REGISTER',
                        background: Theme.of(context).primaryColor,
                      ),
                      fallback: (BuildContext context) => Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Have an account ?',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        defaultTextButton(
                            label: 'Log in',
                            onPressed: () {
                              navigateAndReplacement(
                                context,
                                LogInScreen(),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
