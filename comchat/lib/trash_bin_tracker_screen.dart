import 'package:flutter/material.dart';

class TrashBinTrackerScreen extends StatelessWidget {
  const TrashBinTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Trash Bin Tracker'),
      ),
      body: Center(
        child: Text('Trash Bin Tracker Screen'),
      ),
    );
  }
}
