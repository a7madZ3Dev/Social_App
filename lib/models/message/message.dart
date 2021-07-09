class Message {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime dateTime;
  Message({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.dateTime,
  });

  factory Message.fromJson(Map<String, dynamic> jsonData) {
    return Message(
      text: jsonData['text'],
      senderId: jsonData['senderId'],
      receiverId: jsonData['receiverId'],
      dateTime: jsonData['dateTime'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'dateTime': dateTime,
    };
  }
}
