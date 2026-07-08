import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction.dart';

class GamePlayScreen extends StatelessWidget {
  final String gameTypeId;
  const GamePlayScreen({super.key, required this.gameTypeId});

  @override
  Widget build(BuildContext context) =>
      const UnderConstructionScreen(title: 'Juego');
}
