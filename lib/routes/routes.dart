import 'package:flutter/material.dart';
import 'package:notes/routes/routes_name.dart';
import 'package:notes/view/add_new_notes_view.dart';
import 'package:notes/view/home_view.dart';

class Routes {
  static Route<bool?> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeScreen:
        return MaterialPageRoute<bool?>(
          builder: (context) => const HomeView(),
        );
      case RoutesName.addNewScreen:
        return MaterialPageRoute<bool?>(
          builder: (context) => const AddNewNotesView(),
        );
      default:
        return MaterialPageRoute<bool?>(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "No Route Found",
                  style: TextStyle(fontFamily: "Poppins"),
                ),
              ),
            );
          },
        );
    }
  }
}
