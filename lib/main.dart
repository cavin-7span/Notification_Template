import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_template/notification_channel.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB_WB7Wja1c3KQIMwb8ERres840PdEi-Ng",
        appId: "1:595028006349:web:d702ff566628aef278a084",
        messagingSenderId: "595028006349",
        projectId: "notification-template-d55fc",
      ),
    );
  }

  log("Handling notification service");
  NotificationInitialization.startNotificationService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = "/firebase-push";

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // message listner for web
  void messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification?.body}');
          showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DynamicDialog(
                  title: message.notification?.title,
                  body: message.notification?.body);
            }),
          );
        }
      },
    );
  }

  @override
  void initState() {
    if (kIsWeb) {
      messageListener(context);
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<dynamic>(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              print('android firebase initiated');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

//push notification dialog for foreground
class DynamicDialog extends StatelessWidget {
  final String? title;
  final String? body;
  const DynamicDialog({super.key, this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "N/A"),
      actions: [
        OutlinedButton.icon(
          label: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        )
      ],
      content: Text(body ?? "N/A"),
    );
  }
}
