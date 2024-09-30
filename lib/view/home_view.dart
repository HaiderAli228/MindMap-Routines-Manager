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
  List<Map<String, dynamic>> notesList = []; // List to hold all notes.
  List<Map<String, dynamic>> filteredNotesList =
      []; // List to hold filtered notes.
  DatabaseHelper?
      databaseHelperObject; // Database helper object to interact with the local database.
  TextEditingController searchController =
      TextEditingController(); // Controller for search field.
  List<bool> expandedStates =
      []; // List to manage expanded/collapsed states of list items.
  List<bool> showReadMoreButtons =
      []; // List to manage visibility of "Read More" buttons.
  FocusNode searchFocusNode = FocusNode(); // Focus node for search field.
  bool isGalleryView =
      false; // Boolean to toggle between list and gallery view.

  @override
  void initState() {
    super.initState();
    databaseHelperObject =
        DatabaseHelper.getInstance; // Initialize the database helper.
    accessNotes(); // Fetch notes from the database on initialization.
  }

  // Fetch all notes from the database and reverse the list to show the latest first.
  void accessNotes() async {
    notesList = await databaseHelperObject!.fetchAllNotes();
    notesList = notesList.reversed.toList();

    // Update state to populate filtered notes and manage expanded states and "Read More" visibility.
    setState(() {
      filteredNotesList = notesList;
      expandedStates = List<bool>.filled(notesList.length, false);
      showReadMoreButtons = List<bool>.filled(notesList.length, false);
      _checkReadMoreVisibility(); // Check if notes need a "Read More" button based on content length.
    });
  }

  // Filter notes based on the search query entered by the user.
  void filterNotes(String query) {
    final filtered = notesList.where((note) {
      final title = note[databaseHelperObject!.tableSecondColumnIsTitle]
          .toString()
          .toLowerCase();
      return title
          .contains(query.toLowerCase()); // Match query against note titles.
    }).toList();

    setState(() {
      filteredNotesList = filtered; // Update filtered list based on the query.
    });
  }

  // Check if notes exceed a certain number of lines and should display a "Read More" button.
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
          maxLines: 3, // Set maximum number of lines to check for truncation.
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 150);
        final didExceedMaxLines = textPainter.didExceedMaxLines;

        showReadMoreButtons[i] =
            didExceedMaxLines; // Show button if content exceeds max lines.
      }
      setState(() {}); // Update the state once calculations are done.
    });
  }

  // Handle selection from the options menu (Update or Delete notes).
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
      ).then((_) =>
          accessNotes()); // Refresh notes after returning from the update screen.
    } else if (value == 'Delete') {
      databaseHelperObject!.deleteNotes(indexIs: noteId).then((success) {
        if (success) {
          accessNotes(); // Refresh the list after deletion.
          setState(() {
            ToastMsg.toastMsg("Deleted"); // Show a success message on deletion.
          });
        } else {
          ToastMsg.toastMsg(
              "Not Deleted"); // Show an error message if deletion fails.
        }
      });
    }
  }

  @override
  void dispose() {
    searchFocusNode
        .dispose(); // Dispose the focus node when the widget is removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          // Toggle between list view and grid view.
          IconButton(
            onPressed: () {
              setState(() {
                isGalleryView = !isGalleryView; // Toggle gallery view state.
              });
            },
            icon: Icon(
              isGalleryView
                  ? Icons.list_rounded
                  : Icons.grid_view, // Change icon based on view.
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
          FocusScope.of(context)
              .unfocus(); // Unfocus search field when tapping outside.
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // Search field for filtering notes by title.
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
                  onChanged:
                      filterNotes, // Call filter function when the search query changes.
                ),
              ),
              Expanded(
                child: filteredNotesList.isNotEmpty
                    ? (isGalleryView
                        ? MasonryGridView.count(
                            crossAxisCount:
                                2, // Display notes in two columns (grid view).
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
                                    // Note title with menu options.
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
                                                  noteId), // Handle menu actions.
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
                                    // Note description.
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
                            itemCount:
                                filteredNotesList.length, // List view of notes.
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
                                child: ListTile(
                                  title: Text(
                                    note[databaseHelperObject!
                                        .tableSecondColumnIsTitle],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Note description.
                                      Text(
                                        note[databaseHelperObject!
                                            .tableThirdColumnIsDescription],
                                        maxLines: isExpanded ? null : 3,
                                        overflow: isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: "Poppins"),
                                      ),
                                      // Conditionally display "Read More"/"Show Less" button.
                                      if (hasReadMoreButton)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              expandedStates[index] =
                                                  !isExpanded; // Toggle expanded state.
                                            });
                                          },
                                          child: Text(
                                            isExpanded
                                                ? 'Show Less'
                                                : 'Read More', // Text changes based on state.
                                            style: const TextStyle(
                                                fontFamily: "Poppins"),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    color: Colors.grey.shade100,
                                    onSelected: (value) => _handleMenuSelection(
                                        value, noteId), // Handle menu options.
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
                                ),
                              );
                            }))
                    : Lottie.asset(
                        "assets/animations/no_notes.json"), // Display Lottie animation if no notes.
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button to add a new note.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const AddNewNotesView()), // Navigate to add note screen.
          ).then((_) => accessNotes()); // Refresh notes after returning.
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
