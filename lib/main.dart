import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/institution_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

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
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    return MaterialApp.router(
      title: setting.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
