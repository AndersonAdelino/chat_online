import 'dart:io';
import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _currentUser;
  bool _isLoading = false;
  String background1 = 'images/background.png';
  String background2 = 'images/background2.png';
  String background3 = 'images/background3.png';
  String backgroundCurrent = 'images/background.png';
  String _usersOnline = '0';

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user){
      setState(() {
        _currentUser = user;
      });     
    });
  }

  Future _getUser() async {
    if(_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = 
        await googleSignInAccount.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential authResult = 
        await FirebaseAuth.instance.signInWithCredential(credential);

      final User user = authResult.user;
      return user;

    } catch(error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async{

    final User user = await _getUser();

    if(user == null){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoURL,
      'time': Timestamp.now(),
    };

    if(imgFile != null){
      firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref().child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      firebase_storage.TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if(text != null) data['text'] = text;

    FirebaseFirestore.instance.collection('messages').add(data);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'Chat App',
            ),
            SizedBox(height: 5),
            Text(
              'Usuários logados: $_usersOnline',            
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 5,
        actions: [
          _currentUser != null? IconButton(
            icon: Icon(Icons.wallpaper),
            onPressed: (){
              setState(() {
                if(backgroundCurrent == background1){
                  backgroundCurrent = background2;
                }else if(backgroundCurrent == background2){
                  backgroundCurrent = background3;
                }else{
                  backgroundCurrent = background1;
                }
              });
            },
          ): Container(),

          _currentUser != null? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text('Você saiu com sucesso!'),
                ),
              );
            },
          ): Container(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundCurrent),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('messages')
                  .orderBy('time', descending: true).snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index){
                      return ChatMessage(
                        documents[index].data(), 
                        documents[index].get('uid') == _currentUser?.uid,
                      );
                    }
                  );
                  }
                },
              ),
            ),
            _isLoading ? LinearProgressIndicator() : Container(),
            TextComposer(_sendMessage),
          ],
        ),
      ),
    );
  }
}