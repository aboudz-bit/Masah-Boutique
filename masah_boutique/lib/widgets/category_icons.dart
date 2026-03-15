import 'package:flutter/material.dart';

class AbayaIcon extends StatelessWidget {
  final double size;
  final Color color;
  const AbayaIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.checkroom, size: size, color: color);
  }
}

class JalabiyaIcon extends StatelessWidget {
  final double size;
  final Color color;
  const JalabiyaIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome, size: size, color: color);
  }
}

class DressIcon extends StatelessWidget {
  final double size;
  final Color color;
  const DressIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.celebration, size: size, color: color);
  }
}

class BridalIcon extends StatelessWidget {
  final double size;
  final Color color;
  const BridalIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.favorite, size: size, color: color);
  }
}

class KidsIcon extends StatelessWidget {
  final double size;
  final Color color;
  const KidsIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.child_care, size: size, color: color);
  }
}

class GiftIcon extends StatelessWidget {
  final double size;
  final Color color;
  const GiftIcon({super.key, this.size = 32, this.color = const Color(0xFFC8A96E)});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.card_giftcard, size: size, color: color);
  }
}
