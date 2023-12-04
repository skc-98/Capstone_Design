// 추후 제거 고려
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineNotification {
  final String title;
  final String description;
  final DateTime scheduledTime;

  MedicineNotification({
    required this.title,
    required this.description,
    required this.scheduledTime,
  });
}

class MedicineAlertPage extends StatefulWidget {
  const MedicineAlertPage({super.key});

  @override
  _MedicineAlertPageState createState() => _MedicineAlertPageState();
}

class _MedicineAlertPageState extends State<MedicineAlertPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late DateTime _selectedTime = DateTime.now();
  final List<MedicineNotification> _scheduledNotifications = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    _retrieveScheduledNotifications();
  }

  Future<void> scheduleNotification(DateTime scheduledTime) async {
    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(scheduledTime, tz.local);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    MedicineNotification notification = MedicineNotification(
      title: 'Medicine Time!',
      description: '약 복용 시간입니다.',
      scheduledTime: scheduledTime,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _scheduledNotifications.length + 1,
      notification.title,
      notification.description,
      scheduledDateTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    _scheduledNotifications.add(notification);
    await setScheduledTimeToFirebase(); // Firebase에 예약된 시간 저장
    setState(() {});
  }

  Future<void> _retrieveScheduledNotifications() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users')
        .doc('userId')
        .get();

    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('notifications')) {
      List<dynamic> notifications = data['notifications'];
      for (var notification in notifications) {
        if (notification is Timestamp) {
          _scheduledNotifications.add(
            MedicineNotification(
              title: 'Medicine Time!',
              description: '약 복용 시간입니다.',
              scheduledTime: notification.toDate(),
            ),
          );
        }
      }
    }
    setState(() {});
  }

  Future<void> _cancelNotification(int index) async {
    await flutterLocalNotificationsPlugin.cancel(index + 1);
    _scheduledNotifications.removeAt(index);
    await setScheduledTimeToFirebase(); // Firebase에서 해당 시간 삭제
    setState(() {});
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
      await scheduleNotification(_selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 복용 알림 추가하기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _selectTime(context);
              },
              child: const Text('알림 추가하기'),
            ),
            const SizedBox(height: 20),
            const Text(
              '현재 설정된 알림 목록:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _scheduledNotifications.length,
                itemBuilder: (BuildContext context, int index) {
                  final notification = _scheduledNotifications[index];
                  return ListTile(
                    title: Text(
                      '예약된 시간: ${notification.scheduledTime.hour}:${notification.scheduledTime.minute}',
                    ),
                    subtitle: Text(notification.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _cancelNotification(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setScheduledTimeToFirebase() async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc('userId');

    Map<String, dynamic> scheduledTimesMap = {};
    _scheduledNotifications.asMap().forEach((index, notification) {
      scheduledTimesMap['$index'] =
          notification.scheduledTime.toIso8601String();
    });

    await documentReference.set(
      {'notifications': scheduledTimesMap},
      SetOptions(merge: true),
    );
  }
}
