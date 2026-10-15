import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/ceo_modals.dart';

/// Module 12: My Profile & Settings
/// Implements CEO profile dossier, security policies, typography/monochrome architecture confirmation, sync controls, and session exit
class CeoProfileSettingsPage extends StatelessWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoProfileSettingsPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Header
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text('Executive Overview', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFADB5BD)),
              Text('My Profile & Settings', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Executive Profile & System Settings',
            style: GoogleFonts.instrumentSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF212529), letterSpacing: -0.5),
          ),
          const SizedBox(height: 3),
          Text(
            'Digital identity, security configuration, aesthetic parameters, and active ERP session.',
            style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
          ),
          const SizedBox(height: 20),

          // CEO Profile Card (Responsive Layout)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;

                final avatar = Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      erp.currentUserName.isNotEmpty ? erp.currentUserName[0] : 'C',
                      style: GoogleFonts.instrumentSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                );

                final detailsCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          erp.currentUserName,
                          style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212529),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CHIEF EXECUTIVE OFFICER',
                            style: GoogleFonts.instrumentSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${erp.currentUserEmail} • ID: ${erp.currentUserId}',
                      style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct Reports: 5 Department Heads (Vikram S., Rajesh K., Ananya S., Sneha K., Siddharth R.)',
                      style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF495057), fontWeight: FontWeight.w500),
                    ),
                  ],
                );

                final signOutBtn = OutlinedButton.icon(
                  onPressed: () => CeoModals.showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFE03131)),
                  label: Text('Sign Out', style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFFE03131))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFC9C9)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatar,
                          const SizedBox(width: 14),
                          Expanded(child: detailsCol),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(alignment: Alignment.centerRight, child: signOutBtn),
                    ],
                  );
                }

                return Row(
                  children: [
                    avatar,
                    const SizedBox(width: 18),
                    Expanded(child: detailsCol),
                    const SizedBox(width: 14),
                    signOutBtn,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Brand & Aesthetic Architecture Spec Card (Specification Section 1)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF212529)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Brand & Aesthetic Architecture Verification',
                        style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Adheres strictly to Digital Inertia monochromatic brand specification.',
                  style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF6C757D)),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    return GridView.count(
                      crossAxisCount: isNarrow ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isNarrow ? 1.15 : 1.35,
                      children: [
                        _buildColorSwatch('#212529', 'Primary Dark', 'Headers, active items & typography', const Color(0xFF212529), Colors.white),
                        _buildColorSwatch('#F5F6F7', 'Background', 'Secondary surfaces & inputs', const Color(0xFFF5F6F7), const Color(0xFF212529)),
                        _buildColorSwatch('#FFFFFF', 'Card Surface', 'White cards, tables, widgets', Colors.white, const Color(0xFF212529), hasBorder: true),
                        _buildColorSwatch('Instrument Sans', 'Typography', 'Bold titles & clean regular text', const Color(0xFF212529), Colors.white),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security & Synchronization Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security & Session Controls',
                  style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                ),
                const SizedBox(height: 14),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fingerprint_rounded, size: 22, color: Color(0xFF212529)),
                  title: Text('Biometric Authentication & MFA', style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  subtitle: Text('Enforce biometric or MFA prompt on financial approval executions.', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                  trailing: Switch(value: true, activeColor: const Color(0xFF212529), onChanged: (_) {}),
                ),
                const Divider(height: 16, color: Color(0xFFE9ECEF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sync_rounded, size: 22, color: Color(0xFF212529)),
                  title: Text('Real-Time Cloud Synchronization', style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  subtitle: Text('Continuous bi-directional synchronization with Digital Inertia ERP database.', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFEBFBEE), borderRadius: BorderRadius.circular(6)),
                    child: Text('LIVE API SYNC', style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF2F9E44))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String code, String title, String desc, Color bg, Color fg, {bool hasBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasBorder ? const Color(0xFFDEE2E6) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(code, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w800, color: fg), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: fg), overflow: TextOverflow.ellipsis),
          Text(desc, style: GoogleFonts.instrumentSans(fontSize: 9.5, color: fg.withOpacity(0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
