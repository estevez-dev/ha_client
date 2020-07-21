part of '../../main.dart';


class EntitiesMap extends StatelessWidget {

  final List<EntityWrapper> entities;
  final bool interactive;
  final double aspectRatio;

  const EntitiesMap({Key key, this.entities: const [], this.aspectRatio, this.interactive: false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    List<LatLng> points = [];
    entities.forEach((entityWrapper) {
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
    Widget map = FlutterMap(
      options: new MapOptions(
        interactive: false,
        bounds: LatLngBounds.fromPoints(points),
        boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(40)),
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
    );
    if (aspectRatio != null) {
      return AspectRatio(
          aspectRatio: aspectRatio,
          child: map
      );
    }
    return map;
  }

}