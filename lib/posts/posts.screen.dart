import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/posts/post.service.dart';
import 'package:instagram_clone/user-profile/user-profile.provider.dart';

import 'dart:io';
import 'package:mime/mime.dart';

import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/home/media.dart';
import 'package:instagram_clone/posts/post.dart';
import 'package:provider/provider.dart';


import '../home/home.components/home-media-slider.dart';
import '../services/location_service.dart';

const localFileIdentifier = "loc:";

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {

  final PostService _postService = PostService();
  final ImagePicker picker = ImagePicker();
  final TextEditingController _captionTextEditingController = TextEditingController();
  List<NewPostMedia> _newPostMediaList = [];
  bool _isLoading = false;
  Map<String, dynamic>? _selectedLocation;
  bool _isLoadingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
     try {
     final location = await LocationService.getLocationWithAddress();
     setState(() {
       _selectedLocation = location;
       _isLoadingLocation = false;
     });
     if (location != null) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
         content: Text('📍 ${location['address']}'),
         duration: const Duration(seconds: 2),
     ),
    );
     }
     } catch (e) {
       setState(() => _isLoadingLocation = false);
       print('Ошибка геолокации: $e');
     }
  }
  // ДОБАВЬ МЕТОД ДЛЯ УДАЛЕНИЯ ↓↓↓
  void _removeLocation() {
    setState(() => _selectedLocation = null);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Локация удалена'),
            duration: Duration(seconds: 1),
        ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_newPostMediaList.isEmpty) {
      _openMediaPicker();
    }
  }

  Future<void> _openMediaPicker() async {
    try {
      final List<XFile> files = await picker.pickMultipleMedia();

      if (files.isEmpty) {
        return;
      }

      List<NewPostMedia?> selectedPostMediaList = files.map((xFile) {
        String? mimeType = lookupMimeType(xFile.path);
        if (mimeType == null) {
          return null;
        }

        MediaType? fileMediaType;

        bool isVideo = mimeType.startsWith("video/");
        bool isImage = mimeType.startsWith("image/");

        if (isVideo) {
          fileMediaType = MediaType.video;
        }

        if (isImage) {
          fileMediaType = MediaType.image;
        }

        if (fileMediaType == null) {
          return null;
        }

        return NewPostMedia(
          file: File(xFile.path),
          mediaType: fileMediaType,
        );
      }).toList();

      List<NewPostMedia> nonNullSelectedPostMediaList =
      selectedPostMediaList.whereType<NewPostMedia>().toList();

      setState(() {
        _newPostMediaList = nonNullSelectedPostMediaList;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _createNewPost(String userId) async {
    final caption = _captionTextEditingController.text;

    if(caption.isEmpty) {
      return;
    }

    if(_newPostMediaList.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    DocumentReference? newPostDocRef = await _postService.createPost(
        userId: userId, 
        caption: caption, 
        newPostMediaList: _newPostMediaList,
        location: _selectedLocation,
    
    );

    if(newPostDocRef == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if(mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "New post",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Center(
                  child: InkWell(
                    onTap: _openMediaPicker,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: _newPostMediaList.isEmpty
                          ? Container(
                        color: Colors.black12,
                        height:
                        MediaQuery.of(context).size.height * 0.5,
                        child:
                        const Center(child: Text("Add media")),
                      )
                          : HomeMediaSlider(
                        height:
                        MediaQuery.of(context).size.height * 0.5,
                        mediaList: _newPostMediaList
                            .map(
                              (newPostMedia) => Media(
                            value:
                            '$localFileIdentifier${newPostMedia.file.path}',
                            type: newPostMedia.mediaType,
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _captionTextEditingController,
              decoration: const InputDecoration(
                hintText: "Add a caption",
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 12.0),
            ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            leading: Icon(Icons.location_on,
            color: _selectedLocation != null ? Colors.blue : Colors.grey,),
            title: _isLoadingLocation ? const Text("Определение местоположения...",
            style: TextStyle(color: Colors.grey, fontSize: 14.0),
            )
                : _selectedLocation != null
                ? Text(_selectedLocation! ['address'] ?? 'Местоположение',
            style: const TextStyle(fontSize: 14),)
                :const Text('Добавить местоположение',
            style: TextStyle(fontSize: 14),
            ),
              trailing: _selectedLocation != null ? IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _removeLocation,
                color: Colors.red,
              )
                  : null,
              onTap: _getCurrentLocation,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 12.0),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12))
              ),
              child: _isLoading
                  ? const Center (child: CircularProgressIndicator(strokeWidth: 4.0))
                  : FilledButton(
                onPressed: ()=> {
                  if(userProfile?.uid != null) {
                    _createNewPost(userProfile!.uid)
                  }
                },
                child: const Text("Share"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






