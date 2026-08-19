import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/firebase_service.dart';

class PromoBannerWidget extends StatelessWidget {
  final VoidCallback onExploreTap;

  const PromoBannerWidget({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService()
          .firestore
          .collection('advertisements')
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final adverts = snapshot.data?.docs ?? [];
        if (adverts.isEmpty) {
          return _buildBanner(context, const {}, false);
        }

        adverts.sort((a, b) => ((a.data()['sort_order'] ?? 0) as num)
            .compareTo((b.data()['sort_order'] ?? 0) as num));
        return SizedBox(
          height: 235,
          child: PageView.builder(
            itemCount: adverts.length,
            itemBuilder: (context, index) => _buildBanner(
              context,
              adverts[index].data(),
              true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(
      BuildContext context, Map<String, dynamic> advert, bool fromDatabase) {
    final imageUrl = advert['image_url']?.toString();
    final title = advert['title']?.toString() ?? 'Great Deals.\nEvery Day.';
    final subtitle =
        advert['subtitle']?.toString() ?? 'Shop the best prices on PromoHub.';
    final buttonText = advert['button_text']?.toString() ?? 'EXPLORE NOW';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F7B2D),
        borderRadius: BorderRadius.circular(16.0),
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.38), BlendMode.darken))
            : null,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0F7B2D).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1)),
            const SizedBox(height: 12),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final link = advert['link_url']?.toString();
                if (fromDatabase && link != null && link.isNotEmpty) {
                  await launchUrl(Uri.parse(link),
                      mode: LaunchMode.externalApplication);
                } else {
                  onExploreTap();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: const Color(0xFF0F7B2D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0),
              child: Text(buttonText,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
