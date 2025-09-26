import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool showDatabaseHelp;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.showDatabaseHelp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon ?? Icons.error_outline,
              size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
          if (showDatabaseHelp) ...[
            const SizedBox(height: 16),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('Database Setup Required',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700)),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          'It looks like the database tables have not been created yet. Please run the following command:',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.orange.shade700)),
                      const SizedBox(height: 8),
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('supabase db push',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.grey.shade800))),
                    ])),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('Try Again',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12))),
          ],
        ]));
  }
}
