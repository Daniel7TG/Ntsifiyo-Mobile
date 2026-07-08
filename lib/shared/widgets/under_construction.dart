import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme.dart';

/// Pantalla temporal mientras se implementa una sección.
class UnderConstructionScreen extends StatelessWidget {
  final String title;
  const UnderConstructionScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svgs/construction.svg',
                width: 96, height: 96),
            const SizedBox(height: 16),
            Text(
              'Muy pronto',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
