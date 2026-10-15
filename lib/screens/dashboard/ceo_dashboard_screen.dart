import 'package:flutter/material.dart';
import '../ceo/pages/ceo_overview_page.dart';

/// Clean CEO Dashboard View embedded into Navigation containers
class CeoDashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const CeoDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return CeoOverviewPage(
      onNavigateModule: (idx) {
        onNavigateTab?.call(idx);
      },
    );
  }
}
