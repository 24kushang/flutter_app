import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Repos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = 'https://api.github.com/users/freeCodeCamp/repos';
  List<dynamic> _repositories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRepos().then((repos) {
      setState(() {
        _repositories = repos;
        _isLoading = false;
      });
    });
  }

  Future<List<dynamic>> fetchRepos() async {
    var result = await http.get(Uri.parse(apiUrl));
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: _repositories.map((repo) {
          return ListTile(
            title: Text(repo['name']),
            subtitle: FutureBuilder<dynamic>(
              future: http.get(Uri.parse(
                  repo['commits_url'].replaceAll('{/sha}', ''))),
              builder:
                  (BuildContext context, AsyncSnapshot commitSnapshot) {
                if (commitSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Text('Loading commit data...');
                } else if (commitSnapshot.hasError) {
                  return Text('Error: ${commitSnapshot.error}');
                } else {
                  var lastCommit =
                  json.decode(commitSnapshot.data.body)[0]['commit'];
                  return Text(
                      'Last commit by: ${lastCommit['author']['name']} at ${lastCommit['author']['date']}');
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
