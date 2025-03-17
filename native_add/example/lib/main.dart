import 'package:flutter/material.dart';
import 'dart:async';

import 'package:native_add/native_add.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NativeAdd nativeAdd = NativeAdd();
  List<String> iceCandidates = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    initICECandidates();
  }

  Future<void> initICECandidates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      nativeAdd.create("175.45.203.60", 3478);
      nativeAdd.performSTUN();
      iceCandidates = nativeAdd.fetchICECandidates();
    } catch (e) {
      errorMessage = 'Failed to initialize ICE candidates: $e';
      print(errorMessage);
    } finally {
      nativeAdd.dispose();
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ICE Candidates Example'),
        ),
        body: ListView.builder(
          itemCount: iceCandidates.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(iceCandidates[index]),
            );
          },
        ),
      ),
    );
  }
}
