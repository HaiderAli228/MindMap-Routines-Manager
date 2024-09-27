import 'package:flutter/material.dart';
import 'package:notes/routes/routes_name.dart';
import 'package:notes/view/visual_screen.dart';

import '../view/add_new_notes_view.dart';
import '../view/home_view.dart';

class Routes {
  static Route<bool?> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeScreen:
        return _buildPageRoute(
          const HomeView(),
        );
      case RoutesName.addNewScreen:
        return _buildPageRoute(
          const AddNewNotesView(),
        );
      case RoutesName.visualScreen:
        return _buildPageRoute(
          VisualScreen(
            onDateSelected: (DateTime) {},
            notesList: [],
          ),
        );
      default:
        return _buildPageRoute(
          const Scaffold(
            body: Center(
              child: Text(
                "No Route Found",
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder<bool?> _buildPageRoute(Widget page) {
    return PageRouteBuilder<bool?>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from right to left
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
