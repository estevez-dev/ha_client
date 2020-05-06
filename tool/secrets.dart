import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'syncfusion_license_key': Platform.environment['SYNCFUSION_LICENSE_KEY'],
    'version_type': Platform.environment['HA_CLIENT_VERSION_TYPE']
  };

  final filename = 'lib/.secrets.dart';
  File(filename).writeAsString('final secrets = ${json.encode(config)};');
}