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
  Future<void> _resetOnboarding() async {
    await OnboardingStorage.reset();
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingGate(
      storageKey: OnboardingStorage.defaultStorageKey,
      pages: const <OnboardingPage>[
        OnboardingPage(
          title: 'Benvenuto in smooth_onboarding',
          body: Text(
            'Un onboarding minimale, pulito e riutilizzabile per i tuoi progetti Flutter.',
          ),
        ),
        OnboardingPage(
          title: 'Progressivo e animato',
          body: Icon(
            Icons.linear_scale_rounded,
            size: 84,
            color: Colors.blue,
          ),
        ),
        OnboardingPage(
          title: 'Pronto per la produzione',
          body: Text(
            'Persistenza del primo avvio, dark mode, tema personalizzabile e API semplice.',
          ),
          buttonLabel: 'Inizia',
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demo app'),
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
                    'Onboarding completato.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Usa il pulsante in alto a destra per resettare il flag e rivedere il flusso.',
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
