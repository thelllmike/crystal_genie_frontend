// lib/ui/screens/take_photo_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import 'result_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({Key? key}) : super(key: key);
  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _usingFront = false;
  bool _noCamera = false;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    availableCameras().then((cams) {
      _cameras = cams;
      if (cams.isEmpty) {
        if (mounted) setState(() => _noCamera = true);
        return;
      }
      _restartController();
    }).catchError((_) {
      if (mounted) setState(() => _noCamera = true);
    });
  }

  Future<void> _restartController() async {
    if (_cameras.isEmpty) return;
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == (_usingFront ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );
    await _controller?.dispose();
    _controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    _usingFront = !_usingFront;
    await _restartController();
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _pickedImage = file);
      await _sendAndNavigate(file);
    }
  }

  Future<void> _takePhoto() async {
    if (_controller?.value.isInitialized ?? false) {
      final photo = await _controller!.takePicture();
      setState(() => _pickedImage = photo);
      await _sendAndNavigate(photo);
    }
  }

  Future<void> _sendAndNavigate(XFile file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final dets = await ApiService().detectCrystal(file.path);
      if (!mounted) return;
      Navigator.of(context).pop(); // hide loader
      if (dets.isEmpty) {
        setState(() => _pickedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No crystal detected — keep it within the frame and try again'),
          ),
        );
        return;
      }
      // Record the find in the user's history (best effort).
      if (AuthService.isLoggedIn) {
        DbService.addFind(
          crystalName: dets.first.className,
          headline: dets.first.description.headline,
        ).catchError((e) => debugPrint('Could not save find: $e'));
      }
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultScreen(
          imageFile: File(file.path),
          detections: dets,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Keep the capture frame inside the screen on narrow devices.
    final frameSize = (w - 48.0).clamp(200.0, 380.0);
    final frameLeft = (w - frameSize) / 2;
    const frameTop = 128.0;
    final pillW = w - 32.0;

    Widget preview;
    if (_pickedImage != null) {
      preview = Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    } else if (_controller?.value.isInitialized ?? false) {
      preview = CameraPreview(_controller!);
    } else if (_noCamera) {
      preview = const Center(
        child: Text(
          'No camera available —\npick a photo from the gallery',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        ),
      );
    } else {
      preview = const Center(child: CircularProgressIndicator());
    }

    Widget overlay() => ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: const Color(0x1AFFFFFF)),
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: Stack(children: [
        Positioned.fill(child: preview),
        Positioned(top: 0, left: 0, right: 0, height: frameTop, child: overlay()),
        Positioned(top: frameTop, left: 0, width: frameLeft, height: frameSize, child: overlay()),
        Positioned(top: frameTop, left: frameLeft + frameSize, right: 0, height: frameSize, child: overlay()),
        Positioned(top: frameTop + frameSize, left: 0, right: 0, bottom: 0, child: overlay()),
        Positioned(
          top: frameTop,
          left: frameLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
              ),
            ),
          ),
        ),

        // Top pill
        Positioned(
          top: 16, left: 16, right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                      color: AppColors.neutral100,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Keep your crystal within the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.0,
                          color: Color(0xFF1A181B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom pill
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: pillW,
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33FBF5F3),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0x80FBF5F3), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedAlbum02),
                      color: AppColors.neutral100,
                      iconSize: 28,
                      onPressed: _pickFromGallery,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_pickedImage != null) {
                          setState(() => _pickedImage = null);
                        } else {
                          _takePhoto();
                        }
                      },
                      child: Image.asset(
                        'assets/icons/takephotobutton.png',
                        width: 64, height: 64,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedExchange01),
                      color: AppColors.neutral100,
                      iconSize: 28,
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}