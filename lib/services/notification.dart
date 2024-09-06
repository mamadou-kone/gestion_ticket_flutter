import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  // Callback pour les tap sur les notifications
  static void onNotificationTap(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      onClickNotification.add(notificationResponse.payload!);
    } else {
      print('Erreur : le payload est nul.');
    }
  }

  // Initialiser les notifications locales
  static Future<void> init() async {
    // Initialisation pour Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialisation pour iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    // Initialisation pour Linux
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Configuration des paramètres d'initialisation
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // Initialiser le plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);

    // Demander la permission sur iOS
    if (initializationSettingsDarwin.onDidReceiveLocalNotification != null) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(alert: true, badge: true, sound: true);
    }

    print('Notifications locales initialisées avec succès.');
  }

  // Afficher une notification simple
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);

    print('Notification envoyée : $title');
  }

  // Récupérer les tokens des formateurs
  static Future<List<String>> getTrainerTokens() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'formateur')
        .get();

    List<String> tokens = [];
    for (var doc in querySnapshot.docs) {
      tokens.add(
          doc['token']); // Assurez-vous que ce champ existe dans votre document
    }
    return tokens;
  }

  // Envoyer des notifications aux formateurs
  static Future<void> sendNotificationsToTrainers(
      String title, String body) async {
    List<String> tokens = await getTrainerTokens();

    for (String token in tokens) {
      await sendNotification(token, title, body);
    }
  }

  // Méthode pour envoyer une notification via FCM
  static Future<void> sendNotification(
      String token, String title, String body) async {
    final String serverToken =
        'YOUR_SERVER_KEY'; // Remplacez par votre clé serveur

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(<String, dynamic>{
        'to': token,
        'notification': <String, dynamic>{
          'title': title,
          'body': body,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification envoyée avec succès à $token');
    } else {
      print('Erreur lors de l\'envoi de la notification : ${response.body}');
    }
  }
}
