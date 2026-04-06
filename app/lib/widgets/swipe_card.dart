import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_model.dart';
import '../config/theme.dart';

class SwipeCard extends StatelessWidget {
  final CardModel card;
  final String? appIcon;

  const SwipeCard({
    super.key,
    required this.card,
    this.appIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _buildGlassCard(context);
    }
    return _buildElevatedCard(context);
  }

  Widget _buildGlassCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(26),
                Colors.white.withAlpha(13),
              ],
            ),
            border: Border.all(
              color: Colors.white.withAlpha(38),
              width: 1.5,
            ),
          ),
          child: _buildCardContent(context, isDark: true),
        ),
      ),
    );
  }

  Widget _buildElevatedCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: JaNeeTheme.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _buildCardContent(context, isDark: false),
    );
  }

  Widget _buildCardContent(BuildContext context, {required bool isDark}) {
    final textColor = isDark ? JaNeeTheme.ivory : JaNeeTheme.jet;
    final subtitleColor = isDark ? JaNeeTheme.ivory.withAlpha(153) : JaNeeTheme.jet.withAlpha(153);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (card.icon.isNotEmpty || (appIcon != null && appIcon!.isNotEmpty))
            Text(
              card.icon.isNotEmpty ? card.icon : appIcon!,
              style: const TextStyle(fontSize: 64),
            ),
          if (card.icon.isNotEmpty || (appIcon != null && appIcon!.isNotEmpty))
            const SizedBox(height: 24),

          Text(
            card.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          if (card.subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              card.subtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: JaNeeTheme.amber,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (card.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  card.description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
