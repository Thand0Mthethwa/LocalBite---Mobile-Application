import 'package:flutter/material.dart';

class CrimeReportingScreen extends StatelessWidget {
  const CrimeReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Crime Reporting'),
      ),
      body: Center(
        child: Text('Crime Reporting Screen'),
      ),
    );
  }
}
