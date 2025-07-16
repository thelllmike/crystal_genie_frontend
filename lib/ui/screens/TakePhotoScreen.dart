// lib/ui/screens/take_photo_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import 'result_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({Key? key}) : super(key: key);
  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  late final List<CameraDescription> _cameras;
  CameraController? _controller;
  bool _usingFront = false;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    availableCameras().then((cams) {
      _cameras = cams;
      _restartController();
    });
  }

  Future<void> _restartController() async {
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
      Navigator.of(context).pop(); // hide loader
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultScreen(
          imageFile: File(file.path),
          detections: dets,
        ),
      ));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const frameSize = 380.0, frameLeft = 24.0, frameTop = 128.0;
    final pillW = w - 32.0;

    Widget preview;
    if (_pickedImage != null) {
      preview = Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    } else if (_controller?.value.isInitialized ?? false) {
      preview = CameraPreview(_controller!);
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