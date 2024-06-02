import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/analytics_helper.dart';

class ImagePickerBottomSheet extends StatefulWidget {
  const ImagePickerBottomSheet({super.key});

  @override
  State<ImagePickerBottomSheet> createState() => _ImagePickerBottomSheetState();
}

class _ImagePickerBottomSheetState extends State<ImagePickerBottomSheet> {
  @override
  void initState() {
    super.initState();
    addScreenViewTracking(
      widget.runtimeType.toString(),
      "ImagePickerBottomSheet",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text(Constants.pickFromGalleryLabel),
            onTap: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
          ListTile(
            title: const Text(Constants.openCameraLabel),
            onTap: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
