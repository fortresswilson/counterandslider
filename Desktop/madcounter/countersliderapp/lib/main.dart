import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
const MyApp({super.key});
// This widget is the root of your application.
@override
Widget build(BuildContext context) {
return MaterialApp(
// Application name
title: 'Stateful Widget',
theme: ThemeData(
primarySwatch: Colors.blue,
),
// A widget that will be started on the application startup
home: CounterWidget(),
);
}
}
class CounterWidget extends StatefulWidget {
@override
_CounterWidgetState createState() => _CounterWidgetState();
}
class _CounterWidgetState extends State<CounterWidget> {
//initial couter value
int _counter = 0;
  // controller for text field
  final TextEditingController _incrementController =
      TextEditingController(text: '1');

  // custom increment value
  int _incrementValue = 1;
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Stateful Widget'),
),
body: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Center(
child: Container(
color: Colors.blue,
child: Text(
//displays the current number
'$_counter',
style: TextStyle(fontSize: 50.0),
),
),
),
// 🔹 CUSTOM INCREMENT INPUT
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0),
  child: TextField(
    controller: _incrementController,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'Custom Increment Value',
      border: OutlineInputBorder(),
      hintText: 'Enter a number (e.g., 2)',
    ),
    onChanged: (value) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) {
        _incrementValue = parsed;
      }
    },
  ),
),
const SizedBox(height: 20),

Slider(
min: 0,
max: 100,
value: _counter.toDouble(),
onChanged: (double value) {
setState(() {
_counter = value.toInt();
});
},
activeColor: Colors.blue,
inactiveColor: Colors.red,
),
  const SizedBox(height: 20),

  //  rOW FOR NEW BUTTONS
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      // ➖ DECREMENT BUTTON
      ElevatedButton(
        onPressed: () {
          setState(() {
            if (_counter > 0) {
              _counter--;
            }
          });
        },
        child: const Text('Decrement'),
      ),

      const SizedBox(width: 20),

      //  RESET BUTTON
      ElevatedButton(
        onPressed: () {
          setState(() {
            _counter = 0;
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