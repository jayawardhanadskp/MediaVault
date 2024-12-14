import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ns/widgets/media_item_widget.dart';
import 'package:uuid/uuid.dart';

class MediaCaptureApp extends StatefulWidget {
  const MediaCaptureApp({super.key});

  @override
  State<MediaCaptureApp> createState() => _MediaCaptureAppState();
}

class _MediaCaptureAppState extends State<MediaCaptureApp> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();
  bool _isLoading = false;

  Future<void> _captureAndUploadMedia(ImageSource source, bool isVideo) async {
    try {
      setState(() => _isLoading = true);

      // Capture media
      final XFile? file = isVideo 
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
          
      if (file != null) {
        // Generate unique ID for the media
        final String mediaId = uuid.v4();
        final String timestamp = DateTime.now().toIso8601String();
        final String fileExtension = isVideo ? '.mp4' : '.jpg';
        final String path = 'media/$mediaId$fileExtension';

        // Upload to Firebase Storage
        final Reference ref = _storage.ref().child(path);
        final UploadTask uploadTask = ref.putFile(File(file.path));

        // Wait for upload to complete and get download URL
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save metadata to Firestore
        await _firestore.collection('media').doc(mediaId).set({
          'id': mediaId,
          'type': isVideo ? 'video' : 'photo',
          'url': downloadUrl,
          'timestamp': timestamp,
          'path': path,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded successfully!')),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to capture or upload media: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedia(String mediaId, String path) async {
    try {
      setState(() => _isLoading = true);
      
      // Delete from Storage
      await _storage.ref().child(path).delete();
      
      // Delete from Firestore
      await _firestore.collection('media').doc(mediaId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media deleted successfully!')),
      );
    } catch (e) {
      _showErrorDialog('Failed to delete media: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Capture buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading 
                          ? null 
                          : () => _captureAndUploadMedia(ImageSource.camera, false),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading 
                          ? null 
                          : () => _captureAndUploadMedia(ImageSource.camera, true),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Record Video'),
                    ),
                  ],
                ),
              ),
              // Media gallery from Firebase
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('media')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No media yet. Use the buttons above to capture photos or videos!',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return FirebaseMediaItem(
                          mediaData: data,
                          onDelete: () => _deleteMedia(data['id'], data['path']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}