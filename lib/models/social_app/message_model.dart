class MessageModel {
  String? senderId;
  String? receiverId;
  String? dateTime;
  String? text;
  List<String>? attachments;
  String? localImagePath;
  String? localAudioPath;
  String? voiceMessageUrl;  // Add this field

  MessageModel({
    this.senderId,
    this.receiverId,
    this.dateTime,
    this.text,
    this.attachments,
    this.localImagePath,
    this.localAudioPath,
    this.voiceMessageUrl,  // Add to constructor
  });

  MessageModel.fromjson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    dateTime = json['dateTime'];
    text = json['text'];
    attachments = json['attachments'] != null
        ? List<String>.from(json['attachments'])
        : null;
    localImagePath = json['localImagePath'];
    localAudioPath = json['localAudioPath'];
    voiceMessageUrl = json['voiceMessageUrl'];  // Add to fromJson
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'dateTime': dateTime,
      'text': text,
      'attachments': attachments ?? [],
      'localImagePath': localImagePath,
      'localAudioPath': localAudioPath,
      'voiceMessageUrl': voiceMessageUrl,  // Add to toMap
    };
  }
}