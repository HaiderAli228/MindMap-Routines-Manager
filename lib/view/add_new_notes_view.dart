import 'package:flutter/material.dart';
import 'package:notes/utils/button.dart';
import 'package:notes/utils/text_form_fields.dart';
import 'package:notes/utils/toast_msg.dart';

import '../utils/app_colors.dart';

class AddNewNotesView extends StatefulWidget {
  const AddNewNotesView({super.key});

  @override
  State<AddNewNotesView> createState() => _AddNewNotesViewState();
}

class _AddNewNotesViewState extends State<AddNewNotesView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: const Text(
          "Add New Notes",
          style: TextStyle(
              color: AppColors.themeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins"),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                            text: "Save",
                            onTapFunction: () {
                              titleController.clear();
                              descriptionController.clear();
                            })),
                    Expanded(
                        child: AppButton(
                            text: "Cancel",
                            onTapFunction: () {
                              ToastMsg.toastMsg("Cancelled");
                              Navigator.pop(context);
                            })),
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
    );
  }
}
