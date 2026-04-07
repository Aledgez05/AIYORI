import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'meds_track_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildQuickActionsGrid(BuildContext context) {
    const items = [
      _ActionItem(icon: Icons.add_circle_outline, label: 'New'),
      _ActionItem(icon: Icons.medical_services_outlined, label: 'Log Medication'),
      _ActionItem(icon: Icons.search, label: 'Search'),
      _ActionItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
      _ActionItem(icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => _ActionTile(
                item: item,
                onTap: () => _onActionTap(context, item.label),
              ))
          .toList(),
    );
  }

  void _onActionTap(BuildContext context, String label) {
    switch (label) {
      case 'Log Medication':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedsTrackScreen()),
        );
        break;
      default:
        break;
    }
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedsTrackScreen()),
      );
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        currentIndex: 0,
        onTap: (index) => _onBottomNavTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Med Track'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeBanner(),
                    const SizedBox(height: 28),
                    _SectionLabel('Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 28),
                    _SectionLabel('Recent'),
                    const SizedBox(height: 12),
                    _RecentList(),
                    const SizedBox(height: 32),
                    _ContactFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}

// TOP BAR
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AIYORI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// WELCOME BANNER
class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Everything is ready for you. What will we do today?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION LABEL
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  const _ActionItem({required this.icon, required this.label});
}

// ACTION TILE
class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  final VoidCallback? onTap;

  const _ActionTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.softShadow,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// RECENT LIST
class _RecentList extends StatelessWidget {
  static const _items = [
    _RecentItem(title: 'Medication A', subtitle: '2h ago'),
    _RecentItem(title: 'Medication B', subtitle: 'Yesterday'),
    _RecentItem(title: 'Medication C', subtitle: '3 days ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items.map((item) => _RecentTile(item: item)).toList(),
    );
  }
}

class _RecentItem {
  final String title, subtitle;
  const _RecentItem({required this.title, required this.subtitle});
}

// RECENT TILE
class _RecentTile extends StatelessWidget {
  final _RecentItem item;
  const _RecentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                Text(item.subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

// CONTACT FOOTER
class _ContactFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.support_agent_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Therapist Contact',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          _ContactRow(icon: Icons.person_outline, label: 'Name', value: 'Your full name'),
          _ContactRow(icon: Icons.email_outlined, label: 'Email', value: 'your@email.com'),
          _ContactRow(icon: Icons.phone_outlined, label: 'Phone', value: '+52 000 000 0000'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}