
## Authors

- [@Cavin](https://github.com/cavin-7span)

## Steps to integrate notification

- First create firebase account and setup for android and web 
- Generate vapid key in firebase for flutter web notification
- Now add the google-services.json into your project inside **app** directory
- Now add the following packages in your app :
    - firebase_core
    - firebase_messaging
    - flutter_local_notifications
- Copy the **notification_service** and **web_notification_dialog** file from this repo and paste into your project
- Add these lines in your main method:
 ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp();
  } else {
      // for the web part
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
 ```

 - To listen for web notifications, add the following method in your first stateful widget and call it in init state :
 ```
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
            builder: (BuildContext context) {
              return DynamicDialog(
                  title: message.notification?.title,
                  body: message.notification?.body);
            },
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

 ```

- Add the following function above main method to listen for android background notifications :

```
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
```

- Now add this meta data in your android manifest before **activity** :
```
 <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="high_importance_channel" />
```

- Add these intent filter in Android manifest file in order to get the notification data from background :
```
<intent-filter>
        <action android:name="FLUTTER_NOTIFICATION_CLICK" />
        <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
<intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
</intent-filter>
```

- Now copy the **firebase-messaging-sw.js** file and paste into your project inside **web** directory.
- Add your keys inside **firebase-messaging-sw.js** 
- Add this script in **index.html** and modify the keys of your firebase credentials
```
 <script>
   const firebaseConfig =  {
        apiKey: "AIzaSyB_WB7Wja1c3KQIMwb8ERres840PdEi-Ng",
        authDomain: "notification-template-d55fc.firebaseapp.com",
        projectId: "notification-template-d55fc",
        storageBucket: "notification-template-d55fc.appspot.com",
        messagingSenderId: "595028006349",
        appId: "1:595028006349:web:d702ff566628aef278a084",
      }
      firebase.initializeApp(firebaseConfig);
  </script>

```
- Add the following lines in the **head** tag on i**index.html**
```
  <script src="https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js"></script>

```

- Remove the follwing script from **index.html** 
```
<script>
    if ("serviceWorker" in navigator) {
        window.addEventListener("load", function () {
          navigator.serviceWorker.register("/firebase-messaging-sw.js");
        });
      }
</script>
```
- Add this script in **index.html**
```
<script>
        window.addEventListener('load', function(ev) {
          // Download main.dart.js
          _flutter.loader.loadEntrypoint({
            serviceWorker: {
              serviceWorkerVersion: serviceWorkerVersion,
            }
          }).then(function(engineInitializer) {
            return engineInitializer.initializeEngine();
          }).then(function(appRunner) {
            return appRunner.runApp();
          });
        });
</script>
```

- You can edit channels and everything according to your need in **notification_service.dart**

Note: Don't forget to add those channels in AndroidManifest.xml 