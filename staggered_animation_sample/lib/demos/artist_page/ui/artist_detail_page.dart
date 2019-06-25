import 'dart:ui' as ui;

import '../../../staggered_animation.dart';
import '../data/models.dart';
import 'video_card.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class ArtistDetailsPage extends StatelessWidget {
  ArtistDetailsPage({
    @required this.artist,
  });

  final Artist artist;

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildVideoScroller(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedStep(
      index: 1,
      curve: Curves.elasticOut,
      builder: (context, child, time) => Transform(
          transform: Matrix4.diagonal3Values(
            time,
            time,
            1.0,
          ),
          alignment: Alignment.center,
          child: child),
      child: Container(
        width: 110.0,
        height: 110.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30),
        ),
        margin: const EdgeInsets.only(top: 32.0, left: 16.0),
        padding: const EdgeInsets.all(3.0),
        child: ClipOval(
          child: Image.asset(artist.avatar),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedStep.fade(
            index: 2,
            child: Text(
              artist.firstName + '\n' + artist.lastName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
          ),
          AnimatedStep.fade(
            index: 3,
            child: Text(artist.location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                )),
          ),
          AnimatedStep(
              index: 4,
              curve: Curves.fastOutSlowIn,
              builder: (context, child, time) => Container(
                    child: child,
                    width: time * 225.0,
                    height: 1.0,
                    color: Colors.white.withOpacity(0.55 * time),
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
              child: SizedBox()),
          AnimatedStep.fade(
            index: 5,
            child: Text(
              artist.biography,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoScroller() {
    return AnimatedStep.slide(
      index: 6,
      duration: 3,
      from: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox.fromSize(
          size: Size.fromHeight(245.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: artist.videos.length,
            itemBuilder: (BuildContext context, int index) {
              var video = artist.videos[index];
              return VideoCard(video);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      delay: 5,
      duration: const Duration(milliseconds: 1200),
      child: Scaffold(
        body: AnimatedStep(
          index: 0,
          duration: 3,
          child: _buildContent(),
          builder: (context, child, time) => Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.5 + 0.5 * time,
                    child: Image.asset(
                      artist.backdropPhoto,
                      fit: BoxFit.cover,
                    ),
                  ),
                  BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 5.0 * time,
                      sigmaY: 5.0 * time,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: child,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
