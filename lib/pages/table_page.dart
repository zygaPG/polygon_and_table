import 'dart:math';

import 'package:flutter/material.dart';

class TablePage extends StatefulWidget {
  TablePage({super.key});

  final double _cellWidth = 100;
  final double _cellHeight = 120;
  final double _headingSize = 42;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  List<List<double>> _data = [];

  List<int> _currentRowOrder = [];

  int _selectedRow = -1;

  @override
  void initState() {
    super.initState();

    generateRandomData();
    // listener to sync scrolls 1 -> 2
    _scrollController1.addListener(() {
      if (_scrollController1.offset != _scrollController2.offset) {
        _scrollController2.jumpTo(_scrollController1.offset);
      }
    });

    // listener to sync scrolls 2 -> 1
    _scrollController2.addListener(() {
      if (_scrollController2.offset != _scrollController1.offset) {
        _scrollController1.jumpTo(_scrollController2.offset);
      }
    });
  }

  void generateRandomData() {
    for (int i = 0; i < 8; i++) {
      _currentRowOrder.add(i);
      _data.add([]);
      for (int p = 0; p < 8; p++) {
        _data[i].add((i + Random().nextDouble()));
      }
    }

    setState(() {
      _data = _data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table'),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(children: [
            Row(children: [
              Container(
                height: widget._cellHeight,
                width: widget._headingSize,
              ),
              SingleChildScrollView(
                controller: _scrollController1,
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(height: widget._headingSize),
                    ...List.generate(
                      _data.length,
                      (i) => myTableRow(
                          i,
                          widget._cellWidth,
                          widget._cellHeight,
                          List.generate(_data.length,
                              (index) => _data[i][index].toStringAsFixed(2)),
                          const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
            ]),
            Row(children: [
              SizedBox(width: widget._headingSize),
              myTableRow(
                  -1,
                  widget._cellWidth,
                  widget._headingSize,
                  List.generate(_data.length,
                      (index) => "${_currentRowOrder[index] + 1}"),
                  const Color.fromARGB(255, 241, 232, 182))
            ]),
          ]),
        ),
        SingleChildScrollView(
          controller: _scrollController2,
          scrollDirection: Axis.vertical,
          child: Column(children: [
            SizedBox(height: widget._headingSize),
            rowHeading(0, widget._headingSize, widget._cellHeight, 'Wodór',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(1, widget._headingSize, widget._cellHeight, 'Tlen',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(2, widget._headingSize, widget._cellHeight, 'Azot',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(3, widget._headingSize, widget._cellHeight, 'Węgiel',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(4, widget._headingSize, widget._cellHeight, 'Potas',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(5, widget._headingSize, widget._cellHeight, 'Źelazo',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(6, widget._headingSize, widget._cellHeight, 'Miedź',
                Color.fromARGB(255, 241, 232, 182)),
            rowHeading(7, widget._headingSize, widget._cellHeight, 'Srebro',
                Color.fromARGB(255, 241, 232, 182)),
          ]),
        ),
        Container(
            width: widget._headingSize,
            height: widget._headingSize,
            color: Colors.white),
      ]),
    );
  }

  Widget myTableRow(int rowId, double cellWidth, double cellHeight,
      List<String> content, Color cellColor) {
    return Row(
      children: content.map((text) {
        return Container(
          width: cellWidth,
          height: cellHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: cellColor,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget rowHeading(
    final int rowId,
    double cellWidth,
    double cellHeight,
    String title,
    Color cellColor,
  ) {
    return Container(
        width: cellWidth,
        height: cellHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: cellColor,
        ),
        child: ElevatedButton(
          onPressed: () => onPressRowHeader(rowId),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(0, 241, 241, 241),
            foregroundColor: const Color.fromARGB(0, 15, 15, 15),
            disabledBackgroundColor: const Color.fromARGB(0, 209, 209, 214),
            disabledForegroundColor: const Color.fromARGB(0, 148, 148, 148),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        ));
  }

  void onPressRowHeader(int rowId) {

    List<int> newRowOrder = [];

    if (_selectedRow != rowId) {
      newRowOrder = sortRow(rowId);
      setState(() {
    });
    } else {
      newRowOrder = reverseCurrentRow();
    }

    updateData(newRowOrder);

    setState(() {
      _selectedRow = rowId;
      _currentRowOrder = newRowOrder;
    });
  }

  List<int> sortRow(int rowIndex) {
    if (_data.isEmpty || rowIndex >= _data.length) return [];

    List<double> myRow = [];
    List<int> newRowOrder = [];

    for (int i = 0; i < _data[rowIndex].length; i++) {
      myRow.add(_data[rowIndex][i]);
    }

    myRow.sort();

    for (int i = 0; i < myRow.length; i++) {
      for (int newId = 0; newId < _data[rowIndex].length; newId++) {
        //____________________________________________BIG_BIG_BIG problem if we have more than one same value
        if (myRow[i] == _data[rowIndex][newId]) {
          newRowOrder.add(newId);
        }
      }
    }

    return newRowOrder;
  }

  //reverse current row set
  List<int> reverseCurrentRow() {
    final List<int> newRowOrder = [];

    for (int i = _currentRowOrder.length - 1; i >= 0; i--) {
      newRowOrder.add(_currentRowOrder[i].toInt()); //_________________________problem this code not rversing order this randomize it WTF?
    }
    return newRowOrder;
  }

  void updateData(List<int> rowSet) {
    // new copy of data
    List<List<double>> dataCopy =
        _data.map((row) => List<double>.from(row)).toList();

    // new list with new data
    List<List<double>> newData = List.generate(
        _data.length, (i) => List<double>.filled(_data[i].length, 0.0));

    // swap columns
    for (int row = 0; row < _data.length; row++) {
      for (int col = 0; col < _data[row].length; col++) {
        // set correct to new positon
        newData[row][col] = dataCopy[row][rowSet[col]];
      }
    }

    setState(() {
      _data = List.from(newData.map((row) => List<double>.from(row)));
    });
  }
}
