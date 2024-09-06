import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../couleur/couleur.dart';
import '../couleur/couleur.dart';
import '../couleur/couleur.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<charts.Series<TicketData, String>> _seriesPieData = [];
  List<charts.Series<TicketData, String>> _seriesBarData = [];
  List<charts.Series<TicketData, String>> _seriesDailyData =
      []; // Pour stocker les stats par jour

  @override
  void initState() {
    super.initState();
    _getTicketData();
  }

  void _getTicketData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('tickets').get();

    // Vérifiez combien de documents sont récupérés
    print('Nombre de documents récupérés: ${snapshot.docs.length}');

    Map<String, int> statusCounts = {};
    Map<String, int> categoryCounts = {};
    Map<String, int> dailyCounts = {}; // Pour stocker les tickets par jour

    snapshot.docs.forEach((doc) {
      // Cast doc.data() en Map<String, dynamic>
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      // Vérifiez si le document contient le champ createdAt
      if (data != null && data.containsKey('createdAt')) {
        Timestamp createdAt = data['createdAt']; // Utiliser le champ createdAt
        String status =
            data['status'] ?? 'Inconnu'; // Gestion des valeurs nulles
        String category =
            data['category'] ?? 'Inconnu'; // Gestion des valeurs nulles

        // Vérifiez si la date est valide
        if (createdAt != null) {
          // Formatage de la date pour le regroupement par jour
          String dayKey =
              '${createdAt.toDate().year}-${createdAt.toDate().month.toString().padLeft(2, '0')}-${createdAt.toDate().day.toString().padLeft(2, '0')}'; // Exemple : "2024-09-01"

          // Compter les tickets par statut
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;

          // Compter les tickets par catégorie
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

          // Compter les tickets par jour
          dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;

          // Affichez les valeurs pour le débogage
          print('Created At: ${createdAt.toDate()}, Day Key: $dayKey');
        }
      } else {
        print('Document sans champ createdAt: ${doc.id}');
      }
    });

    // Vérifiez les résultats
    print('Daily Counts: $dailyCounts');
    print('Status Counts: $statusCounts');
    print('Category Counts: $categoryCounts');

    // Générer les statistiques par jour
    _seriesDailyData = _generateDailyData(dailyCounts);

    // Mettre à jour les graphiques
    setState(() {
      _seriesPieData = _generatePieData(statusCounts);
      _seriesBarData = _generateBarData(categoryCounts);
    });
  }

  List<charts.Series<TicketData, String>> _generatePieData(
      Map<String, int> dataMap) {
    List<TicketData> pieData = dataMap.entries
        .map((entry) => TicketData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<TicketData, String>(
        id: 'Tickets',
        domainFn: (TicketData data, _) => data.label,
        measureFn: (TicketData data, _) => data.value,
        data: pieData,
        labelAccessorFn: (TicketData row, _) => '${row.label}: ${row.value}',
        colorFn: (_, index) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];
  }

  List<charts.Series<TicketData, String>> _generateBarData(
      Map<String, int> dataMap) {
    List<TicketData> barData = dataMap.entries
        .map((entry) => TicketData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<TicketData, String>(
        id: 'Categories',
        domainFn: (TicketData data, _) => data.label,
        measureFn: (TicketData data, _) => data.value,
        data: barData,
        colorFn: (_, index) => charts.MaterialPalette.indigo.shadeDefault,
      )
    ];
  }

  List<charts.Series<TicketData, String>> _generateDailyData(
      Map<String, int> dataMap) {
    List<TicketData> dailyData = dataMap.entries
        .map((entry) => TicketData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<TicketData, String>(
        id: 'Tickets par Jour',
        domainFn: (TicketData data, _) => data.label,
        measureFn: (TicketData data, _) => data.value,
        data: dailyData,
        colorFn: (_, index) => charts.MaterialPalette.green.shadeDefault,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('Series Daily Data: $_seriesDailyData'); // Vérifiez les données ici
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              'Statistiques des tickets par jour',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: charts.BarChart(
                _seriesDailyData,
                animate: true,
              ),
            ),
            SizedBox(height: 20), // Espacement
            Text(
              'Nombre de tickets par catégorie',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: charts.BarChart(
                _seriesBarData,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketData {
  final String label;
  final int value;

  TicketData(this.label, this.value);
}
