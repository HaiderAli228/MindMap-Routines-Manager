import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        centerTitle: true,
        title: const Text(
          "New Notes",
          style: TextStyle(
              color: AppColors.themeTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins"),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: TextFormField(
                  controller: titleController,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Study Time",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      label: const Text("Title"),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
