part of '../../main.dart';


class EntitiesMap extends StatelessWidget {

  final List<EntityWrapper> entities;
  final bool interactive;
  final double aspectRatio;
  final LatLng center;
  final double zoom;

  const EntitiesMap({Key key, this.entities: const [], this.aspectRatio, this.interactive: true, this.center, this.zoom}) : super(key: key);

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
    MapOptions mapOptions;
    if (center != null) {
      mapOptions = MapOptions(
        interactive: interactive,
        center: center,
        zoom: zoom ?? 10,
      );
    } else {
      mapOptions = MapOptions(
        interactive: interactive,
        bounds: LatLngBounds.fromPoints(points),
        boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(40)),
      );
    }
    Widget map = FlutterMap(
      options: mapOptions,
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