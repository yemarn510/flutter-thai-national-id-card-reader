

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:card_reader/cardreader_service.dart';


void main() {
  MyApp? myApp;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      myApp?.addError(details.toString());
    };

    runApp(myApp = MyApp());
  }, (Object error, StackTrace stack) {
    myApp?.addError(error.toString());
  });
}

class MyApp extends StatelessWidget {
  final GlobalKey<_MyAppBodyState> _myAppKey = GlobalKey();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Read Thai National ID Card'),
          ),
          body: MyAppBody(key: _myAppKey)),
    );
  }

  void addError(String msg) {
    _myAppKey.currentState?.messages.add(Message.error(msg));
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({required Key key}) : super(key: key);

  @override
  _MyAppBodyState createState() {
    return _MyAppBodyState();
  }
}

enum MessageType { info, error }

class Message {
  final String content;
  final MessageType type;
  Message(this.type, this.content);

  static info(String content) {
    return Message(MessageType.info, content);
  }

  static error(String content) {
    return Message(MessageType.error, content);
  }
}

class _MyAppBodyState extends State<MyAppBody> {
  CardReaderService cardReader = CardReaderService();
  final List<Message> messages = [];
  late CardData? _cardData = null;

  late Uint8List? bytesImage = null;


  @override
  void initState() {
    super.initState();
  }

  readCard() async {
    _cardData = await cardReader.readCard();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () async {
                      await tryAgain();
                    },
                    child: const Text("Read Card")
                  )
              ),
              _cardData != null 
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('CID: '),
                        Text("${_cardData?.cid}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('English Name: '),
                        Text("${_cardData?.englishName}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Thai Name: '),
                        Text("${_cardData?.thaiName}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Birthday: '),
                        Text("${_cardData?.birthday}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gender: '),
                        Text("${_cardData?.gender}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Issuer: '),
                        Text("${_cardData?.issuer}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Issue Date: '),
                        Text("${_cardData?.issueDate}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Expire Date: '),
                        Text("${_cardData?.expireDate}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Address: '),
                        Text("${_cardData?.address}"),
                      ],
                    ),
                    Center(
                      child: 
                        _cardData!.base64Photo != null
                        ? Image.memory(
                            base64.decode(_cardData!.base64Photo!),
                            width: 200,
                            height: 200
                          )
                        : const Text('No Image')
                    )
                  ]
                )
              : const Text('No Data'),
            ]
          )
        )
      ]
    );
  }

  

  tryAgain() async {
    messages.clear();
    readCard();
  }
}
