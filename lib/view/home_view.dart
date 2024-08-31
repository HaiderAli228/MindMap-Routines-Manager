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
  List<Map<String, dynamic>> notesList = [];
  List<Map<String, dynamic>> filteredNotesList = [];
  DatabaseHelper? databaseHelperObject;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseHelperObject = DatabaseHelper.getInstance;
    accessNotes();
  }

  void accessNotes() async {
    notesList = await databaseHelperObject!.fetchAllNotes();
    setState(() {
      filteredNotesList = notesList;
    });
  }

  void filterNotes(String query) {
    final filtered = notesList.where((note) {
      final title = note[databaseHelperObject!.tableSecondColumnIsTitle]
          .toString()
          .toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredNotesList = filtered;
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                hintText: "Search by Title",
                hintStyle: const TextStyle(fontFamily: "Poppins"),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
              ),
              onChanged: filterNotes,
            ),
          ),
          Expanded(
            child: filteredNotesList.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredNotesList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            filteredNotesList[index][
                                databaseHelperObject!.tableSecondColumnIsTitle],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                overflow: TextOverflow.ellipsis),
                          ),
                          subtitle: Text(
                            filteredNotesList[index][databaseHelperObject!
                                .tableThirdColumnIsDescription],
                            maxLines: 3,
                            style: const TextStyle(
                                fontFamily: "Poppins",
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      );
                    },
                  )
                : const SingleChildScrollView(
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60,),
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
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.themeColor,
        child: const Icon(
          Icons.add,
          size: 30,
          color: AppColors.themeTextColor,
        ),
        onPressed: () async {
          // Wait for the result from the AddNewNotesView
          final isNewNoteAdded = await Navigator.pushNamed<bool?>(
            context,
            RoutesName.addNewScreen,
          );
          // If a new note was added, refresh the notes list
          if (isNewNoteAdded == true) {
            accessNotes();
          }
        },
      ),
    );
  }
}
