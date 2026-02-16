import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stateful Widget',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  // Limits + targets
  static const int _maxCounter = 100;
  static const int _greenThreshold = 50; // > 50 turns green
  static const Set<int> _targets = {50, 100};

  // Counter state
  int _counter = 0;

  // Custom increment input
  final TextEditingController _incrementController =
      TextEditingController(text: '1');
  int _incrementValue = 1;
  String? _incrementError;

  // Messages
  String? _maxMessage;

  // History + Undo
  final List<int> _history = [0]; // start with initial value
  bool _suppressHistory = false; // used during undo so we don't re-add
  final Set<int> _shownTargets = {}; // avoid repeating dialogs

  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  // Visual feedback colors
  Color _counterBgColor() {
    if (_counter == 0) return Colors.red;
    if (_counter > _greenThreshold) return Colors.green;
    return Colors.blue;
  }

  Color _counterTextColor() {
    // White works well on red/green/blue
    return Colors.white;
  }

  void _setCounterWithMax(int newValue, {bool recordHistory = false}) {
    // clamp + max message
    if (newValue >= _maxCounter) {
      _counter = _maxCounter;
      _maxMessage = 'Maximum limit reached!';
    } else {
      _counter = newValue;
      _maxMessage = null;
    }

    // record history only when requested (increment/decrement/undo actions)
    if (recordHistory && !_suppressHistory) {
      if (_history.isEmpty || _history.last != _counter) {
        _history.add(_counter);
      }
    }

    // show success dialog for targets (50 / 100)
    if (_targets.contains(_counter) && !_shownTargets.contains(_counter)) {
      _shownTargets.add(_counter);
      // show after frame so it’s safe
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Congratulations!'),
            content: Text('You reached $_counter 🎉'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _applyIncrementValue() {
    final text = _incrementController.text.trim();
    final parsed = int.tryParse(text);

    setState(() {
      if (parsed == null || parsed <= 0) {
        _incrementError = 'Enter a valid number';
        return;
      }
      _incrementValue = parsed;
      _incrementError = null;
    });
  }

  void _increment() {
    final parsed = int.tryParse(_incrementController.text.trim());
    setState(() {
      // validate current field content (so strings won't increment)
      if (parsed == null || parsed <= 0) {
        _incrementError = 'Enter a valid number';
        return;
      }
      _incrementError = null;

      if (_counter >= _maxCounter) {
        _maxMessage = 'Maximum limit reached!';
        return;
      }

      _setCounterWithMax(_counter + _incrementValue, recordHistory: true);
    });
  }

  void _decrement() {
    setState(() {
      if (_counter <= 0) return; // limit at 0
      _counter -= 1;
      _maxMessage = null;

      // record history
      if (_history.isEmpty || _history.last != _counter) {
        _history.add(_counter);
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _maxMessage = null;
      _incrementError = null;

      // reset history + targets
      _history
        ..clear()
        ..add(0);
      _shownTargets.clear();
    });
  }

  void _undo() {
    setState(() {
      if (_history.length < 2) return; // nothing to undo

      // remove current value, revert to previous
      _suppressHistory = true;
      _history.removeLast();
      final prev = _history.last;

      _setCounterWithMax(prev, recordHistory: false);

      _suppressHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateful Widget')),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            // Counter display with color milestones
            Container(
              color: _counterBgColor(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Text(
                '$_counter',
                style: TextStyle(
                  fontSize: 50,
                  color: _counterTextColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Max message
            if (_maxMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _maxMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Custom increment + Add Value button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _incrementController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Custom Increment Value',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter a number (e.g., 2)',
                        errorText: _incrementError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyIncrementValue,
                    child: const Text('Add Value'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider (does not write to history; only increments/decrements do)
            Slider(
              min: 0,
              max: _maxCounter.toDouble(),
              value: _counter.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _setCounterWithMax(value.toInt(), recordHistory: false);
                });
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.red,
            ),

            const SizedBox(height: 10),

            // Buttons row including Undo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decrement,
                  child: const Text('Decrement'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _undo,
                  child: const Text('Undo'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // History list below the slider
            const Text(
              'Counter History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Use Expanded so the list can scroll
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final value = _history[index];
                      return ListTile(
                        dense: true,
                        title: Text('Value: $value'),
                        leading: Text('#${index + 1}'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
