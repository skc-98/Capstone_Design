import 'package:flutter/material.dart';

class mainAfterLogin extends StatelessWidget {
  const mainAfterLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing Life에 오신 것을 환영합니다'),
      ),
      body: const Center(
        child: Text(
          '로그인에 성공했습니다!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
