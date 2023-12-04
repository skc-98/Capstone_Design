import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _kcalController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbohydrateController = TextEditingController();
  String _prediction = "";

  Future<void> sendInputData() async {
    final response = await http.post(
      // 이부분 호스팅 문제 해결해야함
      Uri.parse('http://111.91.155.174:5000/predict'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'kcal': _kcalController.text,
        'protein': _proteinController.text,
        'fat': _fatController.text,
        'carbohydrate': _carbohydrateController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      double predictionValue = double.parse(result['prediction'].toString());
      setState(() {
        if (predictionValue <= 0.1) {
          _prediction = '현재 식습관을 유지해도 좋습니다!';
        } else if (predictionValue > 0.1 && predictionValue <= 0.3) {
          _prediction =
              '조금 더 건강한 식단이 필요합니다.\n 탄단지 비율을 적절하게 유지하고 칼로리 섭취량을 정상 범위로 유지하세요.';
        } else {
          _prediction =
              '비정상적인 식단입니다.\n 탄수화물, 단백질, 지방의 비율이 적절하지 않습니다. \n 대사증후군 위험도가 높습니다.';
        }
      });
    } else {
      print('요청 실패: ${response.statusCode}');
    }
    // 예측값 1에 가까울수록 환자 영양소와 비슷
    // 0에 가까운 값이 정상인 데이터
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('하루 섭취한 영양소 분석'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _kcalController,
                decoration: const InputDecoration(
                  labelText: '칼로리',
                ),
              ),
              TextField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: '단백질',
                ),
              ),
              TextField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: '지방',
                ),
              ),
              TextField(
                controller: _carbohydrateController,
                decoration: const InputDecoration(
                  labelText: '탄수화물',
                ),
              ),
              ElevatedButton(
                onPressed: sendInputData,
                child: const Text('전송'),
              ),
              Text(
                _prediction,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
