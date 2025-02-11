class GenerateCallerId {
  static String generateCallId(String otherId, String userID) {
    List<String> ids = [otherId, userID];
    ids.sort();
    return ids.join("_");
  }


}