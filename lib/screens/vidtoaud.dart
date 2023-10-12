import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';


class ImagePickerExample extends StatefulWidget {
  //const ImagePickerExample({super.key});

  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  File? _image;
  String? responseText;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });

    if (_image != null) {
      await _sendImageToServer(_image!);
    }
  }

  Future<void> _sendImageToServer(File image) async {
    var uri = Uri.parse("http://34.227.89.166:5000/predict");

    var request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // 'file' is the field name on the server endpoint
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    var response = await request.send();
    print(response);

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse=jsonDecode(responseBody);
      // Update the UI with the response.
      setState(() {
        responseText = decodedResponse['result'];
      });
    } else {
      print("Image upload failed with status code ${response.statusCode}");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: SingleChildScrollView(  // <-- Added this
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!),
            ),
            const SizedBox(height: 16.0),
            if (responseText != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '$responseText',
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select an image'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            GestureDetector(
                              child: const Text('Pick from gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 16.0),
                            GestureDetector(
                              child: const Text('Take a photo'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text('Upload & Predict'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select an image'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      GestureDetector(
                        child: const Text('Pick from gallery'),
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        child: const Text('Take a photo'),
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

