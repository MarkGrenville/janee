import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/app_model.dart';
import '../../providers/apps_provider.dart';
import '../../widgets/swipe_card.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CardSwiperController _swiperController = CardSwiperController();

  List<CardModel> _cards = [];
  bool _isLoading = true;
  String? _selectedAppId;
  DateTime? _cardShownAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppsProvider>().fetchApps();
      _fetchCards();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _fetchCards() async {
    try {
      setState(() => _isLoading = true);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      print('[SwipeScreen] Fetching undecided cards for user: $uid');

      // Get all user decisions to know which cards are already decided
      final decisionsSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('decisions')
          .get();

      final decidedCardIds = decisionsSnap.docs
          .map((d) => d.data()['cardId'] as String?)
          .where((id) => id != null)
          .toSet();

      print('[SwipeScreen] User has ${decidedCardIds.length} existing decisions');

      // Fetch apps to get cards from
      final appsProvider = context.read<AppsProvider>();
      final apps = appsProvider.apps;
      final targetApps = _selectedAppId != null
          ? apps.where((a) => a.id == _selectedAppId).toList()
          : apps;

      List<CardModel> allCards = [];
      for (final app in targetApps) {
        try {
          final cardsSnap = await _firestore
              .collection('apps')
              .doc(app.id)
              .collection('cards')
              .where('status', isEqualTo: 'active')
              .get();

          for (final doc in cardsSnap.docs) {
            if (!decidedCardIds.contains(doc.id)) {
              allCards.add(CardModel.fromFirestore(doc, appId: app.id));
            }
          }
        } catch (e) {
          print('[SwipeScreen] Error fetching cards for app ${app.id}: $e');
        }
      }

      allCards.shuffle();

      print('[SwipeScreen] Found ${allCards.length} undecided cards');

      setState(() {
        _cards = allCards;
        _isLoading = false;
        _cardShownAt = DateTime.now();
      });
    } catch (e) {
      print('[SwipeScreen] Error fetching cards: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDecision(CardModel card, String decision) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final timeToDecisionMs = _cardShownAt != null
          ? now.difference(_cardShownAt!).inMilliseconds
          : null;

      print('[SwipeScreen] Creating decision: $decision for card ${card.id} (${card.title})');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('decisions')
          .add({
        'appId': card.appId,
        'cardId': card.id,
        'cardTitle': card.title,
        'decision': decision,
        'decidedAt': FieldValue.serverTimestamp(),
        'availableSince': card.availableSince != null
            ? Timestamp.fromDate(card.availableSince!)
            : null,
        'timeToDecisionMs': timeToDecisionMs,
        'webhookFired': false,
      });

      _cardShownAt = DateTime.now();
      print('[SwipeScreen] Decision saved successfully');
    } catch (e) {
      print('[SwipeScreen] Error creating decision: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save decision')),
        );
      }
    }
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex >= _cards.length) return false;

    final card = _cards[previousIndex];
    String decision;

    switch (direction) {
      case CardSwiperDirection.right:
        decision = 'yes';
        break;
      case CardSwiperDirection.left:
        decision = 'no';
        break;
      case CardSwiperDirection.top:
        decision = 'skip';
        break;
      default:
        return false;
    }

    _createDecision(card, decision);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final apps = context.watch<AppsProvider>().apps;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'JaNee',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: JaNeeTheme.amber,
          ),
        ),
        actions: [
          if (apps.isNotEmpty)
            PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter by app',
              onSelected: (value) {
                setState(() => _selectedAppId = value);
                _fetchCards();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('All Apps'),
                ),
                ...apps.map((app) => PopupMenuItem(
                      value: app.id,
                      child: Text('${app.icon} ${app.name}'),
                    )),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? _buildEmptyState()
              : _buildSwiper(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: JaNeeTheme.amber.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              'All caught up!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No more cards to decide on.\nSubscribe to more apps or check back later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _fetchCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwiper() {
    return Column(
      children: [
        if (_selectedAppId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Chip(
              label: Text(
                context.read<AppsProvider>().apps
                    .where((a) => a.id == _selectedAppId)
                    .map((a) => '${a.icon} ${a.name}')
                    .firstOrNull ?? 'Filtered',
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() => _selectedAppId = null);
                _fetchCards();
              },
            ),
          ),

        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: _cards.length,
            numberOfCardsDisplayed: _cards.length.clamp(1, 3),
            backCardOffset: const Offset(0, -30),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            onSwipe: _onSwipe,
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
              up: true,
            ),
            cardBuilder: (context, index, horizontalOffset, verticalOffset) {
              if (index >= _cards.length) return const SizedBox.shrink();

              final card = _cards[index];
              final appIcon = context.read<AppsProvider>().apps
                  .where((a) => a.id == card.appId)
                  .map((a) => a.icon)
                  .firstOrNull;

              return SwipeCard(card: card, appIcon: appIcon);
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 24, left: 48, right: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                color: const Color(0xFFE57373),
                label: 'No',
                onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
              ),
              _buildActionButton(
                icon: Icons.arrow_upward,
                color: const Color(0xFFBA68C8),
                label: 'Skip',
                onPressed: () => _swiperController.swipe(CardSwiperDirection.top),
                small: true,
              ),
              _buildActionButton(
                icon: Icons.check,
                color: const Color(0xFF81C784),
                label: 'Yes',
                onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
    bool small = false,
  }) {
    final size = small ? 48.0 : 64.0;
    final iconSize = small ? 24.0 : 32.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: iconSize),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
