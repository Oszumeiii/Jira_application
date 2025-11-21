import 'package:flutter/material.dart';


Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blue[50]?.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }



Widget buildDropdown(
  String selectedType,
  void Function(void Function()) setState,
) {
  return DropdownButtonFormField<String>(
    value: selectedType,
    decoration: InputDecoration(
      labelText: "Project Type",
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: const Icon(
        Icons.category_outlined,
        color: Colors.blueAccent,
      ),
      filled: true,
      fillColor: Colors.blue[50]?.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blueAccent,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    dropdownColor: Colors.white,
    icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
    isExpanded: true,
    items: const [
      DropdownMenuItem(
        value: "Software",
        child: Text("Software Development"),
      ),
      DropdownMenuItem(
        value: "Service",
        child: Text("Service Desk"),
      ),
      DropdownMenuItem(
        value: "Marketing",
        child: Text("Marketing Campaign"),
      ),
      DropdownMenuItem(
        value: "Business",
        child: Text("Business Strategy"),
      ),
    ],
    onChanged: (val) {
      if (val != null) {
        setState(() => selectedType = val);
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a project type';
      }
      return null;
    },
  );
}



Widget buildDropdownPriority(
  String selectedPriority,
  void Function(void Function()) setState,
) {
  return DropdownButtonFormField<String>(
    value: selectedPriority,
    decoration: InputDecoration(
      labelText: "Priority Level",
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: const Icon(
        Icons.flag_outlined,
        color: Colors.blueAccent,
      ),
      filled: true,
      fillColor: Colors.blue[50]?.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blueAccent,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    dropdownColor: Colors.white,
    icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
    isExpanded: true,
    items: [
      DropdownMenuItem(
        value: "Low",
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            const Text("Low Priority"),
          ],
        ),
      ),
      DropdownMenuItem(
        value: "Medium",
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            const Text("Medium Priority"),
          ],
        ),
      ),
      DropdownMenuItem(
        value: "High",
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            const Text("High Priority"),
          ],
        ),
      ),
    ],
    onChanged: (val) {
      if (val != null) {
        setState(() => selectedPriority = val);
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a priority level';
      }
      return null;
    },
  );
}
