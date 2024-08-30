import 'package:flutter/material.dart';
import 'package:notes/routes/routes_name.dart';
import 'package:notes/view/add_new_notes_view.dart';
import 'package:notes/view/home_view.dart';

class Routes {
  static  Route<dynamic> generateRoutes(RouteSettings setting) {
    switch (setting.name) {
      case RoutesName.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
        );
      case RoutesName.addNewScreen:
        return MaterialPageRoute(
          builder: (context) => const AddNewNotesView(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Text(
                "No Route Found",
                style: TextStyle(fontFamily: "Poppins"),
              ),
            );
          },
        );
    }
  }
}
