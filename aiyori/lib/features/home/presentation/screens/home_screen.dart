import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'calendar_screen.dart';
import 'checkin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────
              Row(
                children: [
                  Expanded(child: _headerCard()),
                  const SizedBox(width: 16),
                  _emergenciaButton(),
                ],
              ),

              const SizedBox(height: 20),

              // ── Responsive layout ─────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 640;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _leftColumn()),
                        const SizedBox(width: 20),
                        Expanded(child: _rightColumn()),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _leftColumn(),
                      const SizedBox(height: 20),
                      _rightColumn(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // TOP
  // ────────────────────────────────────────────

  Widget _headerCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.favorite_rounded),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu bienestar importa',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Hola, bienvenida',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _pill('Hoy'),
        ],
      ),
    );
  }

  Widget _emergenciaButton() {
    return GestureDetector(
      onTap: () {
        // TODO: acción real
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'EMERGENCIA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  // LEFT
  // ────────────────────────────────────────────

  Widget _leftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Funciones'),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            int count = constraints.maxWidth > 500 ? 3 : 2;

            return GridView.count(
              crossAxisCount: count,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _featureCard(
                  icon: Icons.favorite,
                  label: 'Check-in',
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckInScreen(),
                        ),
                         );
                         },
                         ),

                _featureCard(
                  icon: Icons.calendar_today,
                  label: 'Calendario',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarScreen(),
                        ),
                         );
                          },
                          ),
                          
                 _featureCard(
                  icon: Icons.calendar_today,
                  label: 'Medicacion',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarScreen(),
                        ),
                         );
                          },
                          ),
                 _featureCard(
                  icon: Icons.calendar_today,
                  label: 'Recordatorios',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarScreen(),
                        ),
                         );
                          },
                          ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // RIGHT
  // ────────────────────────────────────────────

  Widget _rightColumn() {
    return Column(
      children: [
        _pinCard(),
        const SizedBox(height: 14),
        _breathingCard(),
        const SizedBox(height: 14),
        _activitiesCard(),
      ],
    );
  }

  Widget _pinCard() {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.lock_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acceso Temporal (PIN)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Gestiona quién ve tus registros',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breathingCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respiración 4-5-4',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _breathStep('4', 'Inhala')),
              _stepSep(),
              Expanded(child: _breathStep('5', 'Sostén')),
              _stepSep(),
              Expanded(child: _breathStep('4', 'Exhala')),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onPressed: () {},
              child: const Text('Iniciar ejercicio'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activitiesCard() {
    return _card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int count = constraints.maxWidth > 500 ? 3 : 2;

          return GridView.count(
            crossAxisCount: count,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _activityCard('Caminar', '5 min'),
              _activityCard('Agua', '2 min'),
              _activityCard('Música', '3 min'),
              _activityCard('Estiramiento', '5 min'),
              _activityCard('Escribir', '3 min'),
              _activityCard('Llamar', '10 min'),
            ],
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  // UI BASE
  // ────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }

Widget _featureCard({
  required IconData icon,
  required String label,
  VoidCallback? onTap,
}) {
  return _HoverCard(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}



  Widget _activityCard(String t, String d) {
    return _card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 10, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(t, style: TextStyle(color: AppColors.textPrimary)),
          Text(d, style: TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _breathStep(String n, String l) {
    return Column(
      children: [
        Text(n,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            )),
        Text(l, style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _stepSep() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text('·'),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverCard({required this.child, this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          transform: isHovering
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}