import 'package:flutter/material.dart';
import 'package:smooth_onboarding/smooth_onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'smooth_onboarding example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _reloadToken = 0;

  Future<void> _showActionMessage(String message) async {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<OnboardingPage> _buildOnboardingPages() {
    return <OnboardingPage>[
      const OnboardingPage(
        title: 'Do you forget about deadlines?',
        body: Text(
          'Bills, documents, subscriptions — keep everything under control automatically. Never miss a deadline again.',
        ),
      ),
      const OnboardingPage(
        title: 'Manage everything in one place',
        body: _UseCasesBody(),
      ),
      const OnboardingPage(
        title: 'Try it now',
        body: _MicroSetupBody(),
        buttonLabel: 'Create first deadline',
      ),
      OnboardingPage(
        title: 'Get notified in time?',
        body: const _NotificationBody(),
        buttonLabel: 'Enable notifications',
        onPrimaryPressed: () async {
          // Hook your real push permission flow here (FCM/local notifications).
          await _showActionMessage(
            'Notification permission flow triggered (connect your real notification SDK here)',
          );
        },
      ),
      OnboardingPage(
        title: 'Save everything securely',
        body: const _LoginBody(),
        buttonLabel: 'Continue with Google',
        secondaryButtonLabel: 'Skip',
        onPrimaryPressed: () async {
          await _showActionMessage(
            'Google Sign-In triggered (connect your real auth SDK here)',
          );
        },
      ),
      OnboardingPage(
        title: 'Unlock Pro features',
        body: const _PaywallBody(),
        buttonLabel: 'Try free for 7 days',
        secondaryButtonLabel: 'Skip',
        onPrimaryPressed: () async {
          await _showActionMessage(
            'Free trial triggered (connect RevenueCat or billing here)',
          );
        },
      ),
    ];
  }

  Future<void> _resetOnboarding() async {
    await OnboardingStorage.reset();
    if (!mounted) {
      return;
    }

    setState(() {
      _reloadToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingGate(
      reloadTrigger: _reloadToken,
      storageKey: OnboardingStorage.defaultStorageKey,
      pages: _buildOnboardingPages(),
      nextButtonLabel: 'Continue',
      doneButtonLabel: 'Start app',
      backButtonTooltip: 'Back',
      progressSemanticsLabel: 'Onboarding progress',
      showBackButton: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Onboarding Example'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Reset onboarding',
              onPressed: _resetOnboarding,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Onboarding Complete!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tap the button in the top-right to reset and replay the onboarding.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _HookBody extends StatelessWidget {
  const _HookBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Bills, documents, subscriptions — everything organized automatically.',
        ),
        SizedBox(height: 12),
        Text('Never miss an important deadline.'),
      ],
    );
  }
}

class _UseCasesBody extends StatelessWidget {
  const _UseCasesBody();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> items = <String>[
      'Bills and payments',
      'Subscriptions (Netflix, Spotify...)',
      'Documents and renewals',
      'Custom reminders',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final String item in items) ...<Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.check_circle_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MicroSetupBody extends StatelessWidget {
  const _MicroSetupBody();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: Bolletta luce'),
            SizedBox(height: 8),
            Text('Data: 26 Aprile 2026 (suggerita)'),
            SizedBox(height: 8),
            Text('Reminder: automatico 3 giorni prima'),
          ],
        ),
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'We notify you before every important deadline, at the right time.',
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Sign in to sync across all devices and keep your data safe.',
    );
  }
}

class _PaywallBody extends StatelessWidget {
  const _PaywallBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('You have already created your first deadline.'),
        SizedBox(height: 12),
        Text('With Pro you get:'),
        SizedBox(height: 8),
        Text('- More deadlines'),
        Text('- Secure backup'),
        Text('- No limits'),
      ],
    );
  }
}

// ignore: unused_element
class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: 1.15,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.18),
              colorScheme.secondary.withValues(alpha: 0.16),
              colorScheme.tertiary.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 18,
              top: 18,
              child: _FloatingBubble(
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              right: 16,
              top: 28,
              child: _FloatingBubble(
                size: 42,
                color: colorScheme.tertiary.withValues(alpha: 0.22),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 176,
                height: 250,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Shared axis',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smooth transitions with a polished finish.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.72,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  colorScheme.primary,
                                  colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 20,
              child: _MiniBadge(
                label: 'No assets',
                icon: Icons.verified_outlined,
                color: colorScheme.secondary,
              ),
            ),
            Positioned(
              right: 24,
              bottom: 26,
              child: _MiniBadge(
                label: 'Built in',
                icon: Icons.layers_outlined,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  const _FloatingBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
