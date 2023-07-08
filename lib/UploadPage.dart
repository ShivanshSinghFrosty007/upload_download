import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  static const id = 'UploadPage';

  @override
  _UploadPage createState() => _UploadPage();
}

class _UploadPage extends State<UploadPage> {
  final dbRef = FirebaseDatabase.instance.reference().child("text");
  Reference storageRef = FirebaseStorage.instance.ref();

  File? image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Future pickImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);
    setState(() {
      this.image = imageTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (image != null)
              Image.file(
                image!,
                height: 200.0,
              )
            else
              const Icon(
                Icons.image,
                size: 200.0,
              ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "NAME"),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Age"),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(56),
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  textStyle: TextStyle(fontSize: 20)),
              onPressed: () {
                pickImage();
              },
              child: Text("Pick Photo"),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(56),
                  primary: Colors.orangeAccent,
                  onPrimary: Colors.white,
                  textStyle: TextStyle(fontSize: 20)),
              onPressed: () async {

                if(nameController.text == "" || ageController.text == "" || image == null){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter all feilds")));
                  return;
                }

                final path = 'files/${nameController.text}';
                storageRef = storageRef.child(path);
                UploadTask uploadTask = storageRef.putFile(image!);

                final snapshot = await uploadTask.whenComplete(() {});
                final urlDownload = await snapshot.ref.getDownloadURL();

                Map<String, dynamic> nameMap = {"name": nameController.text};
                Map<String, dynamic> ageMap = {"age": ageController.text};
                Map<String, dynamic> imageMap = {"image": urlDownload};

                dbRef.child(nameController.text).update(nameMap);
                dbRef.child(nameController.text).update(ageMap);
                dbRef.child(nameController.text).update(imageMap);

                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
