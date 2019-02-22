import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:live_quiz/answer.dart';
import 'dart:convert';
import 'package:live_quiz/quiz.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue[300]),
      title: "Live Quiz App",
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var res = await http.get("https://opentdb.com/api.php?amount=20");
    var decRes = jsonDecode(res.body);
    print(decRes);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FlareActor("assets/Brain.flr",
      animation: "brain",
      alignment: Alignment(0.05, 0.0),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: new Text("Quiz App"),
        elevation: 2.0,
        centerTitle: false,
        brightness: Brightness.light,
        actions: <Widget>[

//          RaisedButton(
//            onPressed: () => FlareActor("assets/hi.flr",
//              animation: "Hi",
//              alignment: Alignment.topCenter,
//            ),
//            child: new Text("Hi Animation")
//          ),
//          RaisedButton(
//            onPressed: () => FlareActor("assets/Brain.flr",
//              animation: "brain",
//            ),
//            child: new Text("Brain Animation"),
//          ),

        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text( 'Press button to start.' );
              case ConnectionState.active:
              case ConnectionState.waiting:
              return Center(
                child: FlareActor("assets/Brain.flr",
                  animation: "brain",
                  alignment: Alignment(-0.8, 0.0),
                  shouldClip: true,
                ),
              );
              case ConnectionState.done:
                if (snapshot.hasError) return errorData( snapshot );
                return questionList( );
            }
            return null;
          }
        ),
      )
    );
  }

  Padding errorData(AsyncSnapshot snapshot){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Error: ${snapshot.error}',
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text("Try Again"),
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        color: Colors.white,
        elevation: 0.0,
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  results[index].question,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[index].category),
                        onSelected: (b) {},
                      ),
                      SizedBox(width: 10.0),
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[index].difficulty),
                        onSelected: (b) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Text(results[index].type.startsWith("m") ? "M" : "B"),
          ),
          children: results[index].allAnswers.map( (m) {
            return AnswerWidget(results, index, m);
          }).toList(),
        ),
      ),
    );
  }
}

