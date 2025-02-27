import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(MyApp());
}

// Main App Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Aggregator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NewsHomePage(),
    );
  }
}

// News Homepage
class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  late Future<List<dynamic>> newsArticles;

  @override
  void initState() {
    super.initState();
    newsArticles = NewsService.fetchNews(); // Fetch news when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News Aggregator")),
      body: FutureBuilder(
        future: newsArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading news")); // Handle error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No news available")); // No news case
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(article['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(article['description'] ?? 'No description available'),
                    leading: article['urlToImage'] != null
                        ? Image.network(article['urlToImage'], width: 80, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported),
                    onTap: () => launchURL(article['url']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// News Service Class for Fetching News
class NewsService {
  static const String apiKey = 'af927b1b3df04f9aadcf55703a27a9b6'; // Replace with your API key
  static const String url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

  static Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles']; // Extract articles from response
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }
}

// Function to Open News URL
void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
