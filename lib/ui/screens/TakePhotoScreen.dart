// lib/ui/screens/take_photo_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/db_service.dart';
import '../widgets/page_transitions.dart';
import 'main_shell.dart';
import 'result_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  /// Whether this tab is the visible one. The shell keeps every tab alive, so
  /// the camera hardware is only opened while [active] is true.
  final bool active;

  const TakePhotoScreen({Key? key, this.active = true}) : super(key: key);
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
    if (widget.active) _startCamera();
  }

  @override
  void didUpdateWidget(TakePhotoScreen old) {
    super.didUpdateWidget(old);
    if (widget.active == old.active) return;
    if (widget.active) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_controller != null) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _noCamera = true);
        return;
      }
      await _restartController();
    } catch (_) {
      if (mounted) setState(() => _noCamera = true);
    }
  }

  /// Releases the camera when the user switches to another tab.
  Future<void> _stopCamera() async {
    final controller = _controller;
    _controller = null;
    if (mounted) setState(() => _pickedImage = null);
    await controller?.dispose();
  }

  Future<void> _restartController() async {
    if (_cameras.isEmpty) return;
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == (_usingFront ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );
    await _controller?.dispose();
    final controller =
        CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    // The user may have left the tab while the hardware was warming up.
    if (!mounted || !widget.active) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
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
      Navigator.of(context).push(SmoothPageRoute(
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

  /// Fills the frame with the camera feed (cover), the picked photo, or a
  /// state message.
  Widget _framePreview() {
    if (_pickedImage != null) {
      return Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    }
    if (_controller?.value.isInitialized ?? false) {
      final size = _controller!.value.previewSize;
      if (size == null) return const ColoredBox(color: Colors.black);
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          // previewSize is landscape-oriented, so swap width/height.
          width: size.height,
          height: size.width,
          child: CameraPreview(_controller!),
        ),
      );
    }
    if (_noCamera) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No camera available —\npick a photo from the gallery',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 15, color: Color(0xFF5E5E5E)),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral20,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Square frame that fits the width but never crowds the controls.
            final frameSize = (constraints.maxWidth - 32)
                .clamp(0.0, constraints.maxHeight * 0.6);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.06),

                  // Top bar: back + title
                  Row(
                    children: [
                      GestureDetector(
                        // Inside the shell there is nothing to pop — the back
                        // arrow returns to the Home tab.
                        onTap: () =>
                            MainShell.selectedTab.value = MainShell.homeTab,
                        child: const Icon(HugeIcons.strokeRoundedArrowLeft01,
                            size: 24, color: Color(0xFF1A181B)),
                      ),
                      const Expanded(
                        child: Text(
                          'Keep your crystal within the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF1A181B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),

                  SizedBox(height: constraints.maxHeight * 0.06),

                  // Camera frame
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: frameSize,
                      height: frameSize,
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFBFD9D9), width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _framePreview(),
                    ),
                  ),

                  const Spacer(),

                  // Bottom control pill
                  Container(
                    height: 80,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x59FBF5F3),
                      borderRadius: BorderRadius.circular(99),
                      border:
                          Border.all(color: const Color(0x80FBF5F3), width: 1),
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
                            width: 64,
                            height: 64,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}