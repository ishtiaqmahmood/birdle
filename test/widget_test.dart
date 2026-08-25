import 'package:birdle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders Birdle title and keyboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Birdle'), findsOneWidget);
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    expect(find.byType(Tile), findsNWidgets(25)); // 5 rows x 5 columns
  });

  testWidgets('Tapping virtual keyboard inputs letters', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    await tester.tap(find.widgetWithText(InkWell, 'A'));
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'B'));
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'A'));
    await tester.pump();

    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);
  });

  testWidgets('Submitting short word shows notification', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    await tester.tap(find.widgetWithText(InkWell, 'A'));
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'ENTER'));
    await tester.pumpAndSettle();

    expect(find.text('Not enough letters'), findsOneWidget);
  });

  testWidgets('Submitting invalid word shows notification', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.widgetWithText(InkWell, 'Z'));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(InkWell, 'ENTER'));
    await tester.pumpAndSettle();

    expect(find.text('Not in word list'), findsOneWidget);
  });

  testWidgets('Restart button resets game', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    await tester.tap(find.widgetWithText(InkWell, 'A'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Check that top row tiles are cleared
    final tileWidgets = tester.widgetList<Tile>(find.byType(Tile));
    final firstTile = tileWidgets.first;
    expect(firstTile.letter, isEmpty);
  });
}
