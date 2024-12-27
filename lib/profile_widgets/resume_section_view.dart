import 'package:flutter/material.dart';

class ResumeSectionView extends StatelessWidget {
  final Widget resumeWidget;

  const ResumeSectionView({
    Key? key,
    required this.resumeWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: resumeWidget,
    );
  }
}
