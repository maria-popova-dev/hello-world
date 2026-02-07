import 'package:flutter/material.dart';
import 'package:instagram_clone/app.components/app_bottom_navigation_bar.dart';
import 'package:instagram_clone/auth/auth.service.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:instagram_clone/posts/post.service.dart';
import 'package:instagram_clone/user-profile/user-profile.dart';
import 'package:instagram_clone/user-profile/user-profile.enums.dart';
import 'package:instagram_clone/user-profile/user-profile.service.dart';
import '../app.components/app_follow_button.dart';
import '../app.components/media-thumbnail.dart';
import '../home/media.dart';

class UserPageScreen extends StatefulWidget {
  final int currentScreenIndex;
  final String userId;
  final String userName;

  const UserPageScreen({
    super.key,
    required this.currentScreenIndex,
    required this.userId,
    required this.userName
  });

  @override
  State<UserPageScreen> createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  final UserProfileService userProfileService = UserProfileService();
  final PostService postService = PostService();
  final AuthService authService = AuthService();

  bool _isLoadingUserProfile = true;
  UserProfile? _userProfile;
  UserProfile? _currentUserProfile;
  UserPostMediaTab activeTab = UserPostMediaTab.all;
  List<UserPostMedia> tabUserPostMediaList = [];

  @override
  void initState() {
    _getUserProfiles();
    super.initState();
  }

  Future<void> _getUserProfiles() async{
    try{
      UserProfile? userProfile = await userProfileService.getUserProfile(widget.userId);
      UserProfile? currentUserProfile = await userProfileService.getUserProfile(authService.currentFirebaseUser!.uid);
      if(userProfile != null) {
        setState(() {
          _isLoadingUserProfile = false;
          _userProfile = userProfile;
          _currentUserProfile = currentUserProfile;
        });
      }
    }catch (error){
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.userName, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
        actions: [
          if(_currentUserProfile != null && _userProfile != null)
          Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: AppFollowButton(
            currentUserId: _currentUserProfile!.uid,
            followedUserId: widget.userId,
            isCurrentlyFollowing: _currentUserProfile!.following.contains(widget.userId),
            color: Colors.black,)
          )
        ],
      ),
      
      body: SafeArea(
        child: Column(
        children: [
          if (_isLoadingUserProfile)
          const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          if(!_isLoadingUserProfile  && _userProfile != null)
         Expanded(
           child: Column(
             children: [
             UserPageHeader(userProfile: _userProfile!),
               Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black12),
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              child:  Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TabButton(icon: Icons.grid_on_outlined, active: activeTab == UserPostMediaTab.all, onTap: (){
                      setState(() {
                        activeTab = UserPostMediaTab.all;
                      });
                    }),
                    const SizedBox(width: 100.0,),
                    TabButton(icon: Icons.video_collection_outlined, active: activeTab == UserPostMediaTab.video, onTap: (){
                      setState(() {
                        activeTab = UserPostMediaTab.video;
                      });
                    }),
                    const SizedBox(width: 100.0,),
                    TabButton(icon: Icons.image_outlined, active: activeTab == UserPostMediaTab.image, onTap: (){
                      setState(() {
                        activeTab = UserPostMediaTab.image;
                      });
                    }),
                  ],
                ),
              ),
            ),

             Expanded(
               child: StreamBuilder<List<Post>>(
                 stream: postService.getPostsByUserId(_userProfile!.uid),
                 builder: (context, snapshot) {
                   if(snapshot.connectionState == ConnectionState.waiting){
                     return const Center(child: CircularProgressIndicator());
                   }

                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
                     return const Center(child: Text('No posts found'));
                   }

                   final posts = snapshot.data!;

                   List<UserPostMedia> allUserPostMedia = posts.asMap().entries.expand((postEntry) =>
                       postEntry.value.media.asMap().entries.map((mediaEntry) => UserPostMedia(
                           userId: posts[postEntry.key].userId,
                           media: mediaEntry.value,
                           mediaIndex:mediaEntry.key
                       ))
                   ).toList();

                   //final allMedia = posts.expand((post) => post.media).toList();

                   if (allUserPostMedia.isEmpty) {
                     return const Center(child: Text('No media found'));
                   }

                   if(activeTab == UserPostMediaTab.all){
                     tabUserPostMediaList = allUserPostMedia;
                   }

                   if(activeTab == UserPostMediaTab.video){
                     tabUserPostMediaList = allUserPostMedia.where((userPostMedia) => userPostMedia.media.type == MediaType.video).toList();
                   }

                   if(activeTab == UserPostMediaTab.image){
                     tabUserPostMediaList = allUserPostMedia.where((userPostMedia) => userPostMedia.media.type == MediaType.image).toList();
                   }

                   return GridView.builder(
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 3,
                         mainAxisSpacing: 1,
                         crossAxisSpacing: 1
                     ),
                     itemCount: tabUserPostMediaList.length,
                     itemBuilder: (context, index){
                       UserPostMedia userPostMedia = tabUserPostMediaList [index];
                       return MediaThumbnail(
                         currentUserId: _currentUserProfile!.uid,
                         currentUserFollowing: _currentUserProfile!.followers,
                         userPostMedia: userPostMedia,
                         currentScreenIndex: widget.currentScreenIndex,);
                     },
                   );
                 },
               ),
             ),

                   ],
                 ),
         ),
      ],
      ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: widget.currentScreenIndex),
    );
  }
}

class UserPageHeader extends StatelessWidget {
  final UserProfile userProfile;
  const UserPageHeader({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userProfile.avatar),
                ),
              ),
              const SizedBox(
                width: 56.0,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserStatistics(value: userProfile.totalPosts ?? 0, label: "Posts"),
                    UserStatistics(value: userProfile.totalFollowers ?? 0, label: "Followers"),
                    UserStatistics(value: userProfile.totalFollowing ?? 0, label: "Following"),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.userName,
                style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),),
              if(userProfile.bio != null && userProfile.bio!.isNotEmpty)
                Text(userProfile.bio!, style: const TextStyle(fontSize: 12.0, color: Colors.black54),),
            ],
          ),
        ],
      ),
    );
  }
}

class UserStatistics extends StatelessWidget {
  final int value;
  final String label;

  const UserStatistics({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
        Text(
          label,
          style: const TextStyle(fontSize: 10.0),)
      ],
    );
  }
}

class TabButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const TabButton({super.key, required this.icon, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: active ? Colors.black : Colors.black26,),
    );
  }
}
