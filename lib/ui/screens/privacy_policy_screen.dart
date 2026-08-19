import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTamilContent(context),
            const Divider(height: 32.0, thickness: 1.0),
            _buildEnglishContent(context),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTamilContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'தனியுரிமைக் கொள்கை',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'கடைசியாகப் புதுப்பிக்கப்பட்டது: 18 பிப்ரவரி 2026',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          'திருப்புகழ் செயலி ஒரு ஓப்பன் சோர்ஸ் (Open Source) பயன்பாடாக உருவாக்கப்பட்டுள்ளது. இந்தச் சேவையை டீம் அயிலவன் (Team Ayilavan) இலவசமாக வழங்குகிறது மற்றும் இது "உள்ளபடியே" (as is) பயன்படுத்துவதற்காக அமைக்கப்பட்டுள்ளது.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(context, '1. தகவல் சேகரிப்பு மற்றும் பயன்பாடு'),
        Text(
          'நாங்கள் எந்தவொரு தனிப்பட்ட தகவலையும் சேகரிக்கவோ, சேமிக்கவோ அல்லது பகிரவோ மாட்டோம். இந்தச் செயலியைப் பயன்படுத்த நீங்கள் எந்த தனிப்பட்ட தரவையும் வழங்க வேண்டியதில்லை. தகவல்களைச் சேகரிக்கும் எந்த மூன்றாம் தரப்பு சேவைகளையும் இது பயன்படுத்துவதில்லை, மேலும் இது முற்றிலும் இணைய இணைப்பு இல்லாமலே (offline) செயல்படுகிறது.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '2. அனுமதிகள்'),
        Text(
          'இந்தச் செயலி உங்கள் கேமரா, இருப்பிடம், தொடர்புகள் அல்லது மைக்ரோஃபோன் போன்ற எந்த முக்கியமான அனுமதிகளையும் கோருவதில்லை.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '3. குக்கீகள் மற்றும் ட்ராக்கிங்'),
        Text(
          'இந்தச் செயலி "குக்கீகள்", "வெப் பீக்கன்கள்" அல்லது வேறு எந்த ட்ராக்கிங் தொழில்நுட்பங்களையும் பயன்படுத்துவதில்லை. எந்தவிதமான பகுப்பாய்வு (analytics) அல்லது செயல்த்திறன் அளவீடுகளும் சேகரிக்கப்படுவதில்லை.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '4. தனியுரிமைக் கொள்கையில் மாற்றங்கள்'),
        Text(
          'நாங்கள் அவ்வப்போது இந்த தனியுரிமைக் கொள்கையை புதுப்பிக்கலாம். எனவே, மாற்றங்களை அறிய அவ்வப்போது இந்தப் பக்கத்தை மதிப்பாய்வு செய்யுமாறு அறிவுறுத்தப்படுகிறீர்கள்.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, 'தொடர்புக்கு'),
        Text(
          'எங்கள் தனியுரிமைக் கொள்கை குறித்து ஏதேனும் கேள்விகள் அல்லது பரிந்துரைகள் இருந்தால், teamayilavan@gmail.com என்ற முகவரியில் எங்களைத் தொடர்பு கொள்ள தயங்க வேண்டாம்.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEnglishContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Policy',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Last updated: 18 February 2026',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          'Thiruppugazh is built as an Open Source app. This service is provided by Team Ayilavan at no cost and is intended for use as is.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _buildSectionTitle(context, '1. Information Collection and Use'),
        Text(
          'We do not collect, store, or share any personal information. This app does not require you to provide any personal data, does not use any third-party services that collect information, and operates entirely offline.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '2. Permissions'),
        Text(
          'This app does not request any sensitive permissions (such as access to your camera, location, contacts, or microphone).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '3. Cookies and Tracking'),
        Text(
          'This app does not use "cookies," "web beacons," or any other tracking technologies. No analytics or performance metrics are collected.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, '4. Changes to This Privacy Policy'),
        Text(
          'We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _buildSectionTitle(context, 'Contact Me'),
        Text(
          'If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact us at teamayilavan@gmail.com',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
