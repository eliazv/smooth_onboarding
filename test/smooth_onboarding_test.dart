import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_onboarding/smooth_onboarding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controller advances, retreats and clamps progress', () {
    final OnboardingController controller = OnboardingController();

    controller.attach(3);
    expect(controller.currentPage, 0);
    expect(controller.progress, closeTo(1 / 3, 0.0001));

    controller.next();
    expect(controller.currentPage, 1);
    expect(controller.isFirstPage, isFalse);
    expect(controller.isLastPage, isFalse);

    controller.skip();
    expect(controller.currentPage, 2);
    expect(controller.isLastPage, isTrue);

    controller.previous();
    expect(controller.currentPage, 1);

    controller.goTo(99);
    expect(controller.currentPage, 2);
  });

  testWidgets('storage helper persists the first-launch flag',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    expect(await OnboardingStorage.isFirstLaunch(storageKey: 'demo'), isTrue);

    await OnboardingStorage.markCompleted(storageKey: 'demo');
    expect(await OnboardingStorage.isFirstLaunch(storageKey: 'demo'), isFalse);
    expect(await OnboardingStorage.isCompleted(storageKey: 'demo'), isTrue);

    await OnboardingStorage.reset(storageKey: 'demo');
    expect(await OnboardingStorage.isFirstLaunch(storageKey: 'demo'), isTrue);
  });

  testWidgets('widget updates the primary action and back button',
      (WidgetTester tester) async {
    final OnboardingController controller = OnboardingController();

    await tester.pumpWidget(
      MaterialApp(
        home: SmoothOnboarding(
          controller: controller,
          pages: const <OnboardingPage>[
            OnboardingPage(
              title: 'First',
              body: Text('Page one'),
            ),
            OnboardingPage(
              title: 'Second',
              body: Text('Page two'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Avanti'), findsOneWidget);
    expect(find.text('Inizia'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();

    expect(find.text('Inizia'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('custom labels are applied', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SmoothOnboarding(
          nextButtonLabel: 'Next',
          doneButtonLabel: 'Start',
          backButtonTooltip: 'Back',
          pages: <OnboardingPage>[
            OnboardingPage(
              title: 'First',
              body: Text('Page one'),
            ),
            OnboardingPage(
              title: 'Second',
              body: Text('Page two'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets(
      'onboarding gate re-checks first launch when reloadTrigger changes',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'gate_demo': true,
    });

    int reloadToken = 0;
    late void Function() triggerReload;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            triggerReload = () {
              setState(() {
                reloadToken++;
              });
            };

            return OnboardingGate(
              storageKey: 'gate_demo',
              reloadTrigger: reloadToken,
              pages: const <OnboardingPage>[
                OnboardingPage(title: 'Welcome', body: Text('Onboarding body')),
              ],
              child: const Text('HOME'),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);

    await OnboardingStorage.reset(storageKey: 'gate_demo');
    triggerReload();
    await tester.pumpAndSettle();

    expect(find.text('Inizia'), findsOneWidget);
  });
}
