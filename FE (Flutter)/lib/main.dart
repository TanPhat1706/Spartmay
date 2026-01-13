import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spartmay/core/theme/app_theme.dart';
import 'package:spartmay/features/auth/presentation/pages/splash_screen.dart';
import 'package:spartmay/features/auth/logic/auth_provider.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';
import 'package:spartmay/features/transaction/logic/transaction_provider.dart';
import 'package:spartmay/features/calendar/logic/calendar_provider.dart';
import 'package:spartmay/features/category/logic/category_provider.dart';
import 'package:spartmay/features/stat/logic/stat_provider.dart';
import 'package:spartmay/features/user/logic/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const SpartmayApp());
}

class SpartmayApp extends StatelessWidget {
  const SpartmayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => StatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Spartmay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, 
        locale: const Locale('vi', 'VN'),
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}