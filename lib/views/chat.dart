import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/theme.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ///設一個能夠輸入訊息的controller
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    ///snapshot.data:對取回來的資料，依照字串及特定符號來做排序
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.docs[index].data()["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.docs[index].data()["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      ///Map也是資料宣告的一種方式，透過序列化的方式將參數存進去
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      ///從DatabaseMethods()抓取所需的資料
      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        ///空字串不能送出訊息
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    ///DatabaseMethods()通知框架，框架收到通知後，重新構建app介面
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///將logo設置在上appber
      appBar: AppBar(
        backgroundColor: MyTheme.kPrimaryColor,
        title: Image.asset(
          "assets/images/logo.png",
          height: 40,
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              ///輸入框
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child:
                  /* Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: MyTheme.kAccentColor,
                child:*/
                  Row(
                children: [
                  Expanded(
                      child: TextField(
                    ///在輸入框調用上面創的controller
                    controller: messageEditingController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Message ...",
                      hintStyle: TextStyle(
                        color: MyTheme.kPrimaryColorVariant,
                        fontSize: 16,
                      ),

                      ///輸入框的UI
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.deepPurple[50]),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: 10,
                  ),

                  ///送出訊息的按鈕，調用上面創的addMessage()函式
                  GestureDetector(
                    onTap: () {
                      addMessage();
                    },
                    child: Container(

                        ///按鈕UI
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xff7C7B9B),
                                  const Color(0xff686795)
                                ],
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.bottomRight),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/images/send.png",
                          height: 30,
                          width: 30,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  ///當資料傳送到聊天室後，要依照時間先後依序排列，並區分資料傳送端(右側)及接收端(左側)
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff9575cd), const Color(0xff9575cd)]
                  : [const Color(0xffb39ddb), const Color(0xffb39ddb)],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
