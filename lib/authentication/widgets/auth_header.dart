import 'package:flutter/material.dart';
import '../theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoSize;
  final bool logoLeft; // register design: crest at the top-left
  final bool serifSubtitle; // login design: serif subtitle

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 90,
    this.logoLeft = false,
    this.serifSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/prison.jpg',
      height: logoSize,
      errorBuilder: (_, _, _) =>
          Icon(Icons.shield, size: logoSize, color: Colors.amber),
    );

    final content = Column(children: [
      if (!logoLeft) ...[logo, const SizedBox(height: 12)],
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: serifSubtitle ? 20 : 17,
          fontFamily: serifSubtitle ? 'Times New Roman' : null,
          fontFamilyFallback: serifSubtitle ? const ['serif'] : null,
        ),
      ),
    ]);

    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        width: double.infinity,
        color: kGreen,
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 16,
          20,
          70,
        ),
        child: logoLeft
            ? Stack(children: [
                Align(alignment: Alignment.topLeft, child: logo),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: content,
                ),
              ])
            : content,
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(0, s.height - 45)
    ..quadraticBezierTo(s.width / 2, s.height + 25, s.width, s.height - 45)
    ..lineTo(s.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
