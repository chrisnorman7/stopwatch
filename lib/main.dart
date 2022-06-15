import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'widgets/focus_text.dart';

/// Whether this system is running Mac OS.
final isMac = Platform.isMacOS;

/// The pause shortcut.
final pauseShortcut = SingleActivator(
  LogicalKeyboardKey.keyP,
  control: !isMac,
  meta: isMac,
);

/// The reset shortcut.
final resetShortcut = SingleActivator(
  LogicalKeyboardKey.keyR,
  control: !isMac,
  meta: isMac,
);

/// Return the given [value] as a string padded with zeros.
String padNumber(final int value) {
  final string = value.toString();
  return string.padLeft(2, '0');
}

void main() => runApp(const MyApp());

/// The main app class.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    RendererBinding.instance.setSemanticsEnabled(true);
    return MaterialApp(
      title: 'Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

/// The widget where the magic happens.
class MyHomePage extends StatefulWidget {
  /// Create an instance.
  const MyHomePage({
    super.key,
  });

  /// Get the state.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for [MyHomePage].
class _MyHomePageState extends State<MyHomePage> {
  int? _counter;
  late int _previousCounter;
  Timer? _timer;
  late bool paused;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _previousCounter = 0;
    paused = false;
  }

  /// Increment the counter.
  void _incrementCounter() {
    if (paused == false) {
      setState(() {
        _counter = (_counter ?? 0) + 1;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final Widget child;
    final counter = _counter;
    final timer = _timer;
    if (counter == null) {
      child = Container(
        alignment: Alignment.center,
        child: const FocusText(
          text: 'Click the start button to begin.',
        ),
      );
    } else if (counter < 0) {
      child = Container(
        alignment: Alignment.center,
        child: Semantics(
          liveRegion: true,
          child: FocusText(
            text: '${counter.abs()}...',
            autofocus: true,
          ),
        ),
      );
    } else {
      if (counter == 0) {
        _counter = counter + _previousCounter;
        _previousCounter = 0;
      }
      final hours = (counter / 3600).floor();
      final remainder = counter % 3600;
      final minutes = (remainder / 60).floor();
      final seconds = remainder % 60;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            liveRegion: true,
            child: FocusText(
              text: padNumber(hours),
            ),
          ),
          const Text(':'),
          Semantics(
            liveRegion: true,
            child: FocusText(
              text: padNumber(minutes),
              autofocus: true,
            ),
          ),
          const Text(':'),
          Semantics(
            liveRegion: seconds == 30,
            child: FocusText(
              text: padNumber(seconds),
            ),
          ),
        ],
      );
    }
    return CallbackShortcuts(
      bindings: {
        pauseShortcut: _playPause,
        resetShortcut: _reset,
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (timer != null)
              ElevatedButton(
                onPressed: _reset,
                child: const Icon(
                  Icons.restart_alt,
                  semanticLabel: 'Reset',
                ),
              )
          ],
          title: const Text('Stopwatch'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [child],
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: counter == null,
          onPressed: _playPause,
          tooltip: timer == null ? 'Start' : (paused ? 'Resume' : 'Pause'),
          child: paused == false
              ? const Icon(Icons.pause)
              : const Icon(Icons.start),
        ),
      ),
    );
  }

  void _playPause() {
    final timer = _timer;
    if (timer == null) {
      _counter = -6;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (final timer) {
          _incrementCounter();
        },
      );
      _incrementCounter();
    } else {
      setState(() {
        paused = !paused;
        if (paused == false) {
          _previousCounter = _counter ?? 0;
          _counter = -6;
        }
      });
    }
  }

  void _reset() => setState(() {
        _timer?.cancel();
        _timer = null;
        _counter = null;
        paused = false;
      });
}
