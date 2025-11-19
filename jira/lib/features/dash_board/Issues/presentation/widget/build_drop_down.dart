import 'package:flutter/material.dart';

 Widget buildDropdownIssue( String selectedType, void Function(void Function()) setState) {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: "Project Type",
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blue[50]?.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [

        DropdownMenuItem(value: "Task", child: Text("Task")),
        DropdownMenuItem(value: "Bug", child: Text("Bug")),
        DropdownMenuItem(value: "Story", child: Text("Story")),
        DropdownMenuItem(value: "Epic", child: Text("Epic")),
      ],
      onChanged: (val) => setState(() => selectedType = val!),
    );
  }