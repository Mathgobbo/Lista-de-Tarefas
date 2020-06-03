import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance';

void main() async {

  await getData();

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.amber,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white
          )
        )
      )
    ),
  ));
}


Future<Map> getData() async{
  http.Response response = await http.get(request);
  return (json.decode(response.body));
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll(){
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black ,
      appBar: AppBar(
        title: Text('\$Conversor\$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...", style: TextStyle(color: Colors.amber, fontSize: 25),textAlign: TextAlign.center,),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar dados...", style: TextStyle(color: Colors.amber, fontSize: 25),textAlign: TextAlign.center,),
                );
              } else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber,),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólar", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "EUR\$", euroController, _euroChanged),
                      Divider(),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

 Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
    return  TextField(
      onChanged: f,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixText: prefix,
      ),
      style: TextStyle(
          color: Colors.amber,
          fontSize: 25
      ),
    );
}
