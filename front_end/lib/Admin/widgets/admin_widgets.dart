// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

Widget modalDrag(double width) {
  return Container(
    width: width * 0.3,
    height: 10,
    decoration: BoxDecoration(
        color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
  );
}

Future modalSheet(BuildContext context, double initsize, double width,
    double height, Widget details) {
  return showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    context: context,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initsize,
      builder: (context, scrollController) => Container(
          width: width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadiusDirectional.vertical(top: Radius.circular(30)),
            // color: Color.fromRGBO(83, 178, 246, 1),
          ),
          child: SingleChildScrollView(
              controller: scrollController, child: details)),
    ),
  );
}

Widget options(
    String func,
    Color backcolor,
    Color textcolor,
    BuildContext context,
    double height,
    double width,
    Widget details,
    double initsize) {
  return InkWell(
    onTap: () => showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initsize,
        builder: (context, scrollController) => Container(
            width: width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadiusDirectional.vertical(top: Radius.circular(30)),
              // color: Color.fromRGBO(83, 178, 246, 1),
            ),
            child: SingleChildScrollView(
                controller: scrollController, child: details)),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backcolor,
          boxShadow: const [
            BoxShadow(
                color: Colors.blueAccent,
                spreadRadius: 2,
                offset: Offset(1, 2),
                blurStyle: BlurStyle.inner,
                blurRadius: 3)
          ]),
      child: Text(
        func,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat Bold'),
      ),
    ),
  );
}
