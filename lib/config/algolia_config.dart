import 'package:algolia/algolia.dart';

class AlgoliaApplication{
  // ignore: prefer_const_constructors
  static final Algolia algolia =  Algolia.init(
    applicationId: 'HFCBBSGQ73', //ApplicationID
    apiKey: '0af3761cf932c61a0c4c157e313058e0', //search-only api key in flutter code
  );
}