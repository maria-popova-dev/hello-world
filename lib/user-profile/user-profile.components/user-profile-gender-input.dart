import 'package:flutter/material.dart';

import '../user-profile.enums.dart';

class UserProfileGenderInput extends StatelessWidget {

  final Gender? selectedGender;
  final Function(Gender)? onChanged;

  const UserProfileGenderInput ({super.key, this.selectedGender, this.onChanged});

  void _handleGenderSelection(Gender? currentSelectedGender){
    if (onChanged != null && currentSelectedGender != null){
      onChanged!(currentSelectedGender);
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget radioButton(String label, Gender value) {
      return Expanded(
        child: ListTile(
          title: Text(label),
          horizontalTitleGap: 0.0,
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Radio<Gender>(
            value: value,
            groupValue: selectedGender,
            onChanged: _handleGenderSelection,
          ),
        ),
      );
    }
    return  Row(
      children: [
        const SizedBox(
            width: 100.0,
            child: Text("Gender")),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              radioButton('Female', Gender.female),
              radioButton('Male', Gender.male),
            ],
          ),
        ),
      ],
    );
  }
}



