import "dart:io";

import 'package:image_picker/image_picker.dart';

class GetImage {
  Future<File?> pickImage() async {
    PickedFile? pickedImageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 100,
    );

    if (pickedImageFile == null) {
      print('No image Picked');
      return null;
    } else
      return File(pickedImageFile.path);
  }
}
