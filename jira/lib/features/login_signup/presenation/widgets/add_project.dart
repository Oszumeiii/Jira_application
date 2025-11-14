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



  Widget buildDropdown( String selectedType, void Function(void Function()) setState) {
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
        DropdownMenuItem(value: "Software", child: Text("Software")),
        DropdownMenuItem(value: "Service", child: Text("Service Desk")),
        DropdownMenuItem(value: "Marketing", child: Text("Marketing")),
        DropdownMenuItem(value: "Business", child: Text("Business")),
      ],
      onChanged: (val) => setState(() => selectedType = val!),
    );
  }



  Widget buildDropdownProjecType( String selectedType, void Function(void Function()) setState) {
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
        DropdownMenuItem(value: "Low", child: Text("Low")),
        DropdownMenuItem(value: "Medium", child: Text("Medium")),
        DropdownMenuItem(value: "High", child: Text("High")),
      ],
      onChanged: (val) => setState(() => selectedType = val!),
    );
  }

