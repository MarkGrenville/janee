import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../models/app_model.dart';

class AppDetailScreen extends StatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  List<CardModel> _cards = [];
  List<DecisionModel> _decisions = [];
  bool _isLoadingCards = true;
  bool _isLoadingDecisions = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCards();
    _fetchDecisions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCards() async {
    try {
      print('[AppDetail] Fetching cards for app: ${widget.app.id}');
      final snap = await _firestore
          .collection('apps')
          .doc(widget.app.id)
          .collection('cards')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _cards = snap.docs
            .map((doc) => CardModel.fromFirestore(doc, appId: widget.app.id))
            .toList();
        _isLoadingCards = false;
      });
      print('[AppDetail] Loaded ${_cards.length} cards');
    } catch (e) {
      print('[AppDetail] Error fetching cards: $e');
      setState(() => _isLoadingCards = false);
    }
  }

  Future<void> _fetchDecisions() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      print('[AppDetail] Fetching decisions for app: ${widget.app.id}');
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('decisions')
          .where('appId', isEqualTo: widget.app.id)
          .orderBy('decidedAt', descending: true)
          .get();

      setState(() {
        _decisions = snap.docs
            .map((doc) => DecisionModel.fromFirestore(doc))
            .toList();
        _isLoadingDecisions = false;
      });
      print('[AppDetail] Loaded ${_decisions.length} decisions');
    } catch (e) {
      print('[AppDetail] Error fetching decisions: $e');
      setState(() => _isLoadingDecisions = false);
    }
  }

  Future<void> _showAddCardDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Card',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Card title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        print('[AppDetail] Adding card: ${titleController.text}');
        await _firestore
            .collection('apps')
            .doc(widget.app.id)
            .collection('cards')
            .add({
          'title': titleController.text.trim(),
          'subtitle': '',
          'description': descriptionController.text.trim(),
          'imageUrl': '',
          'linkUrl': '',
          'icon': '',
          'status': 'active',
          'webhookUrl': '',
          'metadata': {},
          'createdAt': FieldValue.serverTimestamp(),
          'availableSince': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        });

        print('[AppDetail] Card added successfully');
        _fetchCards();
      } catch (e) {
        print('[AppDetail] Error adding card: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add card')),
          );
        }
      }
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = widget.app.ownerId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.app.name,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: JaNeeTheme.amber,
          labelColor: JaNeeTheme.amber,
          unselectedLabelColor: isDark
              ? JaNeeTheme.ivory.withAlpha(128)
              : JaNeeTheme.jet.withAlpha(128),
          tabs: const [
            Tab(text: 'Cards'),
            Tab(text: 'Decisions'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? JaNeeTheme.amber.withAlpha(26)
                        : JaNeeTheme.amber.withAlpha(38),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.app.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.app.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.app.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.app.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardsTab(),
                _buildDecisionsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: _showAddCardDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCardsTab() {
    if (_isLoadingCards) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 48,
              color: JaNeeTheme.amber.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text('No cards yet', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return Card(
          child: ListTile(
            leading: card.icon.isNotEmpty
                ? Text(card.icon, style: const TextStyle(fontSize: 24))
                : const Icon(Icons.style_outlined),
            title: Text(card.title),
            subtitle: card.description.isNotEmpty
                ? Text(
                    card.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: card.status == 'active'
                    ? JaNeeTheme.sage.withAlpha(51)
                    : JaNeeTheme.rose.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.status,
                style: TextStyle(
                  fontSize: 12,
                  color: card.status == 'active' ? JaNeeTheme.sage : JaNeeTheme.rose,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecisionsTab() {
    if (_isLoadingDecisions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_decisions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote_outlined,
              size: 48,
              color: JaNeeTheme.amber.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text('No decisions yet', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _decisions.length,
      itemBuilder: (context, index) {
        final decision = _decisions[index];
        final decisionIcon = switch (decision.decision) {
          'yes' => Icons.check_circle,
          'no' => Icons.cancel,
          'skip' => Icons.skip_next,
          _ => Icons.help_outline,
        };
        final decisionColor = switch (decision.decision) {
          'yes' => const Color(0xFF81C784),
          'no' => const Color(0xFFE57373),
          'skip' => const Color(0xFFBA68C8),
          _ => Colors.grey,
        };

        return Card(
          child: ListTile(
            leading: Icon(decisionIcon, color: decisionColor, size: 28),
            title: Text(decision.cardTitle.isNotEmpty ? decision.cardTitle : decision.cardId),
            subtitle: decision.decidedAt != null
                ? Text(
                    _formatDate(decision.decidedAt!),
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            trailing: Text(
              decision.decision.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: decisionColor,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
