import 'package:flutter/material.dart';
import 'package:notes/data/local/database.dart';
import 'package:notes/routes/routes_name.dart';
import 'package:notes/utils/app_colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool notesStore = false;
  List<Map<String, dynamic>> notesList = [];
  DatabaseHelper? databaseHelperObject;

  @override
  void initState() {
    super.initState();
    databaseHelperObject = DatabaseHelper.getInstance;
    accessNotes();
  }

  void accessNotes() async {
    notesList = await databaseHelperObject!.fetchAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: const Text(
          "Notes",
          style: TextStyle(
              color: AppColors.themeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins"),
        ),
      ),
      body: notesList.isEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(notesList[index].toString()),
                  ),
                  title: Text(
                    notesList[index]
                        [databaseHelperObject!.tableSecondColumnIsTitle],
                    style: const TextStyle(
                        fontFamily: "Poppins", overflow: TextOverflow.ellipsis),
                  ),
                  subtitle: Text(
                    notesList[index]
                        [databaseHelperObject!.tableThirdColumnIsDescription],
                    style: const TextStyle(
                        fontFamily: "Poppins", overflow: TextOverflow.ellipsis),
                  ),
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/1.png"),
                    fit: BoxFit.cover,
                    width: 300,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "No Notes Created Yet",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          backgroundColor: AppColors.themeColor,
          child: const Icon(
            Icons.add,
            size: 30,
            color: AppColors.themeTextColor,
          ),
          onPressed: () {
            Navigator.pushNamed(context, RoutesName.addNewScreen);
          }),
    );
  }
}
