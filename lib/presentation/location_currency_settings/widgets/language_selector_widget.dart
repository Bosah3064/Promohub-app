import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'hi', 'name': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'sw', 'name': 'Kiswahili', 'flag': '🇰🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLanguage = _languages.firstWhere(
      (lang) => lang['code'] == selectedLanguage,
      orElse: () => _languages.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.language,
            color: Colors.purple[700],
            size: 22.0,
          ),
        ),
        title: Text(
          'Language',
          style: GoogleFonts.inter(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              currentLanguage['flag']!,
              style: GoogleFonts.inter(fontSize: 16.0),
            ),
            SizedBox(width: 2.w),
            Text(
              currentLanguage['name']!,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              height: 60.h,
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text(
                    'Select Language',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _languages.length,
                      itemBuilder: (context, index) {
                        final language = _languages[index];
                        final isSelected = language['code'] == selectedLanguage;

                        return ListTile(
                          leading: Text(
                            language['flag']!,
                            style: GoogleFonts.inter(fontSize: 18.0),
                          ),
                          title: Text(
                            language['name']!,
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.grey[800],
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue[700],
                                  size: 22.0,
                                )
                              : null,
                          onTap: () {
                            onLanguageChanged(language['code']!);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
