// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ImagePickerHelper extends StatefulWidget {
  const ImagePickerHelper({super.key});

  @override
  State<ImagePickerHelper> createState() => _ImagePickerHelperState();
}

class _ImagePickerHelperState extends State<ImagePickerHelper> {
  final ImagePicker _picker = ImagePicker();
  String? _rutaImagen;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _rutaImagen = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Seleccione una opción',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _rutaImagen == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageButton(
                    icon: Icons.image,
                    text: "Galería",
                    color: const Color(0xFF493D9E), // Morado oscuro
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 40),
                  _buildImageButton(
                    icon: Icons.camera_alt,
                    text: "Cámara",
                    color: const Color(0xFF2BBF55), // Verde brillante
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_rutaImagen!),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'btnAceptar',
                        onPressed: () {
                          context.pop(_rutaImagen);
                        },
                        backgroundColor: const Color(0xFF2BBF55),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.check, size: 28),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        heroTag: 'btnCancelar',
                        onPressed: () {
                          setState(() {
                            _rutaImagen = null;
                          });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.close, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
