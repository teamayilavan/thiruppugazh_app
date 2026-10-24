import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The privacy policy, in Tamil and English. Kept as one screen of fixed text
/// (rather than ARB strings) so both languages are always shown together and
/// stay in step. When the app's behaviour changes, update both sections and
/// [_lastUpdatedEn] / [_lastUpdatedTa].
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _lastUpdatedEn = '24 October 2026';
  static const String _lastUpdatedTa = '24 அக்டோபர் 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPolicy(
              context,
              title: 'தனியுரிமைக் கொள்கை',
              updated: 'கடைசியாகப் புதுப்பிக்கப்பட்டது: $_lastUpdatedTa',
              intro:
                  'திருப்புகழ் செயலி ஒரு ஓப்பன் சோர்ஸ் (Open Source) பயன்பாடாக உருவாக்கப்பட்டுள்ளது. இந்தச் சேவையை டீம் அயிலவன் (Team Ayilavan) இலவசமாக வழங்குகிறது மற்றும் இது "உள்ளபடியே" (as is) பயன்படுத்துவதற்காக அமைக்கப்பட்டுள்ளது.',
              sections: _tamilSections,
              contactTitle: 'தொடர்புக்கு',
              contact:
                  'எங்கள் தனியுரிமைக் கொள்கை குறித்து ஏதேனும் கேள்விகள் அல்லது பரிந்துரைகள் இருந்தால், teamayilavan@gmail.com என்ற முகவரியில் எங்களைத் தொடர்பு கொள்ள தயங்க வேண்டாம்.',
            ),
            const Divider(height: 32.0, thickness: 1.0),
            _buildPolicy(
              context,
              title: 'Privacy Policy',
              updated: 'Last updated: $_lastUpdatedEn',
              intro:
                  'Thiruppugazh is built as an Open Source app. This service is provided by Team Ayilavan at no cost and is intended for use as is.',
              sections: _englishSections,
              contactTitle: 'Contact Us',
              contact:
                  'If you have any questions or suggestions about this Privacy Policy, do not hesitate to contact us at teamayilavan@gmail.com',
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  static const List<(String, String)> _tamilSections = [
    (
      '1. தகவல் சேகரிப்பு மற்றும் பயன்பாடு',
      'நாங்கள் எந்தவொரு தனிப்பட்ட தகவலையும் சேகரிக்கவோ, சேமிக்கவோ அல்லது பகிரவோ மாட்டோம். கணக்குகள், விளம்பரங்கள், பகுப்பாய்வு (analytics), பிழை அறிக்கை சேவைகள் அல்லது தகவல் சேகரிக்கும் மூன்றாம் தரப்பு மென்பொருள் எதுவும் இந்தச் செயலியில் இல்லை. செயலியின் வெளியீட்டுப் பதிப்புக்கு இணைய அனுமதியே இல்லை; எனவே இது தானாகவே எங்களுக்கோ வேறு யாருக்கோ தரவை அனுப்ப முடியாது.',
    ),
    (
      '2. உங்கள் சாதனத்தில் சேமிக்கப்படும் தரவு',
      'நீங்கள் உருவாக்குபவை மட்டுமே சேமிக்கப்படும்: பிடித்த பாடல்கள், நீங்கள் உருவாக்கிய வகைகளின் பெயர்கள், குறிப்புகள், சிறப்பிடங்கள் (highlights), சேமித்த இணைப்புகள் (இணைய முகவரியும் விருப்பமான தலைப்பும்), மற்றும் அமைப்புகள் (மொழி, கருப்பொருள், எழுத்தின் அளவு, தினசரி அறிவிப்பு, சமீபத்தில் திறந்த பாடல்கள், கடைசி தானியங்கி காப்புப்பிரதி நேரம்). இவை செயலியின் தனிப்பட்ட சேமிப்பிடத்தில் உங்கள் சாதனத்திலேயே இருக்கும்; எங்களால் பார்க்க முடியாது. செயலியை நீக்கினாலோ (uninstall), செயலியின் தரவை அழித்தாலோ இவை நீங்கும்; செயலியிலேயே ஒவ்வொன்றையும் நீக்கவும் முடியும்.',
    ),
    (
      '3. காப்புப்பிரதிகள்',
      'அ) ஆண்ட்ராய்டு தானியங்கி காப்புப்பிரதி (Auto Backup): உங்கள் சாதனத்தில் Google காப்புப்பிரதி இயக்கப்பட்டிருந்தால், பிடித்தவை, வகைகள், குறிப்புகள், சிறப்பிடங்கள், இணைப்புகள் மற்றும் அமைப்புகள் அடங்கிய சிறிய கோப்பை ஆண்ட்ராய்டு உங்கள் Google கணக்கில் சேமிக்கலாம். இது Google-ஆல் அதன் விதிமுறைகளின்படி கையாளப்படுகிறது; டீம் அயிலவனால் இதைப் பார்க்கவோ அணுகவோ முடியாது. புதிய சாதனத்தில் அல்லது மீண்டும் நிறுவும்போது தரவை மீட்க இது உதவும். ஆண்ட்ராய்டு அமைப்புகளில் (Google > காப்புப்பிரதி) இதை நிறுத்தலாம் அல்லது நீக்கலாம். பாடல் உரைகள் காப்புப்பிரதியில் சேர்க்கப்படுவதில்லை.\n\nஆ) ஏற்றுமதி / இறக்குமதி: "தரவை ஏற்றுமதி செய்" என்பதைத் தேர்ந்தெடுத்தால், இதே தரவு அடங்கிய கோப்பு உருவாக்கப்பட்டு ஆண்ட்ராய்டின் பகிர்வுத் திரை திறக்கும். அந்தக் கோப்பு எங்கே செல்லும் என்பது நீங்கள் தேர்ந்தெடுக்கும் செயலியைப் பொறுத்தது. ஒரு தற்காலிகப் பிரதி செயலியின் தற்காலிக சேமிப்பில் இருக்கும்; அது பின்னர் தானாக அகற்றப்படும். "இறக்குமதி" நீங்கள் தேர்ந்தெடுக்கும் கோப்பை மட்டுமே படிக்கும். காப்புப்பிரதிகளில் உங்கள் தனிப்பட்ட குறிப்புகள் இருக்கக்கூடும் என்பதால் அவற்றைப் பாதுகாப்பாக வைத்திருங்கள்.',
    ),
    (
      '4. அனுமதிகள்',
      'தினசரி அறிவிப்பை நீங்கள் இயக்கும்போது மட்டுமே அறிவிப்பு அனுமதி கேட்கப்படும்; அந்த அறிவிப்பு முழுமையாக உங்கள் சாதனத்திலேயே இயங்குகிறது. சாதனம் மறுதொடக்கம் செய்யப்பட்ட பின் அறிவிப்பை மீண்டும் அமைக்க "தொடக்கத்தில் இயக்கு" (RECEIVE_BOOT_COMPLETED) என்ற சாதாரண அனுமதியும், அறிவிப்புக்கான அதிர்வு (vibrate) அனுமதியும் பயன்படுத்தப்படுகின்றன. கேமரா, இருப்பிடம், தொடர்புகள், மைக்ரோஃபோன், சேமிப்பகம் அல்லது இணையம் ஆகியவற்றுக்கான அனுமதிகளை இந்தச் செயலி கோருவதில்லை.',
    ),
    (
      '5. பகிர்தலும் இணைப்புகளும்',
      'செயலிக்குப் பகிர்தல்: வேறொரு செயலியிலிருந்து ஒரு இணைப்பை அல்லது உரையை "திருப்புகழ்" செயலிக்குப் பகிரும்போது, அந்த இணைப்பைப் பாடலுடன் சேர்க்க உதவ, அந்த உரையை மட்டும் செயலி படிக்கும். நீங்கள் பாடலைத் தேர்ந்தெடுத்தால் மட்டுமே அது சேமிக்கப்படும்.\n\nசெயலியிலிருந்து பகிர்தல்: பாடல் உரை அல்லது இணைப்பை நீங்கள் தொட்டுப் பகிரும்போது மட்டுமே ஆண்ட்ராய்டின் பகிர்வுத் திரை திறக்கும்.\n\nஇணையதளங்களைத் திறத்தல்: YouTube, Google, Kaumaram.com, Mayuragiri.com, GitHub ஆகியவற்றுக்கான பொத்தான்களும் நீங்கள் சேமித்த இணைப்புகளும், நீங்கள் உறுதிசெய்த பின்னரே உங்கள் உலாவியில் அல்லது தொடர்புடைய செயலியில் திறக்கும். அந்த இணையதளங்கள் வேறு அமைப்புகளால் நடத்தப்படுபவை; அவற்றுக்குத் தனி தனியுரிமைக் கொள்கைகள் உண்டு. நீங்கள் அவற்றைப் பார்வையிட்டதை (தேடல் பொத்தான்களில் பாடலின் தலைப்பைத் தேடல் சொல்லாக) அவை அறியக்கூடும். இவற்றை நாங்கள் கட்டுப்படுத்துவதில்லை.',
    ),
    (
      '6. குக்கீகள் மற்றும் ட்ராக்கிங்',
      'இந்தச் செயலி "குக்கீகள்", "வெப் பீக்கன்கள்" அல்லது வேறு எந்த ட்ராக்கிங் தொழில்நுட்பங்களையும் பயன்படுத்துவதில்லை. எந்தவிதமான பகுப்பாய்வு (analytics) அல்லது செயல்திறன் அளவீடுகளும் சேகரிக்கப்படுவதில்லை.',
    ),
    (
      '7. தனியுரிமைக் கொள்கையில் மாற்றங்கள்',
      'நாங்கள் அவ்வப்போது இந்த தனியுரிமைக் கொள்கையை புதுப்பிக்கலாம். எனவே, மாற்றங்களை அறிய அவ்வப்போது இந்தப் பக்கத்தை மதிப்பாய்வு செய்யுமாறு அறிவுறுத்தப்படுகிறீர்கள்.',
    ),
  ];

  static const List<(String, String)> _englishSections = [
    (
      '1. Information Collection and Use',
      'We do not collect, store, or share any personal information. The app has no accounts, no ads, no analytics, no crash-reporting service and no third-party software that collects information. The release version of the app has no Internet permission, so it cannot send data to us or to anyone else on its own.',
    ),
    (
      '2. Data Kept on Your Device',
      'Only what you create is stored: your favorite songs, the names of categories you make, notes, highlights, saved links (the web address and an optional title), and settings (language, theme, text size, daily reminder, recently opened songs, and the time of the last automatic backup). This stays in the app\'s private storage on your device and we cannot see it. It is removed when you uninstall the app or clear its data, and you can delete each item inside the app.',
    ),
    (
      '3. Backups',
      'a) Android Auto Backup: if Google backup is turned on for your device, Android may save a small file containing your favorites, categories, notes, highlights, links and settings to your Google account. Google handles it under its own terms; Team Ayilavan cannot see or access it. It lets your data come back on a new device or after reinstalling. You can turn it off or delete it in Android settings (Google > Backup). The song texts themselves are not part of the backup.\n\nb) Export / Import: when you choose "Export Data", the app creates a file with the same data and opens Android\'s share sheet. Where that file goes depends on the app you choose. A temporary copy stays in the app\'s cache and is removed automatically later. "Import" reads only the file you pick. Backups can contain your personal notes, so keep them safe.',
    ),
    (
      '4. Permissions',
      'The notification permission is requested only when you turn on the daily reminder, and the reminder runs entirely on your device. A normal "run at startup" permission (RECEIVE_BOOT_COMPLETED) lets the reminder be set again after the device restarts, and a normal vibrate permission is used by notifications. The app does not request access to your camera, location, contacts, microphone, storage or the Internet.',
    ),
    (
      '5. Sharing and Links',
      'Sharing into the app: when you share a link or text from another app to Thiruppugazh, the app reads only that text so you can attach the link to a song. It is saved only if you choose a song.\n\nSharing out: the Android share sheet opens only when you tap to share a song\'s text or link.\n\nOpening websites: the buttons for YouTube, Google, Kaumaram.com, Mayuragiri.com and GitHub, and the links you saved, open in your browser or the matching app only after you confirm. Those sites are run by others and have their own privacy policies. They may learn that you visited them (and, for the search buttons, the song title used as the search term). We do not control them.',
    ),
    (
      '6. Cookies and Tracking',
      'This app does not use "cookies," "web beacons," or any other tracking technologies. No analytics or performance metrics are collected.',
    ),
    (
      '7. Changes to This Privacy Policy',
      'We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes.',
    ),
  ];

  Widget _buildPolicy(
    BuildContext context, {
    required String title,
    required String updated,
    required String intro,
    required List<(String, String)> sections,
    required String contactTitle,
    required String contact,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          updated,
          style: textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(intro, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final (heading, body) in sections) ...[
          _buildSectionTitle(context, heading),
          Text(body, style: textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        _buildSectionTitle(context, contactTitle),
        Text(contact, style: textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).extension<AppColorExtension>()?.textHigh ??
              Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
