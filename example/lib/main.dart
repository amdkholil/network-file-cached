import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_file_cacher/network_file_cacher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkFileCacher.init(expired: const Duration(hours: 1));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Network File Cached Example')),
        body: Center(
          child: FutureBuilder<File>(
            future: NetworkFileCacher.downloadFile(
              'https://picsum.photos/200/300',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.hasData) {
                return Image.file(snapshot.data!);
              }
              return const Text('No Data');
            },
          ),
        ),
      ),
    );
  }
}
