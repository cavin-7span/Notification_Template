importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyB_WB7Wja1c3KQIMwb8ERres840PdEi-Ng",
    authDomain: "notification-template-d55fc.firebaseapp.com",
    projectId: "notification-template-d55fc",
    storageBucket: "notification-template-d55fc.appspot.com",
    messagingSenderId: "595028006349",
    appId: "1:595028006349:web:d702ff566628aef278a084",
  };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });