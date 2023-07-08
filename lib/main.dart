import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list/UploadPage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbRef = FirebaseDatabase.instance.reference().child("text");
  Reference storageRef = FirebaseStorage.instance.ref().child("files");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => UploadPage()));
          }),
    );
  }

  Widget FirebaseList() {
    return FirebaseAnimatedList(
        query: dbRef,
        itemBuilder: (context, snapshot, animation, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      snapshot.child("image").value.toString(),
                      height: 100,
                      width: 150,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(snapshot.child("name").value.toString()),
                    subtitle: Text(snapshot.child("age").value.toString()),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget StreamList() {
    return StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
          List<dynamic> list = [];
          list.clear();
          // lists = map.values.toList();
          map.forEach((key, value) {
            list.add(value);
          });
          return ListView.builder(
              itemCount: snapshot.data!.snapshot.children.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            list[index]['image'],
                            height: 100,
                            width: 150,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(list[index]["name"]),
                          subtitle: Text(list[index]['age']),
                        ),
                      ),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(shape: CircleBorder()),
                          onPressed: () {
                            storageRef.child(list[index]["name"]).delete();
                            dbRef.child(list[index]["name"]).remove();
                          },
                          child: Icon(Icons.delete)),
                    ],
                  ),
                );
              });
        });
  }
}
