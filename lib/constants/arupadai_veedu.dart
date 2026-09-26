import 'package:flutter/material.dart';

/// One of the six Arupadai Veedu -- the sacred abodes of Lord Murugan.
class ArupadaiAbode {
  const ArupadaiAbode({required this.tamilName, required this.icon});

  /// Tamil place name -- matches `temples.name` / `songs.place` exactly,
  /// the join key used to look up this abode's row and songs.
  final String tamilName;

  /// Decorative icon, purely for visual distinction in the grid.
  final IconData icon;
}

/// The six Arupadai Veedu abodes, in traditional order.
class ArupadaiVeedu {
  ArupadaiVeedu._();

  static const List<ArupadaiAbode> abodes = [
    ArupadaiAbode(
      tamilName: 'திருப்பரங்குன்றம்',
      icon: Icons.landscape_outlined, // hillside shrine
    ),
    ArupadaiAbode(
      tamilName: 'திருச்செந்தூர்',
      icon: Icons.waves_outlined, // seashore temple
    ),
    ArupadaiAbode(
      tamilName: 'பழநி',
      icon: Icons.terrain_outlined, // hill temple
    ),
    ArupadaiAbode(
      tamilName: 'சுவாமிமலை',
      icon: Icons.temple_hindu_outlined, // hill of the divine teacher
    ),
    ArupadaiAbode(
      tamilName: 'திருத்தணிகை',
      icon: Icons.forest_outlined, // hill temple
    ),
    ArupadaiAbode(
      tamilName: 'பழமுதிர்ச்சோலை',
      icon: Icons.park_outlined, // forest grove
    ),
  ];
}
