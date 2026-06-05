import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'screens/assistant_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/health_diary_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/profile_screen.dart';
import 'state/active_pet_scope.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/pt_bottom_nav.dart';
import 'widgets/pt_robot_fab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  Intl.defaultLocale = 'tr_TR';
  runApp(const PetTrackApp());
}

class PetTrackApp extends StatelessWidget {
  const PetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivePetScopeWidget(
      child: MaterialApp(
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
      ),
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
  int _stackPage = 0;

  void _openAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AssistantScreen()),
    );
  }

  void _onNav(int i) {
    if (i == 2) {
      _openAssistant();
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
        return 0;
    }
  }

  static const _pages = <Widget>[
    ProfileScreen(),
    CalendarScreen(),
    HealthDiaryScreen(),
    NutritionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final fabBottom = 16 + bottomInset;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                IndexedStack(
                  index: _stackPage,
                  children: _pages,
                ),
                if (_stackPage == 0 || _stackPage == 3)
                  PtRobotFab(
                    bottomOffset: fabBottom,
                    label: _stackPage == 3 ? 'Pati Dostu' : null,
                    onPressed: _openAssistant,
                  ),
              ],
            ),
          ),
          PtBottomNav(
            currentIndex: _navHighlight,
            nutritionLargePlus: _navHighlight == 4,
            onChanged: _onNav,
            onCenterTap: _openAssistant,
          ),
        ],
      ),
    );
  }
}
