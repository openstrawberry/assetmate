import 'package:flutter/material.dart';

class SimpleCardcCustom extends StatelessWidget {
  final String firstAlpha;

  final String Name;
  Function()? ontap;

  SimpleCardcCustom(
      {required this.ontap,
      required this.firstAlpha,
      required this.Name,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xFFAA32DB), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    firstAlpha,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              Name,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
