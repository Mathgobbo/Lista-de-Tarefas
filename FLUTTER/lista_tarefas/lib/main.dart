import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();
  List _toDoList = [];
  Map<String,dynamic> _lastRemoved = Map();
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addTodo(){
    setState(() {
      Map<String, dynamic> newTodo = Map();

      newTodo['title'] = todoController.text;
      todoController.text = "";
      newTodo['ok'] = false;

      _toDoList.add(newTodo);
      _saveData();
    });
  }



  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{
    try{
        final file = await _getFile();
        return file.readAsString();
    } catch (e){
        return null;
    }
  }

  Widget buildItem(context, index){
      return Dismissible(
        onDismissed: (direction){
          setState(() {
            _lastRemoved = Map.from(_toDoList[index]);
            _lastRemovedPos = index;
            _toDoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
              duration: Duration(seconds: 2),
              content: Text("Tarefa \"${_lastRemoved['title']}\" removida"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  });
              }),
            );
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snack);
          });
        },
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0),
            child: Icon(Icons.delete, color: Colors.white,),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(_toDoList[index]['title']),
          value: _toDoList[index]['ok'],
          secondary: CircleAvatar(
            child: Icon(_toDoList[index]['ok'] ?
            Icons.check : Icons.error),
          ),
          onChanged: (c){
            setState(() {
              _toDoList[index]['ok'] = c;
              _saveData();
            });
          },
        ),
      );
    }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b){
        if(a['ok'] && !b['ok']) return 1;
        else if(!a['ok'] && b['ok']) return -1;
        else return 0;
      });
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: todoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem,
              ),
            )
          )
        ],
      ),
    );
  }
}

