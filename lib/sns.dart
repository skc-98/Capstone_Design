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
  late List<Map<String, dynamic>> _results;

  Future<void> _sendImageAndGetResult(String imageName) async {
    ByteData imageData = await rootBundle.load(imageName);
    List<int> bytes = imageData.buffer.asUint8List();

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
      var result = await response.stream.bytesToString();
      print('Received data: $result'); // 결과 출력해보기
      var data = jsonDecode(result);
      Map<String, dynamic> predictionResult = {
        'image': imageName,
        'prediction': 'test${_results.length + 1}의 예측값: ${data['prediction']}',
        'result': data['result']
      };
      setState(() {
        _results.add(predictionResult);
      });
    } else {
      print('이미지 전송 및 결과 요청 실패. 상태 코드: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _results = [];
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
                for (int i = 1; i <= 10; i++) {
                  String imageName = 'assets/test$i.jpg';
                  await _sendImageAndGetResult(imageName);
                }
              },
              child: const Text('사진 전송'),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildResultWithImage(
                  _results[index]['image'],
                  _results[index]['prediction'],
                  _results[index]['result'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWithImage(
      String imagePath, String prediction, Map<dynamic, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          // 이미지 크기 조정
          imagePath,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10),
        Text(
          prediction,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: result.entries.map((entry) {
            return Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 14),
            );
          }).toList(),
        ),
        const Divider(), // 각 결과 사이에 구분선 추가
      ],
    );
  }
}
