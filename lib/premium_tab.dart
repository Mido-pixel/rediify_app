// premium_tab.dart
// Full-screen Premium tab — extracted from DashboardScreen.
// Features a Spotify-style plan picker with crown/premium icons.

import 'package:flutter/material.dart';

class _C {
  static const bg       = Color(0xFF121212);
  static const surface  = Color(0xFF1A1A1A);
  static const elevated = Color(0xFF242424);
  static const red      = Color(0xFFE8173A);
  static const green    = Color(0xFF1DB954);
  static const text     = Color(0xFFFFFFFF);
  static const sub      = Color(0xFFB3B3B3);
  static const muted    = Color(0xFF535353);
}

class PremiumTab extends StatefulWidget {
  const PremiumTab({super.key});

  @override
  State<PremiumTab> createState() => _PremiumTabState();
}

class _PremiumTabState extends State<PremiumTab> {
  int _selectedPlan = 1; // default to Premium

  final _plans = const [
    _Plan(
      name: 'Free',
      price: 'KSh 0/mo',
      color: Color(0xFF535353),
      icon: Icons.radio_outlined,
      features: [
        'Ads between songs',
        'Shuffle only',
        'Standard audio quality',
        'No offline downloads',
        'Basic listening stats',
      ],
    ),
    _Plan(
      name: 'Premium',
      price: 'KSh 399/mo',
      color: Color(0xFFE8173A),
      icon: Icons.workspace_premium,
      features: [
        'Zero ads — pure music',
        'Play any song, any order',
        'High-quality audio (320 kbps)',
        'Offline downloads',
        'Full stats & listening insights',
        'YouTube search integration',
        'Lyrics view',
      ],
      badge: 'MOST POPULAR',
    ),
    _Plan(
      name: 'Family',
      price: 'KSh 599/mo',
      color: Color(0xFF1565C0),
      icon: Icons.family_restroom,
      features: [
        'Everything in Premium',
        'Up to 6 accounts',
        'Family Mix playlist',
        'Parental controls',
        'Individual recommendations per user',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner ───────────────────────────────────
          _HeroBanner(),
          const SizedBox(height: 28),

          const Text(
            'Choose your plan',
            style: TextStyle(
              color: _C.text, fontSize: 20, fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upgrade anytime. Cancel whenever.',
            style: TextStyle(color: _C.sub, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── Plan cards ────────────────────────────────────
          ..._plans.asMap().entries.map((e) {
            final i    = e.key;
            final plan = e.value;
            return _PlanCard(
              plan: plan,
              isSelected: _selectedPlan == i,
              onTap: () => setState(() => _selectedPlan = i),
            );
          }),

          const SizedBox(height: 24),

          // ── CTA button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _selectedPlan == 0
                  ? null
                  : () => _showSubscribeDialog(context),
              icon: Icon(
                _plans[_selectedPlan].icon,
                color: Colors.white,
              ),
              label: Text(
                _selectedPlan == 0
                    ? 'Currently on Free'
                    : 'Subscribe to ${_plans[_selectedPlan].name}',
                style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _plans[_selectedPlan].color,
                disabledBackgroundColor: _C.muted,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: _plans[_selectedPlan].color.withOpacity(0.4),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Secure payment  •  Cancel anytime',
              style: TextStyle(color: _C.muted, fontSize: 12),
            ),
          ),

          const SizedBox(height: 32),

          // ── Feature comparison highlights ────────────────
          _FeatureHighlights(),
        ],
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context) {
    final plan = _plans[_selectedPlan];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(plan.icon, color: plan.color, size: 28),
            const SizedBox(width: 10),
            Text(
              'Subscribe to ${plan.name}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You will be charged ${plan.price} starting today.',
              style: const TextStyle(color: _C.sub),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.lock, color: _C.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Encrypted & secure  •  Cancel in one tap',
                    style: TextStyle(color: _C.sub, fontSize: 12),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now', style: TextStyle(color: _C.sub)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome to ${plan.name}! 🎉'),
                  backgroundColor: _C.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: plan.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8173A), Color(0xFF7B0D1E), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8173A).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 14),
                      SizedBox(width: 4),
                      Text('PREMIUM', style: TextStyle(
                        color: Color(0xFFFFD700), fontSize: 11,
                        fontWeight: FontWeight.w800, letterSpacing: 1.5,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Unlock the full\nREdiify experience',
                  style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No ads. No limits. Just music.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Large crown icon
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 42),
          ),
        ],
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? plan.color.withOpacity(0.10) : _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? plan.color : const Color(0xFF282828),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: plan.color.withOpacity(0.2), blurRadius: 12)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? plan.color.withOpacity(0.2)
                        : _C.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(plan.icon,
                      color: isSelected ? plan.color : _C.sub, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(plan.name,
                              style: TextStyle(
                                color: isSelected ? plan.color : _C.text,
                                fontSize: 16, fontWeight: FontWeight.w800,
                              )),
                          if (plan.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(plan.badge!,
                                  style: const TextStyle(
                                    color: Colors.black, fontSize: 9,
                                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                                  )),
                            ),
                          ],
                        ],
                      ),
                      Text(plan.price,
                          style: TextStyle(
                            color: isSelected ? plan.color : _C.sub,
                            fontSize: 13, fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? plan.color : _C.muted,
                  size: 22,
                ),
              ],
            ),

            // Feature list
            if (isSelected) ...[
              const SizedBox(height: 14),
              ...plan.features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Icon(Icons.check_circle, color: plan.color, size: 15),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(color: _C.text, fontSize: 13)),
                    ]),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Feature highlights ────────────────────────────────────────
class _FeatureHighlights extends StatelessWidget {
  final _items = const [
    (Icons.block,              Color(0xFFE8173A), 'Zero ads',         'Uninterrupted listening'),
    (Icons.download_outlined,  Color(0xFF1DB954), 'Offline mode',     'Listen anywhere, no data needed'),
    (Icons.high_quality,       Color(0xFF1565C0), 'HD Audio',         '320 kbps crystal clear sound'),
    (Icons.bar_chart,          Color(0xFF6A1B9A), 'Deep stats',       'Your music personality, revealed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why go Premium?',
          style: TextStyle(
            color: _C.text, fontSize: 18, fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ..._items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.$2.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: item.$2.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.$1, color: item.$2, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$3,
                          style: const TextStyle(
                              color: _C.text, fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text(item.$4,
                          style: const TextStyle(color: _C.sub, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            )),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────
class _Plan {
  final String name;
  final String price;
  final Color color;
  final IconData icon;
  final List<String> features;
  final String? badge;

  const _Plan({
    required this.name,
    required this.price,
    required this.color,
    required this.icon,
    required this.features,
    this.badge,
  });
}