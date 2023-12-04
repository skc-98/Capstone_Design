import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _prediction = "";
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카메라')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: <Widget>[
                Expanded(
                    child: _image == null
                        ? CameraPreview(_controller)
                        : Image.file(File(_image!.path))),
                Text(_prediction),
                ElevatedButton(
                  onPressed: () async {
                    if (_image != null) {
                      final File image = File(_image!.path);
                      var request = http.MultipartRequest('POST',
                          Uri.parse('http://111.91.155.174:5000/predict'));
                      request.files.add(await http.MultipartFile.fromPath(
                          'file', image.path));
                      var response = await request.send();
                      if (response.statusCode == 200) {
                        response.stream.transform(utf8.decoder).listen((value) {
                          var data = jsonDecode(value);
                          String prediction = '예측값: ${data['prediction']}';
                          String result = '결과:\n';
                          for (var key in data['result'].keys) {
                            result += '$key: ${data['result'][key]}\n';
                          }
                          setState(() {
                            _prediction =
                                '$prediction\n$result\n영양성분 표시까지 구현하지 못했습니다...';
                          });
                        });
                      } else {
                        print(
                            'Request failed with status: ${response.statusCode}.');
                      }
                    }
                  },
                  child: const Text('사진 전송'),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            _image = await _controller.takePicture();
            setState(() {});
          } catch (e) {
            print('사진 촬영 오류: $e');
          }
        },
      ),
    );
  }
}
