import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'plugins/circular_slider/single_circular_slider.dart';
import 'package:share/receive_share_state.dart';
import 'package:share/share.dart';

import 'utils/logger.dart';

part 'const.dart';
part 'utils/launcher.dart';
part 'entities/entity.class.dart';
part 'entities/entity_wrapper.class.dart';
part 'entities/timer/timer_entity.class.dart';
part 'entities/switch/switch_entity.class.dart';
part 'entities/button/button_entity.class.dart';
part 'entities/text/text_entity.class.dart';
part 'entities/climate/climate_entity.class.dart';
part 'entities/cover/cover_entity.class.dart';
part 'entities/date_time/date_time_entity.class.dart';
part 'entities/light/light_entity.class.dart';
part 'entities/select/select_entity.class.dart';
part 'entities/sun/sun_entity.class.dart';
part 'entities/sensor/sensor_entity.class.dart';
part 'entities/slider/slider_entity.dart';
part 'entities/media_player/media_player_entity.class.dart';
part 'entities/lock/lock_entity.class.dart';
part 'entities/group/group_entity.class.dart';
part 'entities/fan/fan_entity.class.dart';
part 'entities/automation/automation_entity.class.dart';
part 'entities/camera/camera_entity.class.dart';
part 'entities/alarm_control_panel/alarm_control_panel_entity.class.dart';
part 'entity_widgets/common/badge.dart';
part 'entity_widgets/model_widgets.dart';
part 'entity_widgets/default_entity_container.dart';
part 'entity_widgets/missed_entity.dart';
part 'cards/widgets/glance_card_entity_container.dart';
part 'cards/widgets/entity_button_card_body.widget.dart';
part 'entity_widgets/common/entity_attributes_list.dart';
part 'entity_widgets/entity_icon.dart';
part 'entity_widgets/entity_name.dart';
part 'entity_widgets/common/last_updated.dart';
part 'entity_widgets/common/mode_swicth.dart';
part 'entity_widgets/common/mode_selector.dart';
part 'entity_widgets/common/universal_slider.dart';
part 'entity_widgets/common/flat_service_button.dart';
part 'entity_widgets/common/light_color_picker.dart';
part 'entity_widgets/common/camera_stream_view.dart';
part 'entity_widgets/entity_colors.class.dart';
part 'entity_widgets/entity_page_container.dart';
part 'entity_widgets/history_chart/entity_history.dart';
part 'entity_widgets/history_chart/simple_state_history_chart.dart';
part 'entity_widgets/history_chart/numeric_state_history_chart.dart';
part 'entity_widgets/history_chart/combined_history_chart.dart';
part 'entity_widgets/history_chart/history_control_widget.dart';
part 'entity_widgets/history_chart/entity_history_moment.dart';
part 'entities/switch/widget/switch_state.dart';
part 'entities/slider/widgets/slider_controls.dart';
part 'entities/text/widgets/text_input_state.dart';
part 'entities/select/widgets/select_state.dart';
part 'entity_widgets/common/simple_state.dart';
part 'entities/timer/widgets/timer_state.dart';
part 'entities/climate/widgets/climate_state.widget.dart';
part 'entities/cover/widgets/cover_state.dart';
part 'entities/date_time/widgets/date_time_state.dart';
part 'entities/lock/widgets/lock_state.dart';
part 'entities/climate/widgets/climate_controls.dart';
part 'entities/climate/widgets/temperature_control_widget.dart';
part 'entities/cover/widgets/cover_controls.widget.dart';
part 'entities/light/widgets/light_controls.dart';
part 'entities/media_player/widgets/media_player_widgets.dart';
part 'entities/fan/widgets/fan_controls.dart';
part 'entities/alarm_control_panel/widgets/alarm_control_panel_controls.widget.dart';
part 'pages/settings.page.dart';
part 'pages/purchase.page.dart';
part 'pages/widgets/product_purchase.widget.dart';
part 'pages/widgets/page_loading_indicator.dart';
part 'pages/widgets/page_loading_error.dart';
part 'pages/panel.page.dart';
part 'pages/main.page.dart';
part 'home_assistant.class.dart';
part 'pages/log.page.dart';
part 'pages/entity.page.dart';
part 'mdi.class.dart';
part 'entity_collection.class.dart';
part 'managers/auth_manager.class.dart';
part 'managers/location_manager.class.dart';
part 'managers/mobile_app_integration_manager.class.dart';
part 'managers/connection_manager.class.dart';
part 'managers/device_info_manager.class.dart';
part 'managers/startup_user_messages_manager.class.dart';
part 'ui.dart';
part 'view.class.dart';
part 'cards/card.class.dart';
part 'panels/panel_class.dart';
part 'view.dart';
part 'cards/card_widget.dart';
part 'cards/widgets/card_header.widget.dart';
part 'panels/config_panel_widget.dart';
part 'panels/widgets/link_to_web_config.dart';
part 'types/ha_error.dart';
part 'types/event_bus_events.dart';
part 'cards/widgets/gauge_card_body.dart';
part 'cards/widgets/light_card_body.dart';
part 'pages/play_media.page.dart';


EventBus eventBus = new EventBus();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
const String appName = "HA Client";
const appVersion = "0.6.5";

void main() async {
  FlutterError.onError = (errorDetails) {
    Logger.e( "${errorDetails.exception}");
    if (Logger.isInDebugMode) {
      FlutterError.dumpErrorToConsole(errorDetails);
    }
  };

  runZoned(() {
    //AndroidAlarmManager.initialize().then((_) {
      runApp(new HAClientApp());
    //  print("Running MAIN isolate ${Isolate.current.hashCode}");
    //});

  }, onError: (error, stack) {
    Logger.e("$error");
    Logger.e("$stack");
    if (Logger.isInDebugMode) {
      debugPrint("$stack");
    }
  });
}

class HAClientApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: appName,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => MainPage(title: 'HA Client'),
        "/connection-settings": (context) => ConnectionSettingsPage(title: "Settings"),
        "/putchase": (context) => PurchasePage(title: "Support app development"),
        "/play-media": (context) => PlayMediaPage(mediaUrl: "${ModalRoute.of(context).settings.arguments != null ? (ModalRoute.of(context).settings.arguments as Map)['url'] : ''}",),
        "/log-view": (context) => LogViewPage(title: "Log"),
        "/login": (context) => WebviewScaffold(
          url: "${ConnectionManager().oauthUrl}",
          appBar: new AppBar(
            leading: IconButton(
                icon: Icon(Icons.help),
                onPressed: () => Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/docs#authentication")
            ),
            title: new Text("Login with HA"),
            actions: <Widget>[
              FlatButton(
                child: Text("Manual", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  eventBus.fire(ShowPageEvent(path: "/connection-settings", goBackFirst: true));
                },
              )
            ],
          ),
        ),
        "/webview": (context) => WebviewScaffold(
          url: "${(ModalRoute.of(context).settings.arguments as Map)['url']}",
          appBar: new AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()
            ),
            title: new Text("${(ModalRoute.of(context).settings.arguments as Map)['title']}"),
          ),
        )
      },
    );
  }
}