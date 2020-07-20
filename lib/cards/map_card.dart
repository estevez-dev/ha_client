part of '../main.dart';

class MapCard extends StatefulWidget {
  final MapCardData card;

  const MapCard({Key key, this.card}) : super(key: key);

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {

  GlobalKey _mapKey = new GlobalKey();
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    List<LatLng> points = [];
    widget.card.entities.forEach((entityWrapper) {
      double lat = entityWrapper.entity._getDoubleAttributeValue("latitude");
      double long = entityWrapper.entity._getDoubleAttributeValue("longitude");
      if (lat != null && long != null) {
        points.add(LatLng(lat, long));
        markers.add(
            Marker(
                width: 36,
                height: 36,
                point: LatLng(lat, long),
                builder: (ctx) => EntityModel(
                  handleTap: true,
                  entityWrapper: entityWrapper,
                  child: EntityIcon(
                    size: 36,
                  ),
                )
            )
        );
      }
    });
    return CardWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CardHeader(name: widget.card.title),
            AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                child: FlutterMap(
                  key: _mapKey,
                  mapController: mapController,
                  options: new MapOptions(
                    interactive: true,
                    bounds: LatLngBounds.fromPoints(points),
                    boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(30)),
                  ),
                  layers: [
                    new TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']
                    ),
                    new MarkerLayerOptions(
                      markers: markers,
                    ),
                  ],
                )
              ),
            )
          ],
        )
    );
  }
}