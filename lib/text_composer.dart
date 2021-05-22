import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;
  bool _isPressed = false;

  void _reset(){
    _controller.clear();
    setState((){
      _isComposing = false;
    });
  }

  IconButton _options (Widget icon, ImageSource option){

    return IconButton(
      icon: icon,
      onPressed: () async {
        
        final picker = ImagePicker();
        final pickedFile = await picker.getImage(source: option);

        if(pickedFile?.path == null) return;

        final image = File(pickedFile.path);

        widget.sendMessage(imgFile: image);
        _isPressed = false;
      },
      
      iconSize: 70,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isPressed ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(50.0),
              bottom: Radius.zero,
            ),
          ),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(width: 20),
              _options(Icon(Icons.insert_photo), ImageSource.gallery),
              _options(Icon(Icons.photo_camera), ImageSource.camera),
              Container(width: 20),
            ],
          ),
        ) : Container(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(1),     
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: () {
                  setState(() {
                    _isPressed = !_isPressed;
                  });            
                },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enviar uma mensagem',
                  ),
                  onChanged: (text){
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (text){
                    widget.sendMessage(text: text);
                    _reset();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing ? (){
                  widget.sendMessage(text: _controller.text);
                  _reset();
                } : null,
              ),
            ],
          ),      
        ),
      ],
    );
  }
}