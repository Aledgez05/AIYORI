import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _WelcomeCard(),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Acciones rápidas'),
                const SizedBox(height: 12),
                _QuickActionsGrid(),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Recientes'),
                const SizedBox(height: 12),
                _RecentList(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  // — AppBar con degradado en la imagen de cabecera —
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(color: AppColors.textOnDark, fontSize: 18),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textOnDark),
          onPressed: () {},
        ),
      ],
    );
  }
}

// — Tarjeta de bienvenida destacada —
class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('¡Hola de nuevo!',
                    style: TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Aquí está tu resumen del día.',
                    style: TextStyle(color: AppColors.accentSoft, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.emoji_nature_rounded, size: 52, color: AppColors.accentSoft),
        ],
      ),
    );
  }
}

// — Título de sección reutilizable —
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// — Grid de acciones rápidas —
class _QuickActionsGrid extends StatelessWidget {
  // Datos de ejemplo; luego vendrán de un model/provider
  static const _items = [
    {'icon': Icons.add_circle_outline, 'label': 'Nuevo'},
    {'icon': Icons.search,             'label': 'Buscar'},
    {'icon': Icons.bar_chart_rounded,  'label': 'Stats'},
    {'icon': Icons.settings_outlined,  'label': 'Config'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _items.map((item) => _ActionTile(
        icon: item['icon'] as IconData,
        label: item['label'] as String,
      )).toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// — Lista de items recientes —
class _RecentList extends StatelessWidget {
  // Placeholder; se conectará a un repositorio real
  static const _items = ['Elemento 1', 'Elemento 2', 'Elemento 3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items.map((name) => _RecentTile(name: name)).toList(),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final String name;
  const _RecentTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accentSoft,
          child: const Icon(Icons.folder_outlined, color: AppColors.primary),
        ),
        title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: const Text('Hace 2h', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {},
      ),
    );
  }
}

// — Barra de nav inferior —
class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded),    label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),   label: 'Perfil'),
      ],
    );
  }
}