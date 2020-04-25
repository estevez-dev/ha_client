part of '../main.dart';

class MediaControlsCard extends StatelessWidget {
  final HACard card;

  const MediaControlsCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
        child: EntityModel(
            entityWrapper: card.linkedEntityWrapper,
            handleTap: null,
            child: MediaPlayerWidget()
        )
    );
  }

  
}