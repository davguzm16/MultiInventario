// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ImagePickerHelper extends StatefulWidget {
  String? rutaImagen;

  ImagePickerHelper({super.key});

  @override
  _ImagePickerHelperState createState() => _ImagePickerHelperState();
}

class _ImagePickerHelperState extends State<ImagePickerHelper> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        widget.rutaImagen = image.path;
      });
      context.pop(widget.rutaImagen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Imagen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.rutaImagen != null
                ? Image.file(File(widget.rutaImagen!))
                : const Text('No se ha seleccionado ninguna imagen'),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Seleccionar de galería'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Tomar foto'),
            ),
          ],
        ),
      ),
    );
  }
}
