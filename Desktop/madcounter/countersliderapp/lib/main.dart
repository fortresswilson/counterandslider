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
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  // ✅ max limit
  static const int _maxCounter = 100;

  // state
  int _counter = 0;

  final TextEditingController _incrementController =
      TextEditingController(text: '1');
  int _incrementValue = 1;

  String? _incrementError;
  String? _maxMessage;

  // ✅ helper: clamps counter and sets message
  void _setCounterWithMax(int newValue) {
    if (newValue >= _maxCounter) {
      _counter = _maxCounter;
      _maxMessage = 'Maximum limit reached!';
    } else {
      _counter = newValue;
      _maxMessage = null;
    }
  }

  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stateful Widget')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              '$_counter',
              style: const TextStyle(fontSize: 50.0, color: Colors.white),
            ),
          ),

          // ✅ show max message (in the Column, not inside the Row)
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

          const SizedBox(height: 20),

          // ✅ Custom increment + Add Value button (Row)
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
                  onPressed: () {
                    final text = _incrementController.text.trim();
                    final parsed = int.tryParse(text);

                    setState(() {
                      if (parsed == null || parsed <= 0) {
                        _incrementError = 'Enter a valid number';
                        _maxMessage = 'Maximum limit reached!';
                        return;
                      }
                      _incrementValue = parsed; // ✅ ONLY set value
                      _incrementError = null;
                      if (_incrementValue>= _maxCounter) {
      _counter = _maxCounter;
      _maxMessage = 'Maximum limit reached!';
    } else {
      _counter = _incrementValue;
      _maxMessage = null;
    }
                    });
                  },
                  child: const Text('Add Value'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Slider respects max + uses helper
          Slider(
            min: 0,
            max: _maxCounter.toDouble(),
            value: _counter.toDouble(),
            onChanged: (double value) {
              setState(() => _setCounterWithMax(value.toInt()));
            },
            activeColor: Colors.blue,
            inactiveColor: Colors.red,
          ),

          const SizedBox(height: 20),

          // ✅ Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement (min 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_counter > 0) {
                      _counter--;
                      _maxMessage = null;
                    }
                  });
                },
                child: const Text('Decrement'),
              ),
              const SizedBox(width: 20),

              // Increment (uses applied value, clamps to max)
              ElevatedButton(
                onPressed: () {
                  final parsed =
                      int.tryParse(_incrementController.text.trim());

                  setState(() {
                    // block if current text is invalid
                    if (parsed == null || parsed <= 0) {
                      _incrementError = 'Enter a valid number';
                      return;
                    }
                    _incrementError = null;

                    _setCounterWithMax(_counter + _incrementValue);
                  });
                },
                child: const Text('Increment'),
              ),
              const SizedBox(width: 20),

              // Reset
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _counter = 0;
                    _maxMessage = null;
                    _incrementError = null;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 