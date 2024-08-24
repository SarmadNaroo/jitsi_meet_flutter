import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Call')),
        body: Center(child: Text('No user details available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Call')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user['username']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: ${user['email'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Status: ${user['status']}', style: TextStyle(fontSize: 18)),
            // Add more user details as needed
          ],
        ),
      ),
    );
  }
}
