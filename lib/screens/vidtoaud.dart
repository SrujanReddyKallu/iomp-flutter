import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:iomp/screens/login.dart';


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
    setState(() {
      responseText = null;
    });
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
      var decodedResponse = jsonDecode(responseBody);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Caption Generator'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text('Logout'),
          ),
        ],
      ),
      body: Padding( // <-- Added Padding here
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
        // <-- Specify your desired padding value here
        child: SingleChildScrollView(
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
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$responseText',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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
      ),
    );
  }
}