import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'screens/calendar_screen.dart';
import 'screens/health_diary_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/pt_bottom_nav.dart';
import 'widgets/pt_robot_fab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Intl.defaultLocale = 'tr_TR';
  runApp(const PetTrackApp());
}

class PetTrackApp extends StatelessWidget {
  const PetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetTrack',
      theme: buildPetTrackTheme(),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// 0 Profil, 1 Takvim, 2 Günlük, 3 Beslenme
  int _stackPage = 1;

  void _onNav(int i) {
    if (i == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pati Dostu asistanı (taslak)')),
      );
      return;
    }
    setState(() {
      if (i == 0) _stackPage = 0;
      if (i == 1) _stackPage = 1;
      if (i == 3) _stackPage = 2;
      if (i == 4) _stackPage = 3;
    });
  }

  int get _navHighlight {
    switch (_stackPage) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _stackPage,
            children: const [
              ProfileScreen(),
              CalendarScreen(),
              HealthDiaryScreen(),
              NutritionScreen(),
            ],
          ),
          if (_stackPage == 0)
            PtRobotFab(
              bottomOffset: 108,
              onPressed: () {},
            ),
          if (_stackPage == 3)
            PtRobotFab(
              bottomOffset: 108,
              label: 'Pati Dostu',
              onPressed: () {},
            ),
        ],
      ),
      bottomNavigationBar: PtBottomNav(
        currentIndex: _navHighlight,
        nutritionLargePlus: _navHighlight == 4,
        onChanged: _onNav,
        onCenterTap: () => _onNav(2),
      ),
    );
  }
}
