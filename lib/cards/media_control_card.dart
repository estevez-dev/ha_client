part of '../main.dart';

class MediaControlsCard extends StatelessWidget {
  final MediaControlCardData card;

  const MediaControlsCard({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.entity.entity.statelessType == StatelessEntityType.missed) {
      return EntityModel(
        entityWrapper: card.entity,
        child: MissedEntityWidget(),
        handleTap: false,
      );
    }
    return CardWrapper(
        child: EntityModel(
            entityWrapper: card.entity,
            handleTap: null,
            child: MediaPlayerWidget()
        )
    );
  }

  
}