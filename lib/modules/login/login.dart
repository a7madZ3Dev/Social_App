import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder/conditional_builder.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../modules/register/register.dart';
import '../../shared/components/components.dart';

final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();

class LogInScreen extends StatelessWidget {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    AuthCubit authCubit = AuthCubit.get(context);
    return BlocConsumer<AuthCubit, AuthStates>(listener: (context, state) {
      if (state is LogInSuccessState) {
        showToast(
          text: 'LogIn successfully',
          state: ToastStates.SUCCESS,
        );
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: logInFormKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOG IN',
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    Text(
                      'Login now to communicate with friends',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 30.0),
                    defaultFormField(
                      type: TextInputType.emailAddress,
                      validate: (String? value) {
                        if (value!.trim().isEmpty) {
                          return 'Email field must not be empty';
                        }
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
                        suffix: authCubit.isPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixPressed: () {
                          authCubit.changeState();
                        },
                        textInputAction: TextInputAction.done,
                        validate: (String? value) {
                          if (value!.trim().isEmpty) {
                            return 'Password field must not be empty';
                          }
                        },
                        label: 'Password',
                        prefix: Icons.lock_open_outlined,
                        onSaved: (String? value) {
                          if (value != null) password = value;
                        },
                        onSubmit: (value) {
                          if (logInFormKey.currentState!.validate()) {
                            logInFormKey.currentState!.save();
                            authCubit.userLogin(context, email, password);
                          }
                        }),
                    SizedBox(height: 15.0),
                    ConditionalBuilder(
                      condition: state is! LogInLoadingState,
                      builder: (BuildContext context) => defaultButton(
                        function: () {
                          if (logInFormKey.currentState!.validate()) {
                            logInFormKey.currentState!.save();
                            authCubit.userLogin(context, email, password);
                          }
                        },
                        text: 'LOGIN',
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
                          'Don\'t have an account ?',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        defaultTextButton(
                            label: 'Register',
                            onPressed: () {
                              navigateAndReplacement(
                                context,
                                RegisterScreen(),
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
