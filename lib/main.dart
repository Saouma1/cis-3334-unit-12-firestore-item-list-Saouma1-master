import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireStore Demo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseDemo(),
    );
  }
}

class FirebaseDemo extends StatefulWidget {
  @override
  _FirebaseDemoState createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  final TextEditingController _newItemTextField = TextEditingController();
  final CollectionReference itemCollectionDB = FirebaseFirestore.instance.collection('ITEMS');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.7,
                  child: TextField(
                    controller: _newItemTextField,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Name",
                      hintStyle: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  child: ElevatedButton(
                      onPressed: () async {
                        await itemCollectionDB.add({'item_name': _newItemTextField.text});
                        _newItemTextField.clear();
                      },
                      child: Text(
                        'Add Data',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
              ],
            ),
            SizedBox(height: 40),
            Expanded(
              child: StreamBuilder(
                stream: itemCollectionDB.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.check_box),
                          title: Text(snapshot.data!.docs[index]['item_name']),
                          onTap: () async {
                            String itemId = snapshot.data!.docs[index].id;
                            await itemCollectionDB.doc(itemId).delete();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
