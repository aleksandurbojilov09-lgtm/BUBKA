import 'package:material_ui/material_ui.dart';
import 'package:flutter/painting.dart' as painting;

import 'theme.dart';
import 'cockpit_assets.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.selected = false,
    this.radius = 18,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final bool selected;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: selected
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF39342E), Color(0xFF252527), Color(0xFF1B1C20)],
              stops: [0, .52, 1],
            )
          : BubkaDesign.cardGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected
            ? BubkaDesign.goldHighlight
            : BubkaDesign.border.withValues(alpha: .45),
        width: selected ? 1.6 : 1,
      ),
      boxShadow: selected
          ? const [
              BoxShadow(color: Color(0x2AE6BD7E), blurRadius: 16),
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x28000000),
                blurRadius: 9,
                offset: Offset(0, 4),
              ),
            ],
    ),
    child: Stack(
      children: [
        if (selected)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: const CockpitAsset(
                  'surfaces/selected_inner_glow.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(padding: padding, child: child),
          ),
        ),
        if (selected)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SelectedBorder(radius)),
            ),
          ),
      ],
    ),
  );
}

class RegistrationPlate extends StatelessWidget {
  const RegistrationPlate({
    super.key,
    this.number,
    this.compact = false,
    this.showCountry = true,
  });
  final String? number;
  final bool compact;
  final bool showCountry;
  @override
  Widget build(BuildContext context) {
    final hasNumber = number?.trim().isNotEmpty ?? false;
    if (!hasNumber) {
      return const Text(
        'Без регистрационен номер',
        style: TextStyle(color: BubkaDesign.muted, fontSize: 13),
      );
    }
    final style = TextStyle(
      color: const Color(0xFF101114),
      fontWeight: FontWeight.w700,
      fontSize: compact ? 15 : 17,
      letterSpacing: .2,
    );
    const bgStyle = TextStyle(color: BubkaDesign.text, fontSize: 12);
    double width(String text, TextStyle textStyle) {
      final painter = painting.TextPainter(
        text: painting.TextSpan(
          text: text,
          style: DefaultTextStyle.of(context).style.merge(textStyle),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final result = painter.width;
      painter.dispose();
      return result;
    }

    final padding = compact ? 7.0 : 10.0;
    final needed =
        width(number!, style) +
        (showCountry ? width('BG', bgStyle) + 16 : 0) +
        padding * 2 +
        4;
    return Semantics(
      label: 'Регистрационен номер $number',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final row = Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showCountry)
                  Container(
                    color: const Color(0xFF33373F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: const Text('BG', style: bgStyle),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 2,
                  ),
                  child: Text(
                    number!,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),
              ],
            );
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFF0),
                border: Border.all(color: BubkaDesign.goldDark),
                borderRadius: BorderRadius.circular(6),
              ),
              child: needed > constraints.maxWidth
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: row,
                    )
                  : row,
            );
          },
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      backgroundColor: BubkaDesign.accent,
      foregroundColor: BubkaDesign.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.title,
    required this.detail,
    this.action,
  });
  final String title, detail;
  final Widget? action;
  @override
  Widget build(BuildContext context) => PremiumCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BubkaDesign.muted),
        ),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class PremiumField extends StatelessWidget {
  const PremiumField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.hint,
    this.onChanged,
    this.error,
    this.enabled = true,
  });
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hint, error;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(hintText: hint, errorText: error),
        ),
      ],
    ),
  );
}

class DashedCardBorder extends CustomPainter {
  const DashedCardBorder();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.6),
          const Radius.circular(22),
        ),
      );
    final paint = Paint()
      ..color = const Color(0xFF77777E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 11) {
        final end = d + 6 < metric.length ? d + 6 : metric.length;
        canvas.drawPath(metric.extractPath(d, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedCardBorder oldDelegate) => false;
}

class _SelectedBorder extends CustomPainter {
  const _SelectedBorder(this.radius);
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0C8),
            Color(0xFFDFB779),
            Color(0xFFA9814D),
            Color(0xFFF0C88C),
          ],
          stops: [0, .35, .7, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_SelectedBorder oldDelegate) =>
      oldDelegate.radius != radius;
}
