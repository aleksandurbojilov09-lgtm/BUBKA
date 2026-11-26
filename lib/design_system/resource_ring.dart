import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Presentation-only contract. Business persistence and notification thresholds
/// intentionally belong to later phases.
enum ResourceState { unknown, daysOnly, future, active, due, overdue }

enum ResourceChoice {
  insurance('Гражданска отговорност'),
  inspection('Технически преглед'),
  vignette('Винетка'),
  oil('Смяна на масло'),
  service('Друг сервизен интервал'),
  tax('Данък МПС');

  const ResourceChoice(this.label);
  final String label;
}

@immutable
class ResourceView {
  const ResourceView({
    this.state = ResourceState.unknown,
    this.fraction,
    this.remaining,
    this.unit = 'дни',
  });
  final ResourceState state;
  final double? fraction;
  final int? remaining;
  final String unit;
  static DateTime _day(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
  factory ResourceView.calendar({
    required DateTime today,
    DateTime? start,
    DateTime? end,
  }) {
    if (end == null) return const ResourceView();
    final now = _day(today), finish = _day(end);
    final days = finish.difference(now).inDays;
    if (start != null) {
      final begin = _day(start);
      final total = finish.difference(begin).inDays;
      if (total <= 0) return const ResourceView();
      if (now.isBefore(begin)) {
        return const ResourceView(state: ResourceState.future);
      }
      return ResourceView(
        state: days < 0
            ? ResourceState.overdue
            : days == 0
            ? ResourceState.due
            : ResourceState.active,
        fraction: (days / total).clamp(0.0, 1.0).toDouble(),
        remaining: days,
      );
    }
    return ResourceView(
      state: days < 0
          ? ResourceState.overdue
          : days == 0
          ? ResourceState.due
          : ResourceState.daysOnly,
      remaining: days,
    );
  }
  factory ResourceView.service({int? lastKm, int? intervalKm, int? currentKm}) {
    if (lastKm == null ||
        intervalKm == null ||
        currentKm == null ||
        lastKm < 0 ||
        currentKm < lastKm ||
        intervalKm <= 0) {
      return const ResourceView(unit: 'км');
    }
    final left = lastKm + intervalKm - currentKm;
    return ResourceView(
      state: left < 0
          ? ResourceState.overdue
          : left == 0
          ? ResourceState.due
          : ResourceState.active,
      fraction: (left / intervalKm).clamp(0.0, 1.0).toDouble(),
      remaining: left,
      unit: 'км',
    );
  }
  String get status => switch (state) {
    ResourceState.unknown => 'Няма данни',
    ResourceState.daysOnly => 'Известен срок · без процент',
    ResourceState.future => 'Предстоящ период',
    ResourceState.active => 'Оставащ ресурс',
    ResourceState.due => 'Достигнат срок',
    ResourceState.overdue => 'Просрочено',
  };
  String get metric => remaining == null
      ? '—'
      : '${remaining!.abs()} ${unit == 'дни' && remaining!.abs() == 1 ? 'ден' : unit}';
  String get semanticLabel =>
      '$status, $metric${fraction == null ? '' : ', ${(fraction! * 100).round()}%'}';
  Color get color =>
      state == ResourceState.due || state == ResourceState.overdue
      ? const Color(0xFFE76269)
      : resourceColor(fraction);
}

Color resourceColor(double? fraction) {
  const unknown = Color(0xFF94969C);
  const stops = <double>[0, .05, .25, .5, 1];
  const colors = <Color>[
    Color(0xFFE76269),
    Color(0xFFE76269),
    Color(0xFFE59F50),
    Color(0xFFE5C957),
    Color(0xFF4BC58F),
  ];
  if (fraction == null || !fraction.isFinite) return unknown;
  final value = fraction.clamp(0.0, 1.0).toDouble();
  if (value == 0) return colors.first;
  for (var i = 1; i < stops.length; i++) {
    if (value == stops[i]) return colors[i];
    if (value < stops[i]) {
      return Color.lerp(
        colors[i - 1],
        colors[i],
        (value - stops[i - 1]) / (stops[i] - stops[i - 1]),
      )!;
    }
  }
  return colors.last;
}

class ResourceRingPainter extends CustomPainter {
  const ResourceRingPainter(this.resource, {this.progress = 1});
  final ResourceView resource;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.shortestSide * 8.5 / 270;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 127 / 270;
    if (radius <= 0) {
      return;
    }
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    track.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF56565A), Color(0xFF35363A), Color(0xFF252629)],
      stops: [0, .45, 1],
    ).createShader(rect);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 3
        ..color = const Color(0xFF19191C),
    );
    canvas.drawCircle(center, radius, track);
    canvas.drawCircle(
      center,
      radius - width * .46,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .6
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF545459), Color(0xFF232428), Color(0xFF393A3D)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius + width * .48,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF68696D), Color(0xFF27282B), Color(0xFF45464A)],
        ).createShader(rect),
    );
    final fraction = resource.fraction;
    final color = resource.color;
    if (fraction != null && fraction > 0 && progress > 0) {
      final sweep =
          fraction.clamp(0.0, 1.0).toDouble() * progress * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            for (final factor in [.54, .8, 1.07, 1.14, 1.0, .68])
              Color.fromARGB(
                255,
                (color.r * 255 * factor).round().clamp(0, 255).toInt(),
                (color.g * 255 * factor).round().clamp(0, 255).toInt(),
                (color.b * 255 * factor).round().clamp(0, 255).toInt(),
              ),
          ],
          stops: const [0, .28, .47, .57, .72, 1],
        ).createShader(rect);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 1.35
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .10)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
      );
      canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
      final lip = Rect.fromCircle(center: center, radius: radius + width * .34);
      canvas.drawArc(
        lip,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: .12),
              Colors.white.withValues(alpha: .55),
              Colors.white.withValues(alpha: .08),
            ],
          ).createShader(rect),
      );
    }
    if (resource.state == ResourceState.due ||
        resource.state == ResourceState.overdue) {
      canvas.drawCircle(
        center.translate(0, -radius),
        width * .7,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(ResourceRingPainter oldDelegate) =>
      oldDelegate.resource != resource || oldDelegate.progress != progress;
}
