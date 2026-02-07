import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram_clone/app.components/media-thumbnail.dart';
import 'package:instagram_clone/auth/auth.service.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/posts/post.service.dart';
import 'package:instagram_clone/user-profile/user-page-screen.dart';
import 'package:instagram_clone/user-profile/user-profile.dart';
import 'package:instagram_clone/user-profile/user-profile.service.dart';
import '../app.components/app_bottom_navigation_bar.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final UserProfileService userProfileService = UserProfileService();
  final PostService postService = PostService();
  final AuthService authService = AuthService();
  final TextEditingController _searchController =TextEditingController();

  final int currentScreenIndex =1;
  List<UserProfile> _userProfiles = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    _getUserProfile();
    super.initState();
  }

  Future<void> _getUserProfile() async{
    try{
      UserProfile? currentUserProfile = await userProfileService.getUserProfile(authService.currentFirebaseUser!.uid);
      if(currentUserProfile != null) {
        setState(() {
          _currentUserProfile = currentUserProfile;
        });
      }
    }catch (error){
      rethrow;
    }
  }

  Future<void> _handleUserSearch(String searchText) async{
    if(searchText.isEmpty) {
setState(() {
  _userProfiles = [];
});
return;
    }
    setState(() {
      _isLoading = true;
    });

    try{
      final userProfilesResult = await userProfileService.getUsersByUserNameSearch(searchText);
      setState(() {
        _userProfiles = userProfilesResult;
        _isLoading = false;
      });

    }catch(error) {
      setState(() {
        _userProfiles = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide.none),
                    hintText: "Search by username...",
                    filled: true,
                    fillColor: Colors.black12
                  ),
                  onChanged: (searchText){
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(microseconds: 500), () {
                      _handleUserSearch(searchText);
                    });
                  },
                ),
              ),

if(_isLoading)
  const CircularProgressIndicator(strokeWidth: 2.0,),

if(!_isLoading && _searchController.text.isNotEmpty && _userProfiles.isEmpty)
  const Text("User not found"),

if(_searchController.text.isNotEmpty)
  Expanded(child: ListView.builder(
      itemCount: _userProfiles.length,
      itemBuilder: (context, index) {
        final userProfile = _userProfiles[index];

        return InkWell(
          onTap: () =>  Navigator.push(context, MaterialPageRoute(
              builder: (context) => UserPageScreen(
                currentScreenIndex: currentScreenIndex,
                userId: userProfile.uid,
                userName: userProfile.userName,))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userProfile.avatar),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(userProfile.userName, style: const TextStyle(fontSize: 12.0))
              ],
            ),
          ),
        );
      }
  )
  ),

if(_searchController.text.isEmpty)
              Expanded(
                child: StreamBuilder<List<Post>>(
                  stream: postService.getPosts(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<Post> posts = snapshot.data ?? [];

                    List<UserPostMedia> allUserPostMedia = posts.asMap().entries.expand((postEntry) =>
                    postEntry.value.media.asMap().entries.map((mediaEntry) => UserPostMedia(
                        userId: posts[postEntry.key].userId,
                        media: mediaEntry.value,
                        mediaIndex:mediaEntry.key
                    ))
                    ).toList();


                    return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1
                        ),
                      itemCount: allUserPostMedia.length,
                      itemBuilder: (context, index){
                        UserPostMedia userPostMedia = allUserPostMedia [index];
                          return MediaThumbnail(currentUserId: _currentUserProfile!.uid, currentUserFollowing: _currentUserProfile!.followers,  userPostMedia: userPostMedia, currentScreenIndex: currentScreenIndex,);
                      },
                    );
                  },
                ),
              )
            ],
          )),
      bottomNavigationBar:  AppBottomNavigationBar(currentIndex: currentScreenIndex,),
    );
  }
}
