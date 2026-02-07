import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:instagram_clone/app_routes.dart';
import 'package:instagram_clone/auth/auth.components/signup_screen_wrapper.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';
import 'package:instagram_clone/app.components/text_input_field.dart';
import 'package:provider/provider.dart';

class SignupEmailOtpScreen extends StatefulWidget {
  const SignupEmailOtpScreen({super.key});

  @override
  State<SignupEmailOtpScreen> createState() => _SignupEmailOtpScreenState();
}

class _SignupEmailOtpScreenState extends State<SignupEmailOtpScreen> {
  final TextEditingController _signupOtpController = TextEditingController();

  String? _errorMessage;
  late String _generatedOtp;

  String  _generateOtp() {
    Random random = Random();
    String otp = "";

    for(int i = 0; i<6; i++){
      String randomNumberString = random.nextInt(10).toString();
      otp = otp + randomNumberString;
    }
    return otp;
  }

  Future<void> _sendEmailWithOtp(String email, String otp) async{
    try {
      final emailResponse = await http.post(
          Uri.parse(
              "https://pwt3i3mzcm.us-east-1.awsapprunner.com/api/v1/email/test"),
          headers: {
            "Content-Type": "application/json",
            "apiKey": "G3WM69SDmhCYkEZw2Ty7sn"
          },
          body: jsonEncode({
            "fromName": "Instagram Clone",
            "subject": "Email verification OTP",
            "toEmail": email,
            "bodyText": "Your OTP for verification is $otp"
          })
      );
      if(emailResponse.statusCode != 200){
        setState(() {
          _errorMessage = "Failed to send OTP email";
        });
      }
    } catch(error) {
      setState(() {
        _errorMessage = "A server error has occurred";
      });
    }
  }

@override
void initState(){
    super.initState();
    _generatedOtp = _generateOtp();
    final email = context.read<UserProfileProvider>().email;

    if(email == null){
      Navigator.pop(context);
    }

    if (email != null){
      _sendEmailWithOtp(email, _generatedOtp);
    }
}


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Provider(
          create: (context) => UserProfileProvider(),
          child: SignupScreenWrapper(
              headerText: "Enter the OTP sent to your email",
              description: "An OTP has been sent to your email. Enter it here to verify your email.",
              errorMessage: _errorMessage,
              textInputField: TextInputField(
                  textEditingController: _signupOtpController,
                  label: "OTP", textInputType: TextInputType.number
              ),
              inputLabel: "Email",
              onNextButtonPressed: () {
                final enteredOtp = _signupOtpController.text.trim();

                if(enteredOtp.isEmpty){
                  setState(() {
                    _errorMessage = "OTP is required";
                  });
                  return;
                }

                if(enteredOtp == _generatedOtp){
                  Navigator.pushNamed(context, AppRoutes.signupPassword);
                } else {
                  setState(() {
                    _errorMessage = "Invalid OTP";
                  });
                }
              }
          ),
        ),
      ),
    );
  }
}
