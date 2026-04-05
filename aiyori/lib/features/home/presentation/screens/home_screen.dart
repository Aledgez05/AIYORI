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
      _ActionItem(icon: Icons.add_circle_outline,  label: 'Nuevo'),
      _ActionItem(icon: Icons.medical_services_outlined, label: 'Add Med intake'),
      _ActionItem(icon: Icons.search,              label: 'Buscar'),
      _ActionItem(icon: Icons.bar_chart_rounded,   label: 'Stats'),
      _ActionItem(icon: Icons.settings_outlined,   label: 'Config'),
      
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) => _ActionTile(
        item: item,
        onTap: () => _onActionTap(context, item.label),
      )).toList(),
    );
  }

  void _onActionTap(BuildContext context, String label) {
    switch (label) {
      case 'Add Med intake':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedsTrackScreen()),
        );
        break;
      // Add other cases if needed
      default:
        // Do nothing or show a snackbar
        break;
    }
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 1: // Med Track
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedsTrackScreen()),
        );
        break;
      // Add other cases if needed
      default:
        // Do nothing
        break;
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
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: 0,
        elevation: 0,
        onTap: (index) => _onBottomNavTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),     label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Med Track'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined),  label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),    label: 'Profile'),
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

// — Barra superior con nombre de la app y notificaciones —
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre de la app — 
          const Text(
            'AIYORI',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textOnDark),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// — Banner de bienvenida —
class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        //deprecated, pero da un efecto sutil de fondo, se puede ajustar o eliminar
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Ícono decorativo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 24),
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
                  'Here everything is ready for you. What will we do today?',
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

// — Etiqueta de seccion —
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
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  const _ActionItem({required this.icon, required this.label});
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  final VoidCallback? onTap;
  const _ActionTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(item.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(item.label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// — Lista de elementos recientes —
class _RecentList extends StatelessWidget {
  static const _items = [
    _RecentItem(title: 'Elemento 1', subtitle: 'Hace 2h'),
    _RecentItem(title: 'Elemento 2', subtitle: 'Ayer'),
    _RecentItem(title: 'Elemento 3', subtitle: 'Hace 3 días'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items
          .map((item) => _RecentTile(item: item))
          .toList(),
    );
  }
}

class _RecentItem {
  final String title, subtitle;
  const _RecentItem({required this.title, required this.subtitle});
}

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent.withOpacity(0.15),
            child: const Icon(Icons.folder_outlined, color: AppColors.primary, size: 18),
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

// — Footer de contacto — 
class _ContactFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: const [
              Icon(Icons.support_agent_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Contacto Terapeuta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),

          // ——— Placeholder datos contacto, x ahora terapeuta? ———
          _ContactRow(icon: Icons.person_outline,   label: 'Nombre',    value: 'Tu nombre completo'),
          _ContactRow(icon: Icons.email_outlined,   label: 'Email',     value: 'tucorreo@ejemplo.com'),
          _ContactRow(icon: Icons.phone_outlined,   label: 'Teléfono',  value: '+52 000 000 0000'),
          _ContactRow(icon: Icons.language_outlined, label: 'Web',      value: 'www.tusitio.com'),
          _ContactRow(icon: Icons.location_on_outlined, label: 'Ciudad', value: 'Tu ciudad, País'),
          // —————————————————————————————
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
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}