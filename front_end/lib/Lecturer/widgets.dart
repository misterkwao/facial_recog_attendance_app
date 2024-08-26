import 'package:flutter/material.dart';

Widget textfield(IconData icon) {
  return TextFormField(
    cursorColor: Colors.black,
    decoration: InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[300],
      suffixIcon: Icon(icon),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return "Field cannot be empty";
      }
      return null;
    },
  );
}

final formKey = GlobalKey<FormState>();

Widget deleteClass(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 20),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Provide ID to delete class",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Course ID"),
              const SizedBox(height: 10),
              textfield(Icons.abc),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      backgroundColor: WidgetStatePropertyAll(
                          Color.fromRGBO(83, 178, 246, 1)),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                      }
                    },
                    child: const Text("Delete Class"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
