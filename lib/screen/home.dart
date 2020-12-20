import 'package:bytelus_track/model/track.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final List<Track> items = [
  //   Track(
  //       id: "4fcafb8e09b944238d56261f74bb35e4",
  //       trackName: "Black Head",
  //       trackBand: "Under The Black",
  //       releaseYear: 1997,
  //       image: "assets/images/black.png"),
  //   Track(
  //       id: "dd55231d26e64358a656210dce25be0f",
  //       trackName: "Red Lines",
  //       trackBand: "Red String",
  //       releaseYear: 2077,
  //       image: "assets/images/red.png"),
  //   Track(
  //       id: "4819cb36bd5f444fb4ddecbeb654f552",
  //       trackName: "Green Sky",
  //       trackBand: "Green Dreamers",
  //       releaseYear: 1962,
  //       image: "assets/images/green.png"),
  //   Track(
  //       id: "4faa1d62942f4a3192d45f6c195c01e7",
  //       trackName: "Blue Haze",
  //       trackBand: "Hazer",
  //       releaseYear: 2017,
  //       image: "assets/images/blue.png"),
  //   Track(
  //       id: "16b506809e6440d198ba4ef7ac443ed7",
  //       trackName: "Gray Lands",
  //       trackBand: "Future dealers",
  //       releaseYear: 1999,
  //       image: "assets/images/gray.png"),
  //   Track(
  //       id: "d0c4ad7de8294a5ca849bdc2320e05cb",
  //       trackName: "Brown Codes",
  //       trackBand: "Unknown Laces",
  //       releaseYear: 2003,
  //       image: "assets/images/brown.png"),
  //   Track(
  //       id: "afe293c319c3462dbfe17d77a08a456d",
  //       trackName: "Pink Bird",
  //       trackBand: "Boom Freak",
  //       releaseYear: 2009,
  //       image: "assets/images/pink.png"),
  //   Track(
  //       id: "37784c3735c947a5a56a92779cd092f6",
  //       trackName: "Purple Lies",
  //       trackBand: "Nonklo",
  //       releaseYear: 1967,
  //       image: "assets/images/purple.png"),
  //   Track(
  //       id: "34f46ec2f8934947a0606c65ccccf866",
  //       trackName: "Yellow Hazard",
  //       trackBand: "Toxicologist",
  //       releaseYear: 2020,
  //       image: "assets/images/yellow.png"),
  // ];

  TrackStatus _selectedTrackStatus = TrackStatus.neutral;
  @override
  Widget build(BuildContext context) {
    var tracks;

    if (_selectedTrackStatus == TrackStatus.neutral) {
      tracks = FirebaseFirestore.instance.collection('tracks');
    } else {
      tracks = FirebaseFirestore.instance
          .collection('tracks')
          .where("track_status", isEqualTo: _selectedTrackStatus.index);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Track List"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            filterBottons(),
            Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                  stream: tracks.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    var trackList = snapshot.data.docs
                        .map((i) => Track(
                              id: i.id,
                              image: i.data()["image"],
                              trackName: i.data()["track_name"],
                              trackBand: i.data()["track_band"],
                              releaseYear: i.data()["release_year"],
                              trackStatus:
                                  TrackStatus.values[i.data()["track_status"]],
                            ))
                        .toList();
                    return ListView.builder(
                        itemCount: trackList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TrackListItem(item: trackList[index]);
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Row filterBottons() {
    return Row(
      children: [
        Expanded(
          child: FlatButton(
            color: _selectedTrackStatus == TrackStatus.neutral
                ? Colors.grey
                : Colors.transparent,
            child: Text("All"),
            onPressed: () {
              setState(() {
                _selectedTrackStatus = TrackStatus.neutral;
              });
            },
          ),
        ),
        Expanded(
          child: FlatButton(
            color: _selectedTrackStatus == TrackStatus.like
                ? Colors.grey
                : Colors.transparent,
            child: Text("Liked List"),
            onPressed: () {
              setState(() {
                _selectedTrackStatus = TrackStatus.like;
              });
            },
          ),
        ),
        Expanded(
          child: FlatButton(
            color: _selectedTrackStatus == TrackStatus.disLike
                ? Colors.grey
                : Colors.transparent,
            child: Text("Disliked List"),
            onPressed: () {
              setState(() {
                _selectedTrackStatus = TrackStatus.disLike;
              });
            },
          ),
        )
      ],
    );
  }
}

class TrackListItem extends StatelessWidget {
  const TrackListItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Track item;

  @override
  Widget build(BuildContext context) {
    var trackFirebase =
        FirebaseFirestore.instance.collection('tracks').doc(item.id);
    return ListTile(
      leading: Image.asset("assets/images/${item.image}"),
      title: Text(item.trackName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.trackBand),
          Text(item.releaseYear.toString()),
        ],
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.heartBroken,
                    color: item.trackStatus == TrackStatus.disLike
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    if (item.trackStatus == TrackStatus.disLike) {
                      trackFirebase
                          .update({"track_status": TrackStatus.neutral.index});
                    } else
                      trackFirebase
                          .update({"track_status": TrackStatus.disLike.index});
                  }),
            ),
            Expanded(
              child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidHeart,
                    color: item.trackStatus == TrackStatus.like
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    if (item.trackStatus == TrackStatus.like) {
                      trackFirebase
                          .update({"track_status": TrackStatus.neutral.index});
                    } else
                      trackFirebase
                          .update({"track_status": TrackStatus.like.index});
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
