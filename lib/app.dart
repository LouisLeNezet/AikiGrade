import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'routes.dart';

class AikiGradeApp extends StatelessWidget {
  const AikiGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AïkiGrade',
      theme: ThemeData(
        // Set your primary color
        primaryColor: AppColors.primaryColor,
        // Set the accent color (used in FloatingActionButton, etc.)
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondaryColor,
        ),
        // Set the background color
        scaffoldBackgroundColor: AppColors.backgroundColor,
        // Set the text color for the entire app
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textColor,
          ), // Previously headline1
          headlineMedium: TextStyle(
            color: AppColors.textColor,
          ), // Previously headline2
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ), // Previously headline3
          titleLarge: TextStyle(
            color: AppColors.textColor,
          ), // Previously headline4
          titleMedium: TextStyle(
            color: AppColors.textColor,
          ), // Previously headline5
          titleSmall: TextStyle(
            color: AppColors.textColor,
          ), // Previously headline6
          labelLarge: TextStyle(
            color: AppColors.textColor,
          ), // For button labels
          labelMedium: TextStyle(
            color: AppColors.textColor,
          ), // For button labels
          labelSmall: TextStyle(
            color: AppColors.textColor,
          ), // For button labels
          bodyLarge: TextStyle(
            color: AppColors.textColor,
          ), // Previously bodyText1
          bodyMedium: TextStyle(
            color: AppColors.textColor,
          ), // Previously bodyText2
          bodySmall: TextStyle(color: AppColors.textColor), // For smaller text
        ),
        // Button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
          ),
        ),
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
