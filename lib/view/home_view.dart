import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';

import '../data/local/database.dart';
import '../utils/app_colors.dart';
import '../utils/toast_msg.dart';
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
  bool isGalleryView = false;

  @override
  void initState() {
    super.initState();
    databaseHelperObject = DatabaseHelper.getInstance;
    accessNotes();
  }

  void accessNotes() async {
    notesList = await databaseHelperObject!.fetchAllNotes();
    notesList = notesList.reversed.toList();
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
        final text = filteredNotesList[i]
        [databaseHelperObject!.tableThirdColumnIsDescription];
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

        showReadMoreButtons[i] = didExceedMaxLines;
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
    final screenSize = MediaQuery.of(context).size;
    final isWeb = screenSize.width >= 600; // Define a threshold for web layout

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
              isGalleryView ? Icons.list_rounded : Icons.grid_view,
              color: Colors.white,
              size: 25,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 50 : 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
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
                    ? MasonryGridView.count(
                  crossAxisCount: isWeb ? 4 : 2, // Adjust based on screen size
                  itemCount: filteredNotesList.length,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    final note = filteredNotesList[index];
                    final noteId = note[databaseHelperObject!
                        .tableFirstColumnIsSeNum];
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note[databaseHelperObject!
                                      .tableSecondColumnIsTitle],
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
                                onSelected: (value) =>
                                    _handleMenuSelection(value,
                                        noteId),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'Update',
                                      child: Text('Update')),
                                  const PopupMenuItem(
                                      value: 'Delete',
                                      child: Text('Delete')),
                                ],
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            note[databaseHelperObject!
                                .tableThirdColumnIsDescription],
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: "Poppins"),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : ListView.builder(
                  itemCount: filteredNotesList.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotesList[index];
                    final noteId = note[databaseHelperObject!
                        .tableFirstColumnIsSeNum];
                    final isExpanded = expandedStates[index];
                    final hasReadMoreButton =
                    showReadMoreButtons[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note[databaseHelperObject!
                                        .tableSecondColumnIsTitle],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  color: Colors.grey.shade100,
                                  onSelected: (value) =>
                                      _handleMenuSelection(
                                          value, noteId),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'Update',
                                        child: Text('Update')),
                                    const PopupMenuItem(
                                        value: 'Delete',
                                        child: Text('Delete')),
                                  ],
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            AnimatedSize(
                              duration:
                              const Duration(milliseconds: 200),
                              child: Text(
                                note[databaseHelperObject!
                                    .tableThirdColumnIsDescription],
                                maxLines: isExpanded ? null : 3,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                    fontFamily: "Poppins"),
                              ),
                            ),
                            if (hasReadMoreButton)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedStates[index] =
                                    !isExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5),
                                  child: Text(
                                    isExpanded
                                        ? "Read less"
                                        : "Read more",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.themeColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/lottie/noTask.json",
                        height: 200, width: 200),
                    const Text(
                      "No Notes Found",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewNotesView(),
            ),
          ).then((value) => accessNotes());
        },
        backgroundColor: AppColors.themeColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
