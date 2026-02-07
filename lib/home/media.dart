enum MediaType {image, video}

class Media {
  final String value;
  final MediaType type;

  Media({
    required this.value, required this.type
  });

  factory Media.fromMap(Map<String, dynamic> mediaMap) {
    return Media(
        type: _stringToMediaType(mediaMap["type"]),
        value: mediaMap["value"] as String
    );
  }

  static MediaType _stringToMediaType(String stringMediaType) {
    switch(stringMediaType) {
      case "image":
        return MediaType.image;
      case "video":
        return MediaType.video;
      default:
        throw ArgumentError('Invalid media type - stringMediaType');
    }
  }
  Map<String, dynamic> toMap() => {
    "value": value,
    "type": type == MediaType.image ? "image" : "video"
  };
}

