import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivad_app/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../widgets/app_drawer.dart';

// Campaign model
class Campaign {
  final String id;
  final String title;
  final String description;
  final String budget;
  final String duration;
  final String impressions;
  final String reach;
  final String location;
  final String applicants;
  final String drivers;
  final bool isActive;
  final String advertiserId;
  final DateTime? createdAt;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.duration,
    required this.impressions,
    required this.reach,
    required this.location,
    required this.applicants,
    required this.drivers,
    this.isActive = true,
    required this.advertiserId,
    this.createdAt,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      budget: data['budget'] ?? '\$0',
      duration: data['duration'] ?? '0 days',
      impressions: data['impressions'] ?? '0',
      reach: data['reach'] ?? '0',
      location: data['location'] ?? '',
      applicants: data['applicants']?.toString() ?? '0',
      drivers: data['drivers']?.toString() ?? '0',
      isActive: data['isActive'] ?? true,
      advertiserId: data['advertiserId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'budget': budget,
      'duration': duration,
      'impressions': impressions,
      'reach': reach,
      'location': location,
      'applicants': int.tryParse(applicants) ?? 0,
      'drivers': int.tryParse(drivers) ?? 0,
      'isActive': isActive,
      'advertiserId': advertiserId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class CampaignsPage extends StatefulWidget {
  final AuthService auth;

  const CampaignsPage({super.key, required this.auth});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _logout() async => widget.auth.logout();

  Future<AppRole> _loadRole() async {
    final uid = widget.auth.currentUser?.uid;
    if (uid == null) return AppRole.driver;
    final role = (await widget.auth.getOrCreateUserRole(uid)).toLowerCase();
    return role == 'advertiser' ? AppRole.advertiser : AppRole.driver;
  }

  Future<void> _createCampaign(Campaign campaign) async {
    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('campaigns')
          .doc(campaign.id)
          .set(campaign.toFirestore());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCampaign(Campaign campaign) async {
    final lp = Provider.of<LanguageProvider>(context, listen: false);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(lp.translate('delete_campaign')),
        content: Text('Delete "${campaign.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lp.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(lp.translate('delete')),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _firestore.collection('campaigns').doc(campaign.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${campaign.title} deleted'),
            action: SnackBarAction(
              label: lp.translate('undo'),
              onPressed: () => _createCampaign(campaign),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editCampaign(Campaign campaign) async {
    final lp = Provider.of<LanguageProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: campaign.title);
    final budgetController = TextEditingController(
      text: campaign.budget.replaceAll('\$', ''),
    );
    final durationController = TextEditingController(
      text: campaign.duration.replaceAll(' days', ''),
    );
    final locationController = TextEditingController(text: campaign.location);
    final descController = TextEditingController(text: campaign.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(lp.translate('edit_campaign')),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: lp.translate('campaign_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: lp.translate('description'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: budgetController,
                        decoration: InputDecoration(
                          labelText: lp.translate('budget'),
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: durationController,
                        decoration: InputDecoration(
                          labelText: lp.translate('duration_days'),
                          suffixText: 'days',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final days = int.tryParse(v);
                          if (days == null) return 'Invalid number';
                          if (days < 30) return 'Must be at least 30 days';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: lp.translate('location'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lp.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() == true) {
                await _firestore
                    .collection('campaigns')
                    .doc(campaign.id)
                    .update({
                      'title': titleController.text,
                      'description': descController.text,
                      'budget': '\$${budgetController.text}',
                      'duration': '${durationController.text} days',
                      'location': locationController.text,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lp.translate('campaign_updated')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(lp.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(LanguageProvider lp) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final budgetController = TextEditingController();
    final durationController = TextEditingController();
    final locationController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(lp.translate('create_campaign')),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: lp.translate('campaign_name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: lp.translate('description'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: budgetController,
                          decoration: InputDecoration(
                            labelText: lp.translate('budget'),
                            prefixText: '\$',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: InputDecoration(
                            labelText: lp.translate('duration_days'),
                            suffixText: 'days',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final days = int.tryParse(v);
                            if (days == null) return 'Invalid number';
                            if (days < 30) return 'Must be at least 30 days';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: lp.translate('location'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lp.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() == true) {
                        final userId = widget.auth.currentUser?.uid;
                        if (userId == null) return;

                        final newCampaign = Campaign(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          description: descController.text,
                          budget: '\$${budgetController.text}',
                          duration: '${durationController.text} days',
                          impressions: '0',
                          reach: '0',
                          location: locationController.text,
                          applicants: '0',
                          drivers: '0',
                          isActive: true,
                          advertiserId: userId,
                          createdAt: DateTime.now(),
                        );

                        setDialogState(() => _isLoading = true);
                        await _createCampaign(newCampaign);
                        setDialogState(() => _isLoading = false);
                        if (mounted) Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(lp.translate('create')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    const currentRoute = '/campaigns';

    return FutureBuilder<AppRole>(
      future: _loadRole(),
      builder: (context, snap) {
        final role = snap.data ?? AppRole.driver;
        final isAdvertiser = role == AppRole.advertiser;
        final userId = widget.auth.currentUser?.uid;

        return Scaffold(
          backgroundColor: const Color(0xfff5f6fa),
          drawer: isMobile
              ? AppDrawer(
                  role: role,
                  activeRoute: currentRoute,
                  onLogout: _logout,
                )
              : null,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              isAdvertiser
                  ? lp.translate('my_campaigns')
                  : lp.translate('campaigns'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => lp.toggleLanguage(),
                icon: const Icon(Icons.language),
              ),
              if (isAdvertiser)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) => ElevatedButton.icon(
                      onPressed: () => _showCreateDialog(lp),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        isMobile
                            ? lp.translate('create')
                            : lp.translate('create_campaign'),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: isAdvertiser
              ? _buildAdvertiserView(lp, userId)
              : _buildDriverView(lp),
        );
      },
    );
  }

  Widget _buildAdvertiserView(LanguageProvider lp, String? userId) {
    if (userId == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('campaigns')
          .where('advertiserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('failed-precondition')) {
            return const Center(
              child: Text('Create Firestore index for campaigns'),
            );
          }
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final campaigns =
            snapshot.data?.docs
                .map((doc) => Campaign.fromFirestore(doc))
                .toList() ??
            [];

        if (campaigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  lp.translate('no_campaigns'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(lp),
                  icon: const Icon(Icons.add),
                  label: Text(lp.translate('create_first_campaign')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: campaigns.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  lp.translate('my_campaigns'),
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
            final campaign = campaigns[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCampaignCard(lp, campaign),
            );
          },
        );
      },
    );
  }

  Widget _buildCampaignCard(LanguageProvider lp, Campaign campaign) {
    return Dismissible(
      key: Key(campaign.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lp.translate('delete_campaign')),
            content: Text('Delete "${campaign.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(lp.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(lp.translate('delete')),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteCampaign(campaign),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          campaign.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: campaign.isActive
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          campaign.isActive
                              ? lp.translate('active')
                              : lp.translate('pending'),
                          style: TextStyle(
                            color: campaign.isActive
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (campaign.description.isNotEmpty)
                    Text(
                      campaign.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _infoColumn(lp.translate('budget'), campaign.budget),
                      _infoColumn(lp.translate('duration'), campaign.duration),
                      _infoColumn(
                        lp.translate('applicants'),
                        campaign.applicants,
                      ),
                      _infoColumn(lp.translate('drivers'), campaign.drivers),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _iconInfo(Icons.track_changes, campaign.impressions),
                      _iconInfo(
                        Icons.person_pin_circle_outlined,
                        campaign.reach,
                      ),
                      _iconInfo(Icons.location_on_outlined, campaign.location),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _editCampaign(campaign),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(lp.translate('edit')),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _deleteCampaign(campaign),
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(lp.translate('delete')),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverView(LanguageProvider lp) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('campaigns')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final campaigns =
            snapshot.data?.docs
                .map((doc) => Campaign.fromFirestore(doc))
                .toList() ??
            [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lp.translate('available_campaigns'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 24),
                if (campaigns.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 60,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${lp.translate('available_campaigns')}: 0",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Check back later for new opportunities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...campaigns.map(
                    (campaign) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildReadOnlyCard(lp, campaign),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyCard(LanguageProvider lp, Campaign campaign) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: campaign.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    campaign.isActive
                        ? lp.translate('active')
                        : lp.translate('pending'),
                    style: TextStyle(
                      color: campaign.isActive
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (campaign.description.isNotEmpty)
              Text(
                campaign.description,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _infoColumn(lp.translate('budget'), campaign.budget),
                _infoColumn(lp.translate('duration'), campaign.duration),
                _infoColumn(lp.translate('applicants'), campaign.applicants),
                _infoColumn(lp.translate('drivers'), campaign.drivers),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _iconInfo(Icons.track_changes, campaign.impressions),
                _iconInfo(Icons.person_pin_circle_outlined, campaign.reach),
                _iconInfo(Icons.location_on_outlined, campaign.location),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                ),
                child: Text(lp.translate('view_applicants')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    ],
  );
  Widget _iconInfo(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
      ),
    ],
  );
}
