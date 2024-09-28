import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:notes/data/local/database.dart';
import 'package:notes/utils/app_colors.dart';
import 'package:notes/utils/toast_msg.dart';
import 'add_new_notes_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  List<Map<String, dynamic>> notesList = [];
  List<Map<String, dynamic>> filteredNotesList = [];
  DatabaseHelper? databaseHelperObject;
  TextEditingController searchController = TextEditingController();
  List<bool> expandedStates = [];
  List<bool> showReadMoreButtons = [];

  FocusNode searchFocusNode = FocusNode();

  bool isGalleryView = false; // Boolean for toggling view

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
      expandedStates = List<bool>.filled(notesList.length, false);
      showReadMoreButtons = List<bool>.filled(notesList.length, false);
      _checkReadMoreVisibility();
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

  void _checkReadMoreVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < filteredNotesList.length; i++) {
        final text = filteredNotesList[i][databaseHelperObject!.tableThirdColumnIsDescription];
        final textSpan = TextSpan(
          text: text,
          style: const TextStyle(fontFamily: "Poppins"),
        );
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 3,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 150);
        final didExceedMaxLines = textPainter.didExceedMaxLines;

        if (didExceedMaxLines) {
          showReadMoreButtons[i] = true;
        } else {
          showReadMoreButtons[i] = false;
        }
      }
      setState(() {});
    });
  }

  void _handleMenuSelection(String value, int noteId) {
    if (value == 'Update') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewNotesView(
            note: filteredNotesList.firstWhere((note) =>
            note[databaseHelperObject!.tableFirstColumnIsSeNum] == noteId),
          ),
        ),
      ).then((_) => accessNotes());
    } else if (value == 'Delete') {
      databaseHelperObject!.deleteNotes(indexIs: noteId).then((success) {
        if (success) {
          accessNotes();
          setState(() {
            ToastMsg.toastMsg("Deleted");
          });
        } else {
          ToastMsg.toastMsg("Not Deleted");
        }
      });
    }
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isGalleryView = !isGalleryView;
              });
            },
            icon: Icon(
              isGalleryView ? Icons.list_alt : Icons.grid_view, // Icon toggle
              color: Colors.white,
            ),
          )
        ],
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: const Text(
          "NoteBook",
          style: TextStyle(
            color: AppColors.themeTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                focusNode: searchFocusNode,
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
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                onChanged: filterNotes,
              ),
            ),
            Expanded(
              child: filteredNotesList.isNotEmpty
                  ? (isGalleryView
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredNotesList.length,
                itemBuilder: (context, index) {
                  final note = filteredNotesList[index];
                  final noteId = note[databaseHelperObject!.tableFirstColumnIsSeNum];

                  return IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note[databaseHelperObject!.tableSecondColumnIsTitle],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: Colors.grey.shade100,
                                onSelected: (value) => _handleMenuSelection(value, noteId),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Update',
                                    child: Text('Update'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            note[databaseHelperObject!.tableThirdColumnIsDescription],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis, // Add ellipsis if text is long
                            style: const TextStyle(
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : ListView.builder(
                itemCount: filteredNotesList.length,
                itemBuilder: (context, index) {
                  final note = filteredNotesList[index];
                  final noteId = note[databaseHelperObject!.tableFirstColumnIsSeNum];
                  final isExpanded = expandedStates[index];

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          note[databaseHelperObject!.tableSecondColumnIsTitle],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note[databaseHelperObject!.tableThirdColumnIsDescription],
                              maxLines: isExpanded ? null : 3,
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                            if (showReadMoreButtons[index])
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedStates[index] = !isExpanded;
                                  });
                                },
                                child: Text(
                                  isExpanded ? "Hide" : "Read More",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.themeColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          color: Colors.grey.shade100,
                          onSelected: (value) => _handleMenuSelection(value, noteId),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Update',
                              child: Text('Update'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ))
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/json_data/empty.json",
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const Text(
                      "No Notes Available",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewNotesView(),
            ),
          ).then((_) => accessNotes());
        },
        backgroundColor: AppColors.themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
