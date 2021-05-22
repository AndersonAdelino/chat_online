import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);
  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: mine? EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 100)
          : EdgeInsets.only(top: 10, bottom: 10, right: 100, left: 10),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: !mine? Colors.white.withOpacity(0.7)
            : Colors.purple[700].withOpacity(0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(
                2.0, 2.0
              ),
            ),
          ],          
        ),
        child: Row(
          children: [
            !mine ?
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl']),
                radius: 25,
              ),
            )
            : 
            Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    data['senderName'],
                    style: TextStyle(
                      fontSize: 12,
                      color: mine? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                    height: 7,
                  ),
                  data['imgUrl'] != null ? 
                    Image.network(data['imgUrl'], width: 250,)
                  :
                    Text(
                      data['text'],
                      textAlign: !mine ? TextAlign.start : TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        color: mine? Colors.white : Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            mine ?
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl']),
                radius: 25,
              ),
            )
            : 
            Container(),  
          ],
        ),
    );
  }
}