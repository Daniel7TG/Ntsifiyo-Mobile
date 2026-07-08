import 'package:flutter/material.dart';

import '../../shared/widgets/under_construction.dart';

class MediaPlayerScreen extends StatelessWidget {
  final int mediaId;
  const MediaPlayerScreen({super.key, required this.mediaId});

  @override
  Widget build(BuildContext context) =>
      const UnderConstructionScreen(title: 'Reproductor');
}
