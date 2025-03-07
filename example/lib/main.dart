import 'package:flutter/material.dart';
import 'package:stetho_network_inspector/stetho_network_inspector.dart';
import 'package:http/http.dart' as http;

void main() {
  Stetho.initialize();

  runApp(new StethoNetworkInspectorExample(
    client: new http.Client(),
  ));
}

class StethoNetworkInspectorExample extends StatelessWidget {
  late final http.Client client;

  StethoNetworkInspectorExample({Key? key, required this.client})
      : super(key: key);

  fetchImage() {
    client.get(
      Uri.parse(
          'https://flutter.dev/assets/404/dash_nest-c64796b59b65042a2b40fae5764c13b7477a592db79eaf04c86298dcb75b78ea.png'),
      headers: {'Authorization': 'token'},
    );
  }

  fetchJson() {
    client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      headers: {'Authorization': 'token'},
    );
  }

  fetchError() {
    client.get(Uri.parse('https://jsonplaceholder.typicode.com/postadsass/1'));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            //   new Padding(
            //     padding: new EdgeInsets.all(16.0),
            //     child: new RaisedButton(
            //       onPressed: fetchJson,
            //       child: new Text("Fetch json"),
            //     ),
            //   ),
            //   new Padding(
            //     padding: new EdgeInsets.all(16.0),
            //     child: new RaisedButton(
            //       onPressed: fetchImage,
            //       child: new Text("Fetch image"),
            //     ),
            //   ),
            //   new Padding(
            //     padding: new EdgeInsets.all(16.0),
            //     child: new RaisedButton(
            //       onPressed: fetchError,
            //       child: new Text("Fetch with Error"),
            //     ),
            //   )
            ],
          ),
        ),
      ),
    );
  }
}
