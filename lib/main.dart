import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_netflix_responsive_ui/providers/google_drive_provider.dart';
import 'package:flutter_netflix_responsive_ui/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GoogleDriveProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    startAwait();
  }

  Future<void> startAwait() async {
    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);

    await provider.googleDrive.signIn();
    await provider.googleDrive.fetchCategories();

    setState(() => {loading = false});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netflix Julcia i Paweł',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: loading ? CupertinoActivityIndicator() : NavScreen(),
    );
  }
}
