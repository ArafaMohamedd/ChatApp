// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatnew/main.dart';
import 'package:chatnew/features/on%20Boarding/presentation/on_boarding_view.dart';

void main() {
  testWidgets('App starts with onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(startWidget: OnBoardingView()));

    // Wait for the widget to build completely
    await tester.pumpAndSettle();

    // Verify that the onboarding screen is displayed
    expect(find.byType(OnBoardingView), findsOneWidget);
  });
}
