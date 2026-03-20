import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/shopkeeper/dashboard_wrapper.dart';
import 'pages/receiver/dashboard_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const FoodDonationApp(),
    ),
  );
}

class FoodDonationApp extends StatelessWidget {
  const FoodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Donation',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/shopkeeper_dashboard': (context) => const ShopkeeperDashboardWrapper(),
        '/receiver_dashboard': (context) => const ReceiverDashboardWrapper(),
      },
    );
  }
}
