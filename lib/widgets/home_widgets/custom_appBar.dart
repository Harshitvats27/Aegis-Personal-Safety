import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/quotes.dart';


class CustomAppBar extends StatelessWidget {
  Function? onTap;
  int? quoteIndex;
  CustomAppBar({super.key, this.onTap, this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!();
      },
      child: Container(
        child: Text(
          sweetSayings[quoteIndex!],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}