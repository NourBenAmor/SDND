// CustomTextFormField.dart
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String decoration;
  final String controllerName;
  final TextAlign alignment;
  final String validation;
  final bool required;

  const CustomTextFormField({super.key, 
    required this.decoration,
    required this.controllerName,
    required this.alignment,
    required this.validation,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(), // You may want to use a controller passed from the parent widget
      textAlign: alignment,
      decoration: InputDecoration(
        labelText: decoration, // Placeholder for your actual decoration
      ),
      validator: (value) {
        // Implement your validation logic based on the 'validation' parameter
        if (required && value?.isEmpty == true) {
          return 'This field is required';
        }
        // Add more validation rules as needed
        return null;
      },
    );
  }
}
