import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/institution_provider.dart';
import 'screens/public/public_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final institutionProvider = InstitutionProvider();
  await institutionProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: institutionProvider),
      ],
      child: const InstitutionManagementApp(),
    ),
  );
}

class InstitutionManagementApp extends StatelessWidget {
  const InstitutionManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final setting = context.watch<InstitutionProvider>().setting;

    return MaterialApp(
      title: setting.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: const PublicScreen(),
    );
  }
}
