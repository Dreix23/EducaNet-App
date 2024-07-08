import 'package:flutter/material.dart';

class ChildrenDropdown extends StatelessWidget {
  final List<String> children;
  final String selectedChild;
  final Function(String) onChildSelected;

  ChildrenDropdown({
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: DropdownButtonFormField<String>(
          value: selectedChild.isNotEmpty ? selectedChild : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Selecciona un hijo',
            prefixIcon: Icon(Icons.child_care, color: Colors.pink),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            isDense: true,
          ),
          items: children.map<DropdownMenuItem<String>>((String child) {
            return DropdownMenuItem<String>(
              value: child,
              child: Text(child),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChildSelected(newValue);
            }
          },
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colors.pink),
          elevation: 0,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}
