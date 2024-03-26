
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../Functions/Providers/app_state_provider.dart';

import '../../../../Pages/CommunicationPage.dart';
import '../../../../Pages/OptionsPage.dart';
import '../../../../Pages/RandAPage.dart';
import '../../../../Pages/dashboard.dart';
import '../../Pages/calendar_Page.dart';
import '../../Pages/journal_page.dart';
import '../../Pages/kanban_page.dart';
import '../../Pages/tasks_page.dart';
import 'aiv_nav.dart';

final tileTxtStyle = TextStyle(
  fontSize: 14,
  fontFamily: GoogleFonts.poppins().fontFamily,
  fontWeight: FontWeight.w400,
);

final shadowStyle = [
  Shadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 6,
    offset: const Offset(0, 3), // changes position of shadow
  ),
];

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Row(
        children: [
          const AIVNavRail(),
          Expanded(
            child: Column(
              children: [
                // App Bar
                // TODO:
                // pages
                Expanded(
                  flex: 26,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      String screen =
                      Provider.of<AppStateProvider>(context, listen: true)
                          .selectedPage!;
                      // debugPrint(screen);
                      switch (screen) {
                        case 'Dashboard':
                          return const Dashboard(

                          );
                        case 'TaskList':
                          return const TaskListPage();
                        case 'Kanbans':
                          return const KanbanPage();
                        case 'Journal':
                          return const JournalPage();
                        case 'Calendar':
                          return const CalendarPage();
                        case 'Reports & Analytics':
                          return const RandAPage();
                        case 'Communication':
                          return const CommunicationPage();
                        case 'Options':
                          return const OptionsPage();
                        default:
                          return const Dashboard(
                          );
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
