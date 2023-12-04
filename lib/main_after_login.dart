import 'package:flutter/material.dart';
import 'package:wellbeing_life/InputPage.dart';
import 'package:wellbeing_life/FoodImage.dart';
import 'package:wellbeing_life/medicine_alert.dart';
import 'package:wellbeing_life/sns.dart';

class mainAfterLogin extends StatelessWidget {
  const mainAfterLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서비스 시작하기'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InputPage()),
                  );
                },
                child: const Text('하루 섭취한 영양소 분석'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraPage()),
                  );
                },
                child: const Text('사진으로 영양성분 분석'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MedicineAlertPage()),
                  );
                },
                child: const Text('약 복용 알림 추가하기'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const snsAnalyze()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.brown[200], // 버튼 텍스트 색상
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 10), // 버튼 내부 여백
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // 버튼 모서리 둥글기
                  ),
                ),
                child: const Text('SNS 분석하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
