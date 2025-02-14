class Logger {
  static void log(String tag, String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print("LOCATION_APP: $tag: ${match.group(0)}"));
  }
}
