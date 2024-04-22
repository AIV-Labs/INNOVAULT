import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Functions/Providers/app_state_provider.dart';
import 'NavWidgets/dashboard_nav_widget.dart';
import 'NavWidgets/file_vault_nav_widget.dart';
import 'NavWidgets/journal_nav_widget.dart';
import 'NavWidgets/task_nav_widget.dart';

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

class AIVNavRail extends StatefulWidget {
  const AIVNavRail({super.key});

  @override
  State<AIVNavRail> createState() => _AIVNavRailState();
}

class _AIVNavRailState extends State<AIVNavRail> {
  bool isHovered = false;
  bool isVisible = false;

  String selectedPage = 'Dashboard';

  Timer? exitTimer;
  Timer? enterTimer;
  bool detailedViewOpen = false;

  void toggleDetailedView() {
    setState(() {
      detailedViewOpen = !detailedViewOpen;
    });
  }
  void turnOffDetailedView() {
    setState(() {
      detailedViewOpen = false;
    });
  }
  void turnOnDetailedView() {
    setState(() {
      detailedViewOpen = true;
    });
  }

  void chgSelectedPage(String newPage) {
    turnOnDetailedView();
    setState(() {
      selectedPage = newPage;
    });
    // push to new page
    Provider.of<AppStateProvider>(context, listen: false)
        .setSelectedPage(newPage);
    // Navigator.pushNamed(context, "/${newPage}");
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        // the hover auto open
        //     onEnter: (_) {
        //       exitTimer?.cancel();
        //
        //       enterTimer = Timer(const Duration(milliseconds: 900), () {
        //         setState(() {
        //           isHovered  = true;
        //         });
        //       });
        // // change this as well when you chang  the speed of the rail
        //       exitTimer = Timer(const Duration(milliseconds: 1050), () {
        //         setState(() {
        //           isVisible  = true;
        //         });
        //       });
        //     },
        onExit: (_) {
          enterTimer?.cancel();
          exitTimer?.cancel();
          isVisible = false;
          exitTimer = Timer(const Duration(milliseconds: 200), () {
            setState(() {
              isHovered = false;
            });
          });
        },
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (isHovered == false) {
                exitTimer?.cancel();
                isHovered = true;
      
                exitTimer = Timer(const Duration(milliseconds: 230), () {
                  setState(() {
                    isVisible = true;
                  });
                });
              } else {
                exitTimer?.cancel();
                isVisible = false;
                exitTimer = Timer(const Duration(milliseconds: 50), () {
                  setState(() {
                    isHovered = false;
                  });
                });
              }
            });
          },
          child: AnimatedContainer(
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    // color:  Color(0xFFf3f5f6).withOpacity(0.9),
                    color: const Color(0xFFd1d9db).withOpacity(0.9),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    spreadRadius: -1.2,
                    blurRadius: 20.0,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isHovered ? 250 : 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Logo
                  Expanded(
                    flex: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return  Container(
                                height: 170,
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 20,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Image.asset(
                                          'assets/CF_bodymodel/female/woman_front_face.png',
                                          height: 170,
                                          fit: BoxFit.scaleDown,
                                          filterQuality: FilterQuality.medium,
                                          isAntiAlias: true,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Visibility(
                                        visible: isHovered,
                                        child: Divider(
                                          color: Colors.black.withOpacity(0.3),
                                          thickness: 1,
                                          indent:
                                              MediaQuery.of(context).size.width /
                                                  20,
                                          endIndent:
                                              MediaQuery.of(context).size.width /
                                                  20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                      },
                    ),
                  ),
      
                  const SizedBox(
                    height: 30,
                  ),
      
                  // List Tiles
      
                  // List Tiles

                  Expanded(
                      flex: 5,
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          if (isHovered && detailedViewOpen) {
                            // Navigation rail is opened and detailed view is open
                            Widget selectedWidget;
                            switch (selectedPage) {
                                case 'Dashboard':
                                  selectedWidget = const DashboardNavWidget();
                                  break;
                                case 'File Vault':
                                  selectedWidget = const VaultNavWidget();
                                  break;
                                case 'Journal':
                                  selectedWidget = const JournalNavWidget();
                                  break;
                                case 'Tasks':
                                  selectedWidget = const TasksNavWidget();
                                  break;
                                default:
                                  selectedWidget = Text('You Shouldn\'t Be Here '); // Default widget when no page is selected
                                }
                                return Column(
                                children: [
                                TextButton(
                                onPressed: turnOffDetailedView,
                                child: const Text('Back to main navigation'),
                                ),
                                selectedWidget,
                                ],
                                );

                          } else {
                            // Navigation rail is closed
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CustomListTile(
                                    isVisible: isVisible,
                                    icon: Icons.dashboard,
                                    title: 'Dashboard',
                                    hoveredColor: const Color(0xFFe8cca5),
                                    chgSelectedPage: chgSelectedPage,
                                  )
                                ),
                                Expanded(
                                  child: CustomListTile(
                                    isVisible: isVisible,
                                    icon: Icons.folder_open,
                                    title: 'File Vault',
                                    hoveredColor: const Color(0xFF6b4e71),
                                    chgSelectedPage: chgSelectedPage,
                                  )
                                ),
                                Expanded(
                                  child: CustomListTile(
                                    isVisible: isVisible,
                                    icon: Icons.book,
                                    title: 'Journal',
                                    hoveredColor: const Color(0xFFb75d69),
                                    chgSelectedPage: chgSelectedPage,
                                  )
                                ),
                                Expanded(
                                  child: CustomListTile(
                                    isVisible: isVisible,
                                    icon: Icons.task,
                                    title: 'Tasks',
                                    hoveredColor: const Color(0xFF00a878),
                                    chgSelectedPage: chgSelectedPage,
                                  )
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
      
                  const SizedBox(
                    height: 80,
                  ),
      
                  Expanded(
                    child: AnimatedContainer(
                      padding: const EdgeInsets.only(bottom: 20),
                      duration: const Duration(milliseconds: 150),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // align to right
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: isVisible,
                            child: RepaintBoundary(
                              child: Image(
                                image: const AssetImage(
                                  'assets/Logo_Icons/AIV.gif',
                                ),
                                width: isVisible ? 60 : 30,
                                filterQuality: FilterQuality.medium,
                                isAntiAlias: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class CustomListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isVisible;
  final Color hoveredColor;
  //declare function to change the selected page
  final Function(String) chgSelectedPage;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isVisible,
    required this.hoveredColor,
    required this.chgSelectedPage,
  });

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _colorAnimation;

  bool isHovered = false;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _colorAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const double growScale = 1.12;
    const Color defaultColor = Color(0xFF343a40);
    final Color hoveredColor = widget.hoveredColor;

    bool selectedPage = (widget.title ==
        Provider.of<AppStateProvider>(context, listen: true).selectedPage);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 0, 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: () {
            widget.chgSelectedPage(widget.title);
            _animateColor();
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                // Icon
                Icon(
                  widget.icon,
                  size: isHovered || isClicked || selectedPage
                      ? 20 * growScale
                      : 20,
                  color:
                      isHovered || selectedPage ? hoveredColor : defaultColor,
                  shadows: [
                    Shadow(
                      color: isHovered || selectedPage
                          ? hoveredColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                // title
                Transform.scale(
                  scale:
                      isHovered || isClicked || selectedPage ? growScale : 1.0,
                  child: Visibility(
                    visible: widget.isVisible,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize:
                            isHovered || isClicked || selectedPage ? 13 : 14,
                        fontWeight: isHovered || isClicked || selectedPage
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isHovered || selectedPage
                            ? hoveredColor
                            : defaultColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _animateColor() {
    setState(() {
      isClicked = !isClicked;
    });

    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse().then((_) {
        setState(() {
          isClicked = false;
        });
      });
    } else {
      _animationController.forward();
    }
  }
}
