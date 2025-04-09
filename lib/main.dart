import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toolkit/screens/cv_maker_screens/cv_maker_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/personal_info_screen.dart';

import 'package:toolkit/screens/home_screen.dart';
import 'package:toolkit/widgets/cv_templates/template_1.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}
// void main() {
//   runApp(
//     DevicePreview(
//       enabled: true,
//       builder: (context) => const MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToolKit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primaryColor: const Color(0xFF00BFA5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PersonalInfoScreen(),
    );
  }
}





