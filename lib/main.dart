import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_sinarindo/screens/addStudent.dart';
import 'package:project_sinarindo/screens/editStudent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mendefinisikan variabel
  final CollectionReference _students = FirebaseFirestore.instance.collection('students');
  DateTime selectedDate = DateTime.now();
  String imageUrl='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Sistem Absensi", style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStudent()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
        stream: _students.snapshots(), //build connection
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length, //number of rows
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.network(
                        documentSnapshot['image'],
                        width: 50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        height: 50, // Sesuaikan ukuran gambar sesuai kebutuhan Anda
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(_getFormattedTimestamp(documentSnapshot['timestamps'])),
                    trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditStudent(documentSnapshot: documentSnapshot),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(documentSnapshot.id),
                      ),
                    ],
                  ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  String _getFormattedTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      // Handle the case when 'timestamps' is null, set a default value or return an empty string
      return 'No Timestamp';
    }
    // Convert the Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime as a human-readable string (change the format as desired)
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  Future<void> _deleteStudent(String productId) async {
    await _students.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully deleted a student')));
  }

}