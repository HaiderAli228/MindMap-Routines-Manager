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
    databaseHelperObject = DatabaseHelper.getInstance;

    if (widget.note != null) {
      titleController.text =
          widget.note![databaseHelperObject!.tableSecondColumnIsTitle];
      descriptionController.text =
          widget.note![databaseHelperObject!.tableThirdColumnIsDescription];
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage("assets/images/2.png"),
                  height: 200,
                  fit: BoxFit.cover,
                ),
                TextFormFields(
                  controllerValue: titleController,
                  hintText: "Enter Title Here",
                ),
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
                const SizedBox(
                  height: 200,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
