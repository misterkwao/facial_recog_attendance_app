// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance_app/Providers/admin_page_provider.dart';

import '../../Constants/admin_constants.dart';

import 'admin_widgets.dart';
import 'delete_classloc.dart';

class AllClassLocations extends StatefulWidget {
  const AllClassLocations({super.key});

  @override
  State<AllClassLocations> createState() => _AllClassLocationsState();
}

int selectedClassLoc = 0;

class _AllClassLocationsState extends State<AllClassLocations> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Class Locations",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Consumer<AdminPageProvider>(
              builder: (context, value, child) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.classLocations.length,
                itemBuilder: (context, index) {
                  final classLocation = value.classLocations[index];
                  return Container(
                    width: width,
                    margin: const EdgeInsets.only(bottom: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.grey[300] ?? Colors.black)),
                    child: Row(
                      children: [
                        const SizedBox(
                            height: 50,
                            child: VerticalDivider(
                                color: Colors.blue, thickness: 5)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Container(
                            child: Text(
                              classLocation["class_name"],
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      classLocation["college_location"],
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                PopupMenuButton(
                                  color: Colors.white,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () {
                                        selectedClassLoc = index;
                                        modalSheet(context, 0.4, width, height,
                                            const DeleteClassloc());
                                      },
                                      child: const Text(
                                        "Delete Class Location",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  ],
                                  child: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              createClassLoc(context, height, width),
            ],
          ),
        ],
      ),
    );
  }
}
