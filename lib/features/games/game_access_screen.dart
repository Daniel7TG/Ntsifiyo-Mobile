import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction.dart';

class GameAccessScreen extends StatelessWidget {
  final String gameTypeId;
  const GameAccessScreen({super.key, required this.gameTypeId});

  @override
  Widget build(BuildContext context) =>
      const UnderConstructionScreen(title: 'Actividades');
}
