import 'package:flutter/material.dart';

class OnboardingGraphic extends StatelessWidget {
  final int pageIndex;
  final bool isDark;

  const OnboardingGraphic({
    super.key,
    required this.pageIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return _buildDiscoveryGraphic();
      case 1:
        return _buildConnectGraphic();
      case 2:
      default:
        return _buildGrowthGraphic();
    }
  }

  // Slide 1: Discovery & Verified Search
  Widget _buildDiscoveryGraphic() {
    final cardBg = isDark ? const Color(0xFF141416) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF28282D) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF18181B);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final pillBg = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF4F4F5);

    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient circular ring
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                width: 1.5,
              ),
            ),
          ),

          // Central Main Card
          Positioned(
            top: 45,
            child: Container(
              width: 230,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.black : Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Directory',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Doctors, Advocates, Retail',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress or mock sector pills
                  Row(
                    children: [
                      _buildChip(
                        icon: Icons.location_on_rounded,
                        text: 'Surat',
                        pillBg: pillBg,
                        textCol: textPrimary,
                        borderCol: cardBorder,
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        icon: Icons.verified_rounded,
                        text: 'Verified',
                        pillBg: pillBg,
                        textCol: textPrimary,
                        borderCol: cardBorder,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Badge Top-Left: Doctor
          Positioned(
            top: 15,
            left: 20,
            child: _buildFloatingBadge(
              icon: Icons.medical_services_rounded,
              title: 'Dr. Mehul Desai',
              subtitle: 'Doctor • 4.9 ★',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // Floating Badge Bottom-Right: Advocates
          Positioned(
            bottom: 25,
            right: 20,
            child: _buildFloatingBadge(
              icon: Icons.gavel_rounded,
              title: 'RP Consultancy',
              subtitle: 'Advocates • Sector 1',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // Floating Micro Pin
          Positioned(
            bottom: 30,
            left: 38,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '100+ Sectors',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Connect & Instant Call/WhatsApp
  Widget _buildConnectGraphic() {
    final cardBg = isDark ? const Color(0xFF141416) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF28282D) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF18181B);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Waves
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                width: 1.5,
              ),
            ),
          ),

          // Center Profile Connect Card
          Positioned(
            top: 40,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        child: Text(
                          'DA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Darshan Patel',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Available Now',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionCircle(
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        bgColor: isDark ? Colors.white : Colors.black,
                        iconColor: isDark ? Colors.black : Colors.white,
                        textColor: textPrimary,
                      ),
                      _buildActionCircle(
                        icon: Icons.chat_bubble_rounded,
                        label: 'WhatsApp',
                        bgColor: const Color(0xFF25D366),
                        iconColor: Colors.white,
                        textColor: textPrimary,
                      ),
                      _buildActionCircle(
                        icon: Icons.near_me_rounded,
                        label: 'Direction',
                        bgColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        iconColor: textPrimary,
                        textColor: textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Badge Left
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Direct Contact',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Badge Bottom
          Positioned(
            bottom: 22,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Zero Middlemen',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Growth & List Enterprise
  Widget _buildGrowthGraphic() {
    final cardBg = isDark ? const Color(0xFF141416) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF28282D) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF18181B);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Aura
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                width: 1.5,
              ),
            ),
          ),

          // Central Business Portfolio Mockup Card
          Positioned(
            top: 40,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOUR ENTERPRISE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Madhav Retail & Store',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Seller & Distributor • Surat, Gujarat',
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Growth metrics mini bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cardBorder, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '5.0 ★',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                'Top Rating',
                                style: TextStyle(fontSize: 9.5, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cardBorder, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Multi-Biz',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                'Supported',
                                style: TextStyle(fontSize: 9.5, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Badge Top
          Positioned(
            top: 15,
            right: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Grow Network',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Badge Bottom-Left
          Positioned(
            bottom: 25,
            left: 20,
            child: _buildFloatingBadge(
              icon: Icons.storefront_rounded,
              title: 'RP Consultancy',
              subtitle: 'Associated Enterprise',
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String text,
    required Color pillBg,
    required Color textCol,
    required Color borderCol,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textCol),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textCol),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: textPrimary),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
