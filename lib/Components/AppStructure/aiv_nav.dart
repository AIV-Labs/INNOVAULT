import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Functions/Providers/app_state_provider.dart';

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

  void chgSelectedPage(String newPage) {
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
                        return isHovered
                            ? Container(
                                height: 170,
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 20,
                                      child: Image.asset(
                                        'assets/Logo_Icons/Logo_v4.png',
                                        height: 170,
                                        filterQuality: FilterQuality.medium,
                                        isAntiAlias: true,
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
                              )
                            : Container(
                                padding: const EdgeInsets.fromLTRB(0, 70, 20, 0),
                                height: 170,
                                // child:  Icon(Icons.account_circle_rounded,  size: 30, shadows: shadowStyle,)
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    fontSize: 40,
                                    shadows: shadowStyle,
                                    fontFamily:
                                        GoogleFonts.fleurDeLeah().fontFamily,
                                    fontWeight: FontWeight.w800,
                                    textBaseline: TextBaseline.alphabetic,
                                    // color: Colors.black.withOpacity(0.6),
                                    color:
                                        const Color(0xFF125773).withOpacity(0.6),
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
      
                  const SizedBox(
                    height: 30,
                  ),
      
                  // List Tiles
      
                  Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.dashboard,
                            title: 'Dashboard',
                            hoveredColor: const Color(0xFFe8cca5),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.schedule,
                            title: 'Scheduling',
                            hoveredColor: const Color(0xFF6b4e71),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.people,
                            title: 'Clients',
                            hoveredColor: const Color(0xFFb75d69),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.attach_money,
                            title: 'Billing',
                            hoveredColor: const Color(0xFF00a878),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.inventory,
                            title: 'Inventory',
                            hoveredColor: const Color(0xFF53687e),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.analytics,
                            title: 'Reports & Analytics',
                            hoveredColor: const Color(0xFFe1aa1e),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                              child: CustomListTile(
                            isVisible: isVisible,
                            icon: Icons.chat,
                            title: 'Communication',
                            hoveredColor: const Color(0xFFa2a77f),
                            chgSelectedPage: chgSelectedPage,
                          )),
                          Expanded(
                            child: CustomListTile(
                              isVisible: isVisible,
                              icon: Icons.settings,
                              title: 'Options',
                              hoveredColor: const Color(0xFF5f797b),
                              chgSelectedPage: chgSelectedPage,
                            ),
                          ),
                        ],
                      )),
      
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
