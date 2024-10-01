import 'package:flutter/material.dart';
import 'package:notes/utils/button.dart';
import 'package:notes/utils/text_form_fields.dart';
import 'package:notes/utils/toast_msg.dart';
import '../data/local/database.dart';
import '../utils/app_colors.dart';

class AddNewNotesView extends StatefulWidget {
  final Map<String, dynamic>? note;

  const AddNewNotesView({super.key, this.note});

  @override
  State<AddNewNotesView> createState() => _AddNewNotesViewState();
}

class _AddNewNotesViewState extends State<AddNewNotesView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DatabaseHelper? databaseHelperObject;

  @override
  void initState() {
    super.initState();

    // Initialize the database helper object to interact with the local database
    databaseHelperObject = DatabaseHelper.getInstance;

    // If a note was passed (for updating), pre-fill the title and description fields
    if (widget.note != null) {
      titleController.text =
          widget.note![databaseHelperObject!.tableSecondColumnIsTitle];
      descriptionController.text =
          widget.note![databaseHelperObject!.tableThirdColumnIsDescription];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch screen size to make UI responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth > 600; // Check for larger screens like tablets or web

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: Text(
          widget.note == null ? "Add New Notes" : "Update Notes",
          style: const TextStyle(
              color: AppColors.themeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins"),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 100 : 15, // Dynamic horizontal padding
            vertical: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage("assets/images/2.png"),
                  height: isLargeScreen ? 300 : 200, // Adjust image size
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                TextFormFields(
                  controllerValue: titleController,
                  hintText: "Enter Title Here",
                ),
                const SizedBox(height: 20),
                TextFormFields(
                  controllerValue: descriptionController,
                  hintText: "Enter Description Here",
                  maxLinesIs: 6,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                            text: widget.note == null ? "Save" : "Update",
                            onTapFunction: () {
                              if (formKey.currentState!.validate()) {
                                if (widget.note == null) {
                                  // Add new note
                                  databaseHelperObject!
                                      .addNewNotes(
                                    titleIs: titleController.text,
                                    descriptionIs: descriptionController.text,
                                  )
                                      .then((_) {
                                    ToastMsg.toastMsg("New Note Saved");
                                    Navigator.pop(context, true);
                                  });
                                } else {
                                  // Update existing note
                                  databaseHelperObject!
                                      .updateNotes(
                                    titleIs: titleController.text,
                                    descriptionIs: descriptionController.text,
                                    indexIs: widget.note![databaseHelperObject!
                                        .tableFirstColumnIsSeNum],
                                  )
                                      .then((_) {
                                    ToastMsg.toastMsg("Notes Updated");
                                    Navigator.pop(context, true);
                                  });
                                }
                              }
                            }),
                      ),
                      const SizedBox(width: 10), // Add spacing between buttons
                      Expanded(
                        child: AppButton(
                            text: "Cancel",
                            onTapFunction: () {
                              ToastMsg.toastMsg("Cancelled");
                              Navigator.pop(context, false);
                            }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
