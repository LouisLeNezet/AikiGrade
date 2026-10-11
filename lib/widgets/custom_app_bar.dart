import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:aikigrade/widgets/centered_constrained.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // Reduced height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60.0,
      backgroundColor: AppColors.headerColor,
      automaticallyImplyLeading: false,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.headerTitleColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,

      title: CenteredConstrained(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_minimalist_black.png', height: 45),
            const SizedBox(width: 20),
            const Text(
              'AïkiGrade',
              style: TextStyle(
                fontSize: 30,
                color: AppColors.headerTitleColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Katana',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
