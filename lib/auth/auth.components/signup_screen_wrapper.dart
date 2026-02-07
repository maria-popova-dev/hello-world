import 'package:flutter/material.dart';
import 'package:instagram_clone/auth/auth.components/auth_screen_padding.dart';
import 'package:instagram_clone/app.components/text_input_field.dart';
import 'package:instagram_clone/auth/auth.constants.dart';

class SignupScreenWrapper extends StatelessWidget {

  final String headerText;
  final String description;
  final String inputLabel;
  final TextInputField textInputField;
  final bool ? emailConfirmationStep;
  final bool loading;
  final String ? errorMessage;
  final void Function() onNextButtonPressed;
  final Function() ? onResendConfirmationCodeButtonPressed;

  const SignupScreenWrapper( {
    required this.headerText,
    required this.description,
    required this.inputLabel,
    required this.textInputField,
    this.emailConfirmationStep = false,
    this.loading = false,
    this.errorMessage,
    required this.onNextButtonPressed,
    this.onResendConfirmationCodeButtonPressed,
  super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenPadding(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                Text(headerText,
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AuthConstants.formGapValue),
                Text(description,
                  style: const TextStyle(fontSize: 12.0),),
                SizedBox(height: AuthConstants.formGapValue),
                textInputField,
                if(errorMessage !=null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                SizedBox(height: AuthConstants.formGapValue),
                loading ?
                const Center(child: CircularProgressIndicator(strokeWidth:4.0,)) :
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: onNextButtonPressed,
                      child: const Text('Next')),
                ),
                SizedBox(
                  height: AuthConstants.formGapValue,
                ),
                if (emailConfirmationStep == true)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: onResendConfirmationCodeButtonPressed,
                        child: const Text("I didn't get the code")),
                  ),
                SizedBox(
                  height: AuthConstants.formGapValue,
                ),
              ],
            ),
            TextButton(onPressed: () => Navigator.popAndPushNamed(context, '/login'),
                child: const Text("Already have an account? Login"))
          ],
        )
    );
  }
  }
