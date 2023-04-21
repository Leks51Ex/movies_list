import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovieSearchPage(),
    );
  }
}

class MovieSearchPage extends StatefulWidget {
  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  List<Movie> _movies = [];
  String _searchText = "";
  bool _isLoading = false;

  Future<void> _searchMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.kinopoisk.dev/movie?search=$_searchText&token=FPKKB3A-CN44SB8-PMHEWRT-QRF6W34'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final moviesJson = jsonResponse['data']['movies'];
        setState(() {
          _movies = List<Movie>.from(
              moviesJson.map((movieJson) => Movie.fromJson(movieJson)));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter movie title',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchMovies();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: _movies.length,
                    itemBuilder: (BuildContext context, int index) {
                      final movie = _movies[index];
                      return ListTile(
                        title: Text(movie.title),
                        subtitle: Text(movie.year),
                        leading: movie.posterUrl != null
                            ? Image.network(movie.posterUrl)
                            : Container(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Movie {
  final String title;
  final String year;
  final String posterUrl;

  Movie({required this.title, required this.year, required this.posterUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      year: json['year'],
      posterUrl: json['posterUrl'],
    );
  }
}
