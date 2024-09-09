import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:movie_app_project/controllers/main_page_data_controller.dart';
import 'package:movie_app_project/models/main_page_data.dart';

import '../models/search_categorie.dart';
import '../models/movie.dart';

//widgets
import '../widgets/movie_tile.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController>((ref) {
  return MainPageDataController();
});

final selectedMoviePosterURLProvider = StateProvider<String?>((ref) {
  final _movies = ref.watch(mainPageDataControllerProvider.state).movies!;
  return _movies.length != 0 ? _movies[0].posterURL() : null;
});

class MainPage extends ConsumerWidget {
  double? _deviceheight;
  double? _devicewidth;

  late var _selectedMoviePosterUrl;

  late MainPageDataController? _mainPageDataController;
  late MainPageData? _mainPageData;

  TextEditingController? _searchTextFieldController;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    _deviceheight = MediaQuery.of(context).size.height;
    _devicewidth = MediaQuery.of(context).size.width;

    _mainPageDataController = watch(mainPageDataControllerProvider);
    _mainPageData = watch(mainPageDataControllerProvider.state);

    _selectedMoviePosterUrl = watch(selectedMoviePosterURLProvider);
    _searchTextFieldController = TextEditingController();

    _searchTextFieldController!.text = _mainPageData!.searchText!;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Container(
        height: _deviceheight,
        width: _devicewidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _backgroudWidget(),
            _forgroundWidget(),
          ],
        ),
      ),
    );
  }

  Widget _backgroudWidget() {
    // default background image

    if (_selectedMoviePosterUrl.state != null) {
      return Container(
        height: _deviceheight,
        width: _devicewidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: NetworkImage(_selectedMoviePosterUrl.state),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: _deviceheight,
        width: _devicewidth,
        color: Colors.black,
      );
    }
  }

  Widget _forgroundWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, _deviceheight! * 0.02, 0, 0),
      width: _devicewidth! * 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _topBarWidget(),
          Container(
            height: _deviceheight! * 0.83,
            padding: EdgeInsets.symmetric(vertical: _deviceheight! * 0.01),
            child: _movieListWidget(),
          )
        ],
      ),
    );
  }

  Widget _topBarWidget() {
    return Container(
      height: _deviceheight! * 0.08,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchFieldWidget(),
          _categorieSelectionWidget(),
        ],
      ),
    );
  }

  Widget _searchFieldWidget() {
    final _border = InputBorder.none;
    return Container(
      width: _devicewidth! * 0.50,
      height: _deviceheight! * 0.05,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (_input) =>
            _mainPageDataController!.updateTextSearch!(_input),
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            focusedBorder: _border,
            border: _border,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            hintStyle: TextStyle(color: Colors.white54),
            filled: false,
            fillColor: Colors.white24,
            hintText: 'Search...'),
      ),
    );
  }

  Widget _categorieSelectionWidget() {
    return DropdownButton(
      dropdownColor: Colors.black38,
      value: _mainPageData!.searchCategory,
      icon: Icon(
        Icons.menu,
        color: Colors.white24,
      ),
      underline: Container(
        height: 1,
        color: Colors.white24,
      ),
      onChanged: (dynamic _value) => _value.toString().isNotEmpty
          ? _mainPageDataController!.updateSearchCategoreie!(_value)
          : null,
      items: [
        DropdownMenuItem(
          child: Text(
            SearchCategory.popular,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.popular,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.upcoming,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.upcoming,
        ),
        DropdownMenuItem(
          child: Text(
            SearchCategory.none,
            style: TextStyle(color: Colors.white),
          ),
          value: SearchCategory.none,
        ),
      ],
    );
  }

  Widget _movieListWidget() {
    final List<Movie> _movies = _mainPageData!.movies!;

    // First display bech nchouf static movie from postman
    // for (var i = 0; i < 9; i++) {
    //   _movies.add(
    //     Movie(
    //       name: 'Trolls Band Together',
    //       language: 'EN',
    //       isAdult: false,
    //       description:
    //           "When Branch’s brother, Floyd, is kidnapped for his musical talents by a pair of nefarious pop-star villains, Branch and Poppy embark on a harrowing and emotional journey to reunite the other brothers and rescue Floyd from a fate even worse than pop-culture obscurity",
    //       posterPath: '/bkpPTZUdq31UGDovmszsg2CchiI.jpg',
    //       releaseDate: '2023-10-12',
    //       backdropPath: '/xgGGinKRL8xeRkaAR9RMbtyk60y.jpg',
    //       rating: 7.5,
    //     ),
    //   );
    // }
    if (_movies.length != 0) {
      return NotificationListener(
        onNotification: (_onScrollNotification) {
          if (_onScrollNotification is ScrollEndNotification) {
            final before = _onScrollNotification.metrics.extentBefore;
            final max = _onScrollNotification.metrics.maxScrollExtent;
            if (before == max) {
              _mainPageDataController!.getMovies!();
              return true;
            }
            return false;
          }
          return false;
        },
        child: ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (BuildContext _context, int _count) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: _deviceheight! * 0.01, horizontal: 0),
                child: GestureDetector(
                  onTap: () {
                    _selectedMoviePosterUrl.state = _movies[_count].posterURL();
                  },
                  child: MovieTile(
                    movie: _movies[_count],
                    height: _deviceheight! * 0.20,
                    width: _devicewidth! * 0.85,
                  ), // Text(_movies[_count].name?? 'Default Name'),
                ),
              );
            }),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );
    }
  }
}
