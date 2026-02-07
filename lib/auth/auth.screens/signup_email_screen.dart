import 'package:flutter/material.dart';
import 'package:instagram_clone/app_routes.dart';
import 'package:instagram_clone/auth/auth.components/signup_screen_wrapper.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';
import 'package:instagram_clone/app.components/text_input_field.dart';
import 'package:provider/provider.dart';

class SignupEmailScreen extends StatefulWidget {
 const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final TextEditingController _signupEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    body: SafeArea(
        child: Provider(
          create: (context) => UserProfileProvider(),
          child: SignupScreenWrapper(
              headerText: "What's your email?",
              description: "Enter the email where you can be contacted. No one will see this on your profile.",
              textInputField: TextInputField(
                textEditingController: _signupEmailController,
                label: "Email", textInputType: TextInputType.emailAddress
              ),
              inputLabel: "Email",
              onNextButtonPressed: () {
                final email = _signupEmailController.text.trim();

                if(email.isNotEmpty){
                  context.read<UserProfileProvider>().setEmail(email);
                  Navigator.pushNamed(context, AppRoutes.signupPassword);
                }
                print("Go to password screen");
              }
                ),
        ),
            ),
    );
  }
}
