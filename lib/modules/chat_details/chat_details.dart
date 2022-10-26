import 'package:flutter/material.dart';

import '../../models/user/user.dart';
import '../../models/message/message.dart';
import '../../shared/network/remote/data.dart';
import '../../shared/components/constants.dart';
import '../../shared/styles/styles/icon_broken.dart';

class ChatsDetailsScreen extends StatelessWidget {
  final _controller = new TextEditingController();
  final UserFireBase? receiverUser;
  final DatabaseService databaseService = DatabaseService();

  ChatsDetailsScreen({Key? key, this.receiverUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
            _controller.clear();
          },
          icon: Icon(
            IconBroken.Arrow___Left_2,
          ),
          tooltip: 'back',
        ),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(receiverUser!.image!),
              ),
            ),
            Text(
              receiverUser!.name!,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          MessagesStream(
            user: receiverUser,
            databaseService: databaseService,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(
                2.0,
              ),
            ),
            clipBehavior: Clip
                .antiAliasWithSaveLayer, // for clip Material Button in the row
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    enableSuggestions: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Send a message ...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15),
                    ),
                  ),
                ),
                Container(
                  color: Theme.of(context).primaryColor,
                  height: 50.0,
                  child: MaterialButton(
                    minWidth: 1.0,
                    child: Icon(
                      IconBroken.Send,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      var message = _controller.text;
                      _controller.clear();
                      await databaseService.createChatWithUser(
                          text: message,
                          receiverUid: receiverUser!.uid!);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final UserFireBase? user;
  final DatabaseService? databaseService;
  MessagesStream({this.user, this.databaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: databaseService!.getChatDataWithUser(receiverUid: user!.uid!),
      builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length > 0) {
            return Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return MessageBubble(
                    message: snapshot.data![index],
                    isMe: snapshot.data![index].senderId == userId,
                  );
                },
              ),
            );
          } else {
            return Expanded(
                child: Center(child: Text('Chat with ${user!.name} now')));
          }
        } else {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({required this.message, required this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Material(
            elevation: 5.2,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Theme.of(context).primaryColor : Colors.grey[100],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
              child: Text(
                '${message.text} ',
                style: TextStyle(
                    fontSize: 16, color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
