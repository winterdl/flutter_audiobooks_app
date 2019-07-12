import 'package:audiobooks/resources/models/models.dart';
import 'package:audiobooks/resources/repository.dart';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'package:webfeed/webfeed.dart';

final _metadata = "https://archive.org/metadata/";
final _commonParams = "q=collection:(librivoxaudio)&fl=runtime,avg_rating,num_reviews,title,description,identifier,creator,date,downloads,subject,item_size";

final _latestBooksApi = "https://archive.org/advancedsearch.php?$_commonParams&sort[]=addeddate desc&output=json";

final _highestRated = "https://archive.org/advancedsearch.php?$_commonParams&sort[]=avg_rating desc&rows=50&page=1&output=json";
  final query="title:(secret tomb) AND collection:(librivoxaudio)";

class ArchiveApiProvider implements Source{

  Client client = Client();

  Future<List<Book>> fetchBooks(int offset, int limit) async {
    final response = await client.get("$_latestBooksApi&rows=$limit&page=${offset/limit + 1}");
    Map resJson = json.decode(response.body);
    return Book.fromJsonArray(resJson['response']['docs']);
  }

  Future<List<AudioFile>> fetchAudioFiles(String bookId, String url) async {
    if(url == null) return null;
    final response = await client.get(url);
    final String feed = response.body;
    RssFeed rssFeed = RssFeed.parse(feed);
    List<AudioFile> afiles = List<AudioFile>();
    rssFeed.items.forEach((item)=>afiles.add(AudioFile(
      bookId: bookId,
      title: item.title,
      link: item.enclosure.url
    )));
    return afiles;
  }

  @override
  Future<List<Book>> topBooks() async {
    final response = await client.get("$_highestRated");
    Map resJson = json.decode(response.body);
    return Book.fromJsonArray(resJson['response']['docs']);
  }

}

final archiveApiProvider = ArchiveApiProvider();