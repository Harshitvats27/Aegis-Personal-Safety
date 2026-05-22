import 'package:flutter/material.dart';
import '../../utils/quotes.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onTap; // Function? ko standard VoidCallback kiya
  final int? quoteIndex;

  const CustomAppBar({super.key, this.onTap, this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Text(
          sweetSayings[quoteIndex ?? 0],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            // 🔥 TEXT COLOR FIXED FOR DARK/LIGHT MODE
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}