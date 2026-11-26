import 'package:flutter_test/flutter_test.dart';
import 'package:garage/design_system/resource_ring.dart';
import 'package:garage/features/cockpit/cockpit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('resource colors match the approved stops and clamp', () {
    expect(resourceColor(1), const Color(0xFF4BC58F));
    expect(resourceColor(.5), const Color(0xFFE5C957));
    expect(resourceColor(.25), const Color(0xFFE59F50));
    expect(resourceColor(.05), const Color(0xFFE76269));
    expect(resourceColor(0), const Color(0xFFE76269));
    expect(resourceColor(-1), resourceColor(0));
    expect(resourceColor(2), resourceColor(1));
    expect(resourceColor(null), const Color(0xFF94969C));
    expect(resourceColor(double.nan), resourceColor(null));
    expect(
      resourceColor(.75),
      Color.lerp(resourceColor(.5), resourceColor(1), .5),
    );
  });
  test('calendar resource uses real calendar days, not a 30-day window', () {
    final start = DateTime(2026, 1, 1), end = DateTime(2027, 1, 1);
    expect(
      ResourceView.calendar(today: start, start: start, end: end).fraction,
      1,
    );
    final middle = ResourceView.calendar(
      today: DateTime(2026, 7, 2),
      start: start,
      end: end,
    );
    expect(middle.remaining, 183);
    expect(middle.fraction, closeTo(183 / 365, .0001));
    final days = ResourceView.calendar(today: DateTime(2026, 12, 18), end: end);
    expect(days.remaining, 14);
    expect(days.fraction, isNull);
    expect(days.state, ResourceState.daysOnly);
    expect(
      ResourceView.calendar(
        today: DateTime(2025, 12, 31),
        start: start,
        end: end,
      ).state,
      ResourceState.future,
    );
    expect(
      ResourceView.calendar(today: end, start: start, end: end).state,
      ResourceState.due,
    );
    final late = ResourceView.calendar(
      today: DateTime(2027, 1, 2),
      start: start,
      end: end,
    );
    expect(late.fraction, 0);
    expect(late.state, ResourceState.overdue);
    expect(
      ResourceView.calendar(today: start, start: start, end: start).state,
      ResourceState.unknown,
    );
    expect(ResourceView.calendar(today: start).fraction, isNull);
  });
  test('service presentation reflects the approved example', () {
    ResourceView at(int km) =>
        ResourceView.service(lastKm: 180000, intervalKm: 10000, currentKm: km);
    expect(at(180000).fraction, 1);
    expect(at(185000).fraction, .5);
    expect(at(185000).remaining, 5000);
    expect(at(189500).fraction, .05);
    expect(at(190000).state, ResourceState.due);
    expect(at(190001).state, ResourceState.overdue);
    expect(at(179999).state, ResourceState.unknown);
    expect(
      ResourceView.service(lastKm: 0, intervalKm: 0, currentKm: 0).fraction,
      isNull,
    );
  });
  test(
    'fixture selection stays independent per vehicle and never auto switches',
    () {
      final model = CockpitFixtureModel();
      addTearDown(model.dispose);
      model.selectChoice(ResourceChoice.oil);
      expect(model.choice, ResourceChoice.oil);
      expect(model.resource.fraction, isNull);
      model.showResource(
        const ResourceView(
          state: ResourceState.active,
          fraction: .25,
          remaining: 2500,
          unit: 'км',
        ),
      );
      model.select(1);
      expect(model.choice, ResourceChoice.insurance);
      expect(model.resource.fraction, 1);
      model.selectChoice(ResourceChoice.vignette);
      model.select(0);
      expect(model.choice, ResourceChoice.oil);
      expect(model.resource.remaining, 2500);
      model.select(1);
      expect(model.choice, ResourceChoice.vignette);
    },
  );
  test('ignition reference stages and final values', () {
    IgnitionFrame frame(double ms) => IgnitionFrame(ms: ms);
    expect(frame(0).lamps, 0);
    expect(frame(500).lamps, 1);
    expect(frame(1000).lamps, 0);
    expect(frame(1350).beams, greaterThan(0));
    expect(frame(1700).wordmark, 1);
    expect(frame(2200).wordmarkTravel, inExclusiveRange(0, 1));
    expect(frame(2700).body, 1);
    expect(frame(3400).navigation, 1);
    expect(frame(3400).beams, 0);
    expect(frame(3400).done, isTrue);
  });

  test('Bulgarian calendar and kilometre units including overdue', () {
    final end = DateTime(2026, 12, 10);
    for (final offset in [-2, -1, 0, 1, 2]) {
      final value = ResourceView.calendar(
        today: end.add(Duration(days: offset)),
        end: end,
      );
      final amount = offset.abs();
      expect(value.metric, '$amount ${amount == 1 ? 'ден' : 'дни'}');
      if (offset > 0) {
        expect(value.state, ResourceState.overdue);
        expect(value.semanticLabel, contains('Просрочено'));
      }
      final km = ResourceView.service(
        lastKm: 100,
        intervalKm: 10,
        currentKm: 110 + offset,
      );
      expect(km.metric, '$amount км');
    }
  });
}
