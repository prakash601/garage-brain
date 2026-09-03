import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_os/core/theme/status_colors.dart';
import 'package:workshop_os/core/utils/plate.dart';
import 'package:workshop_os/core/widgets/content_frame.dart';
import 'package:workshop_os/core/widgets/empty_state.dart';
import 'package:workshop_os/core/theme/app_theme.dart';
import 'package:workshop_os/data/drift/enums.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title and fires the action', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_outlined,
              title: 'Nothing here',
              subtitle: 'Try again later.',
              actionLabel: 'Do it',
              onAction: () => fired = true,
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('empty_state_action')));
      expect(fired, isTrue);
    });

    testWidgets('no action button when no label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.inbox_outlined, title: 'Empty'),
          ),
        ),
      );
      expect(find.byKey(const Key('empty_state_action')), findsNothing);
    });
  });

  group('ContentFrame', () {
    testWidgets('passes the child through', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentFrame(child: Text('inner')),
          ),
        ),
      );
      expect(find.text('inner'), findsOneWidget);
    });
  });

  group('status colors', () {
    Future<Color> flagColor(
        WidgetTester tester, Brightness brightness) async {
      late Color captured;
      await tester.pumpWidget(
        Theme(
          data: brightness == Brightness.light
              ? AppTheme.light()
              : AppTheme.dark(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                captured = plateFlagColor(context, PlateFlag.green);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return captured;
    }

    testWidgets('plate green adapts to brightness', (tester) async {
      final light = await flagColor(tester, Brightness.light);
      final dark = await flagColor(tester, Brightness.dark);
      expect(light, isNot(dark));
    });

    testWidgets('every job status has a label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final labels = JobStatus.values
                    .map((s) => jobStatusChipStyle(context, s).label);
                return Text(labels.join('|'));
              },
            ),
          ),
        ),
      );
      expect(
        find.text('Arrived|In Progress|Ready|Delivered'),
        findsOneWidget,
      );
    });
  });
}
