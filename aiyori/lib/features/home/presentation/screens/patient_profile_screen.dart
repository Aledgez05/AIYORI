import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/user_service.dart';
import 'profile_completion_screen.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final UserService _userService = UserService();
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;
  String? _generatedPin;
  String? _pinExpiry;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
  }

  Future<void> _generatePin() async {
    if (user == null) return;
    final pin = await _userService.generatePin(user!.uid);
    setState(() {
      _generatedPin = pin;
      _pinExpiry = 'Valid for 24 hours';
    });
    // Refresh user data to show updated PIN status
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }
          final data = snapshot.data!.data()!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(int.parse(data['avatarColor'] ?? '0xFF6EC1C2')),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              data['name']?.substring(0, 1).toUpperCase() ?? '?',
                              style: const TextStyle(fontSize: 36, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['name'] ?? 'No name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['email'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _editProfile(context, data),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPersonalInfoCard(data),
                    const SizedBox(height: 16),
                    _buildEmergencyContactCard(data),
                    const SizedBox(height: 16),
                    _buildProfessionalsCard(data),
                    const SizedBox(height: 16),
                    _buildPinCard(data),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(Map<String, dynamic> data) {
    final user = FirebaseAuth.instance.currentUser;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, 'Name', data['name'] ?? 'Not set'),
            _infoRow(Icons.calendar_today_outlined, 'Birth Date', 
                data['birthDate'] != null ? '${(data['birthDate'] as Timestamp).toDate().day}/${(data['birthDate'] as Timestamp).toDate().month}/${(data['birthDate'] as Timestamp).toDate().year}' : 'Not set'),
            _infoRow(Icons.phone_outlined, 'Phone', data['phone'] ?? 'Not set'),
            _infoRow(Icons.email_outlined, 'Email', data['email'] ?? ''),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.primary),
              title: const Text('Patient UID'),
              subtitle: Text(user!.uid),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: user.uid));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('UID copied to clipboard')),
                  );
                },
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(Map<String, dynamic> data) {
    final contact = data['emergencyContact'] ?? {};
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, 'Name', contact['name'] ?? 'Not set'),
            _infoRow(Icons.phone_outlined, 'Phone', contact['phone'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalsCard(Map<String, dynamic> data) {
    final therapistIds = List<String>.from(data['therapistIds'] ?? []);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Professionals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (therapistIds.isEmpty)
              const Text('No professionals linked yet.', style: TextStyle(color: AppColors.textSecondary))
            else
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _userService.getLinkedProfessionals(user!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final pros = snapshot.data!;
                  return Column(
                    children: pros.map((pro) {
                      return ListTile(
                        leading: Icon(Icons.medical_services, color: AppColors.primary),
                        title: Text(pro['name']),
                        subtitle: Text(pro['professionalType'] == 'psychiatrist' ? 'Psychiatrist' : 'Psychologist'),
                        trailing: IconButton(
                          icon: const Icon(Icons.link_off, color: Colors.red),
                          onPressed: () => _unlinkProfessional(pro['uid']),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showLinkDialog(),
              icon: const Icon(Icons.add_link),
              label: const Text('Link New Professional'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinCard(Map<String, dynamic> data) {
    final hasPin = data['currentPin'] != null;
    final isLinked = (data['therapistIds'] as List?)?.isNotEmpty ?? false;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temporary Access (PIN)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (isLinked)
              const Text('You are already linked to a professional. Generate a new PIN only if you need to add another.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if (_generatedPin != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Your PIN:', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(_generatedPin!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    const SizedBox(height: 4),
                    Text(_pinExpiry!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: hasPin ? null : _generatePin,
              icon: const Icon(Icons.vpn_key),
              label: Text(hasPin ? 'PIN already active' : 'Generate New PIN (24h)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPin ? Colors.grey : AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, Map<String, dynamic> currentData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileCompletionScreen(existingData: currentData)),
    );
    if (result == true) {
      setState(() {
        _userDataFuture = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
      });
    }
  }

  void _showLinkDialog() {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link a Professional'),
        content: TextField(
          controller: pinController,
          decoration: const InputDecoration(labelText: 'Enter PIN (6 digits)'),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 6 digits')));
                return;
              }
              final success = await _userService.linkProfessionalWithPin(pin, user!.uid);
              Navigator.pop(context);
              if (success) {
                setState(() {
                  _userDataFuture = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .get();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Professional linked successfully')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid or expired PIN')));
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }

  void _unlinkProfessional(String proUid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Professional'),
        content: const Text('Are you sure you want to remove this professional?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unlink', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _userService.unlinkProfessional(user!.uid, proUid);
      setState(() {
        _userDataFuture = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Professional unlinked')));
    }
  }
}