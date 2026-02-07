import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/user-profile/user-profile.components/user-profile-gender-input.dart';
import 'package:instagram_clone/user-profile/user-profile.components/user-profile-text-field.dart';
import 'package:instagram_clone/user-profile/user-profile.dart';
import 'package:instagram_clone/user-profile/user-profile.enums.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';
import 'package:instagram_clone/user-profile/user-profile.service.dart';
import 'package:provider/provider.dart';
import '../app.components/app_bottom_navigation_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  final UserProfileService _userProfileService = UserProfileService();

   UserProfile? _userProfile;
   final ImagePicker _profileImagePicker = ImagePicker();

   bool _updatingProfile = false;

  // Text field controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
   Gender? _selectedGender;
   File? _pickedProfileImageFile;

   @override
   void initState(){
     setInitialValues();
     super.initState();
   }

  void setInitialValues() {
    final UserProfile? userProfile = context.read<UserProfileProvider>().userProfile;

    if(userProfile != null){
      _userProfile = userProfile;
      _firstNameController.text = userProfile.firstName ?? "";
      _lastNameController.text = userProfile.lastName ?? "";
      _usernameController.text = userProfile.userName;
      _websiteController.text = userProfile.website ?? "";
      _bioController.text = userProfile.bio ?? "";
      _emailController.text = userProfile.email;
       _phoneNumberController.text = userProfile.phoneNumber ?? "";
      _selectedGender = userProfile.gender;
    }
  }

   Future<void> _uploadProfilePhoto() async {
     try {
       final XFile? pickedProfileImage = await _profileImagePicker.pickImage(source: ImageSource.gallery);
        if(pickedProfileImage == null) return;

        setState(() {
          _pickedProfileImageFile = File(pickedProfileImage.path);
        });

     } catch (error) {
       print(error);
     }
   }

  Future<void> _updateProfile() async {
  if(_userProfile == null){
    return;
  }

  setState(() {
    _updatingProfile = true;
  });

  final userProfileToUpdate = _userProfile!.copyWith(
    firstName: _firstNameController.text,
    lastName: _lastNameController.text,
    userName: _usernameController.text,
    website: _websiteController.text,
    bio: _bioController.text,
    email: _emailController.text,
    phoneNumber: _phoneNumberController.text,
    gender:_selectedGender,
    updatedAt: DateTime.now(),
  );

 UserProfile? updatedUserProfile = await _userProfileService.updateUserProfile(userProfileToUpdate, _pickedProfileImageFile);

 if(updatedUserProfile != null){

   context.read<UserProfileProvider>().setUserProfile(updatedUserProfile);

   setState(() {
     _userProfile = updatedUserProfile;
   });

 }

  setState(() {
    _updatingProfile = false;
  });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed:() => print ("Cancel"), child: const Text("Cancel")),
        leadingWidth: 68.0,
        title: const Text("User Profile", style: TextStyle(fontSize: 16.0)),
        actions: [
          TextButton(onPressed: _updateProfile, child: _updatingProfile ? const CircularProgressIndicator() : const Text ("Done", style: TextStyle (fontWeight:FontWeight.bold )),)
        ],
      ),
      body: SafeArea(child:
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              if(_userProfile == null)
                const Center(child: CircularProgressIndicator(),),
              
              if(_userProfile != null)
            Column(
              children: [
                // Profile Photo Column
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: CircleAvatar(
                          backgroundImage: _pickedProfileImageFile != null ? FileImage(_pickedProfileImageFile!) : NetworkImage(_userProfile!.avatar),
                        ),
                      ),
                      TextButton(onPressed: _uploadProfilePhoto, child: const Text("Change Profile Photo", style: TextStyle(fontWeight: FontWeight.bold),))
                    ],
                  ),
                ),
        
                const Divider(height: 1.0, color: Colors.black12),
        
                // Profile Inputs Column
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserProfileTextField(label: "First Name", controller: _firstNameController,placeholder: "Enter first name",),
                      UserProfileTextField(label: "Last Name",controller: _lastNameController,placeholder: "Enter last name",),
                       UserProfileTextField(label: "Username",controller: _usernameController,placeholder: "Enter username",),
                       UserProfileTextField(label: "Website",controller: _websiteController,placeholder: "www.yoursite.com", keyboardType: TextInputType.url),
                       UserProfileTextField(label: "Bio",controller: _bioController,placeholder: "Enter bio description",),
        
                      const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text("Private Information", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
        
                       UserProfileTextField(label: "Email",controller: _emailController, enabled: false),
                       UserProfileTextField(label: "Phone",controller: _phoneNumberController,placeholder: "Enter phone number",keyboardType: TextInputType.phone,),
                       UserProfileGenderInput(selectedGender: _selectedGender,onChanged: (gender){
                         setState(() {
                           _selectedGender = gender;
                         });
                       },)
                    ],
                  ),
                )
              ],
            ),
          ],
          ),
        ),
      )),
      bottomNavigationBar:  const AppBottomNavigationBar(currentIndex: 4,),
    );
  }
}
