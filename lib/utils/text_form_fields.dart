import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class TextFormFields extends StatelessWidget {
  const TextFormFields(
      {this.maxLinesIs,
      required this.hintText,
      required this.controllerValue,
      super.key});
  final TextEditingController controllerValue;
  final String hintText;
  final int? maxLinesIs;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: TextFormField(
        controller: controllerValue,
        validator:
            MultiValidator([RequiredValidator(errorText: "Required ")]).call,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: maxLinesIs ?? 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey.shade200,
          hintText: hintText,
          hintStyle: const TextStyle(fontFamily: "Poppins"),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }
}
