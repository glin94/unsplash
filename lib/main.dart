import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unsplash_app/provider.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'model/photo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MyHomePage(title: 'UNSPLASH'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool gridView = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () => setState(() => gridView = !gridView),
              icon: Icon(gridView ? Icons.view_list : Icons.grid_on))
        ],
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? gridView
                  ? PhotoGrid(list: snapshot.data)
                  : PhotoList(
                      list: snapshot.data,
                    )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotoGrid extends StatelessWidget {
  final List<Photo> list;
  const PhotoGrid({Key key, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return GridView.count(
          physics: BouncingScrollPhysics(),
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          children: list
              .map<Widget>((item) => PhotoGridItem(
                    item: item,
                  ))
              .toList());
    });
  }
}

class PhotoGridItem extends StatelessWidget {
  final Photo item;
  const PhotoGridItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    Card(
      elevation: 7, 
      child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailScreen(
                          item: item,
                        ))),
            child:  Hero(
                tag: item.id,
                child: CachedNetworkImage(
                  imageUrl: item.urls["regular"],
                  fit: BoxFit.cover,
                  placeholder: (c, s) => Container(),
                ),
              ),
            ),
            Positioned(
              top: 5,left: 5,
              child:  Row(
                  children: <Widget>[
                    new Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                item.user['profile_image']['medium'])),
                      ),
                    ),
                  SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      item.user['username'],
                      style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
                    )
                  ],
                )),
                Positioned(
                  bottom: 0,left: 0,right: 0,
                  child: 
                  Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(200, 0, 0, 0),
                   Color.fromARGB(0, 0, 0, 0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Text(
                        item.desc??item.altDesc??"",
                        maxLines: 1,
                        style: TextStyle(color: Colors.white,fontSize: 10),
                      ),
            ))
                
      ],
    ));

  
  }
}

class PhotoList extends StatelessWidget {
  final List<Photo> list;

  const PhotoList({
    Key key,
    this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (c, i) => PhotoListItem(
              item: list[i],
            ));
  }
}

class PhotoListItem extends StatelessWidget {
  final Photo item;
  const PhotoListItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      new Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  item.user['profile_image']['medium'])),
                        ),
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      new Text(
                        item.user['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Text(parseDate(item.createdAt),
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(
                              item: item,
                            ))),
                child: Hero(
                  tag: item.id,
                  child: CachedNetworkImage(
                    imageUrl: item.urls["regular"],
                    fit: BoxFit.cover,
                    placeholder: (c, s) => Container(
                      height: MediaQuery.of(context).size.height/4,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: 
                 Text(item.desc ?? item.altDesc ?? "",
                 textScaleFactor: 1.1,),
                  )
          ],
        
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Photo item;
  const DetailScreen({Key key, this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
        Hero(
            tag: item.id,
            child: CachedNetworkImage(
              imageUrl: item.urls["regular"],
              fit: BoxFit.contain,
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item.desc ?? item.altDesc ?? "",
              textScaleFactor: 1.3,
              style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ]),
    ));
  }
}

String parseDate(String s) {
  s.replaceAll("T", " ");
  DateTime d = DateTime.parse(s);
  return timeago.format(
    d,
    allowFromNow: true,
  );
}
