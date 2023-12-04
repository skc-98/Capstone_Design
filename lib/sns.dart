import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class snsAnalyze extends StatefulWidget {
  const snsAnalyze({super.key});

  @override
  _snsAnalyzeState createState() => _snsAnalyzeState();
}

class _snsAnalyzeState extends State<snsAnalyze> {
  String _prediction = "";

  Future<void> _countResultsFromAssets() async {
    // test1부터 test10까지의 이미지를 순회하며 카운트합니다.
    for (int i = 1; i <= 10; i++) {
      String imageName = 'assets/test$i.jpg'; // 이미지 경로
      ByteData imageData = await rootBundle.load(imageName);
      List<int> bytes = imageData.buffer.asUint8List();

      // 이미지를 서버로 전송하고 결과를 받아옵니다.
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://111.91.155.174:5000/predict'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageName,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          var data = jsonDecode(value);
          String prediction = 'test$i의 예측값: ${data['prediction']}';
          String result = '결과:\n';
          for (var key in data['result'].keys) {
            result += '$key: ${data['result'][key]}\n';
          }
          setState(() {
            _prediction += '$prediction\n$result\n';
          });
        });
      } else {
        print('test$i에 대한 요청이 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS 분석하기')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _countResultsFromAssets();
              },
              child: const Text('사진 전송'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _prediction.isNotEmpty ? _prediction : '여기에 결과가 표시됩니다.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
