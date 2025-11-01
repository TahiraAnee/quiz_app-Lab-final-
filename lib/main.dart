import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/category_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizProvider(),
      child: MaterialApp(
        title: 'Quizzical',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/categories': (context) => const CategoryScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/results': (context) => const ResultsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}