import 'package:flutter/material.dart';

import 'my_painter.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drawing Simulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  TextEditingController _textEditingController3 = TextEditingController();
  TextEditingController _textEditingController4 = TextEditingController();
  double _width = 500;
  bool _quad = true;
  MyPainter _painter = MyPainter();
  List<List<Offset>> _paths = [];
  int _turn = 0;
  void _conv() {
    List<String> list_of_string = _textEditingController3.text.split("\n");
    String par = "";
    int max = 0;
    try {
      for (var element in list_of_string) {
        try {
          if (element.substring(4, 5) == "X") {
            var sp = element.split(" ");
            var x = double.parse(sp[1].substring(1)).toInt();
            var y = double.parse(sp[2].substring(1)).toInt();
            if (max < x) max = x;
            if (max < y) max = y;
            if (element.substring(0, 3) == "G00") {
              par = par + "M $x $y \n";
            } else {
              par = par + "L $x $y \n";
            }
          }
        } catch (e) {}
      }
    } catch (e) {}
    setState(() {
      _textEditingController4.text = par;
      _textEditingController.text = par;
      _textEditingController2.text = max.toString();
    });
    _draw();
  }

  void _changeturn(int turn) {
    setState(() {
      turn < 4 ? _turn = turn : _turn = 0;
    });
  }

  void _draw() {
    List<String> list_of_string = _textEditingController.text.split("\n");
    List<Offset> offsets = [];
    _paths = [];
    for (var element in list_of_string) {
      // print(element);
      try {
        if (element.toString() != "") {
          var sp = element.split(" ");
          // print("${sp[0]} ${double.parse(sp[1])} ${sp[2]} ");
          double x;
          double y;
          if (_quad) {
            x = (double.parse(sp[1]) * _width / double.parse(_textEditingController2.text)) - (_width / 2);
            y = (double.parse(sp[2]) * _width / double.parse(_textEditingController2.text)) - (_width / 2);
          } else {
            x = (double.parse(sp[1]) * _width / double.parse(_textEditingController2.text));
            y = (double.parse(sp[2]) * _width / double.parse(_textEditingController2.text));
          }
          if (x > 500 || y > 500) print("${sp[0]} ${double.parse(sp[1])} ${sp[2]} ");
          if (sp[0] == "M") {
            _paths.add(offsets);
            offsets = [];
            offsets.add(Offset(x, y));
          } else if (sp[0] == "L") {
            offsets.add(Offset(x, y));
          }
        }
      } catch (e) {
        print(element.toString());
        debugPrint("94: " + e.toString());
      }
    }
    _paths.add(offsets);
    _paths.removeAt(0);
    // print("_paths: " + _paths.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _painter.paths = _paths;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.blueGrey[50],
        appBar: AppBar(
          title: Text('2D Drawing by wheel tools'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "วาดภาพจำลองจากชุดข้อมูลพิกัด",
              ),
              Tab(
                text: "แปลง gcode เป็นชุดข้อมูลพิกัด",
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // _width = constraints.maxWidth - 100;
            if (constraints.maxWidth < 600) {
              return Container(
                child: Center(
                  child: Text('โปรดเข้าใช้งานด้วยอุปกรณ์ที่มีขนาดมากกว่า 600 dp ขึ้นไป'),
                ),
              );
            } else {
              return TabBarView(
                key: Key('3'),
                children: [
                  Row(
                    children: [_display(), _input()],
                  ),
                  Row(
                    children: [_input_gcode(), _output_code()],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _display() {
    return Expanded(
      child: Container(
        color: Colors.blue[100],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: RotatedBox(
              quarterTurns: _turn,
              child: Container(
                width: _width,
                height: _width,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    child: CustomPaint(
                      size: Size(_width, _width),
                      painter: _painter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Card(
                  child: IconButton(
                      onPressed: () {
                        _changeturn(_turn + 1);
                      },
                      icon: const Icon(Icons.rotate_right_rounded)),
                ),
                Card(
                  child: IconButton(
                      onPressed: () {
                        _draw();
                      },
                      icon: const Icon(Icons.draw)),
                ),
                Card(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _quad = true;
                          _draw();
                        });
                      },
                      icon: const Icon(Icons.grid_view)),
                ),
                Card(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _quad = false;
                          _draw();
                        });
                      },
                      icon: const Icon(Icons.square)),
                ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textEditingController2,
                keyboardType: TextInputType.number,
                maxLines: 1,
                minLines: 1,
                decoration: InputDecoration(labelText: "ขนาดภาพ"),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: ScrollController(),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1000,
                      minLines: 1,
                      decoration: InputDecoration(labelText: "ข้อมูลพิกัด"),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _input_gcode() {
    return Expanded(
        key: Key('1'),
        child: Column(
          children: [
            SizedBox(
                height: 60,
                child: Card(
                    child: Center(
                  child: Text('G CODE'),
                ))),
            Expanded(
              child: ListView(
                controller: ScrollController(),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textEditingController3,
                        keyboardType: TextInputType.multiline,
                        maxLines: 1000,
                        minLines: 1,
                        decoration: InputDecoration(labelText: "กรอก gcode ที่นี่"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _output_code() {
    return Expanded(
      key: Key('2'),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  _conv();
                },
                child: Text('แปลงเป็นผลลัพธ์'),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: ScrollController(),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _textEditingController4,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1000,
                      minLines: 1,
                      decoration: InputDecoration(labelText: "ผลลัพธ์"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
