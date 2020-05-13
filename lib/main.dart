import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'plugins/dynamic_multi_column_layout.dart';
import 'plugins/spoiler_card.dart';
import 'package:workmanager/workmanager.dart' as workManager;
import 'package:geolocator/geolocator.dart';
import 'package:battery/battery.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart' as standaloneWebview;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'utils/logger.dart';
import '.secrets.dart';

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
part 'entities/entity_model.widget.dart';
part 'entities/default_entity_container.widget.dart';
part 'entities/missed_entity.widget.dart';
part 'cards/entity_button_card.dart';
part 'pages/widgets/entity_attributes_list.dart';
part 'entities/entity_icon.widget.dart';
part 'entities/entity_name.widget.dart';
part 'pages/widgets/last_updated.dart';
part 'entities/climate/widgets/mode_swicth.dart';
part 'entities/climate/widgets/mode_selector.dart';
part 'entities/universal_slider.widget.dart';
part 'entities/flat_service_button.widget.dart';
part 'entities/light/widgets/light_color_picker.dart';
part 'entities/camera/widgets/camera_stream_view.dart';
part 'plugins/history_chart/entity_history.dart';
part 'plugins/history_chart/simple_state_history_chart.dart';
part 'plugins/history_chart/numeric_state_history_chart.dart';
part 'plugins/history_chart/combined_history_chart.dart';
part 'plugins/history_chart/history_control_widget.dart';
part 'plugins/history_chart/entity_history_moment.dart';
part 'entities/switch/widget/switch_state.dart';
part 'entities/slider/widgets/slider_controls.dart';
part 'entities/text/widgets/text_input_state.dart';
part 'entities/select/widgets/select_state.dart';
part 'entities/simple_state.widget.dart';
part 'entities/entity_picture.widget.dart';
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
part 'entities/vacuum/vacuum_entity.class.dart';
part 'entities/vacuum/widgets/vacuum_controls.dart';
part 'entities/vacuum/widgets/vacuum_state_button.dart';
part 'entities/error_entity_widget.dart';
part 'pages/settings/connection_settings.part.dart';
part 'pages/purchase.page.dart';
part 'pages/widgets/product_purchase.widget.dart';
part 'pages/widgets/page_loading_indicator.dart';
part 'pages/widgets/bottom_info_bar.dart';
part 'pages/widgets/page_loading_error.dart';
part 'pages/panel.page.dart';
part 'pages/main/main.page.dart';
part 'pages/settings/integration_settings.part.dart';
part 'pages/settings/app_settings.page.dart';
part 'pages/settings/lookandfeel_settings.part.dart';
part 'pages/zha_page.dart';
part 'pages/quick_start.page.dart';
part 'home_assistant.class.dart';
part 'pages/entity.page.dart';
part 'utils/mdi.class.dart';
part 'entity_collection.class.dart';
part 'managers/auth_manager.class.dart';
part 'managers/location_manager.class.dart';
part 'managers/mobile_app_integration_manager.class.dart';
part 'managers/connection_manager.class.dart';
part 'managers/device_info_manager.class.dart';
part 'managers/startup_user_messages_manager.class.dart';
part 'managers/theme_manager.dart';
part 'ui.dart';
part 'view.class.dart';
part 'cards/card.class.dart';
part 'panels/panel_class.dart';
part 'viewWidget.widget.dart';
part 'cards/widgets/card_header.widget.dart';
part 'panels/config_panel_widget.dart';
part 'panels/widgets/link_to_web_config.dart';
part 'types/ha_error.dart';
part 'types/event_bus_events.dart';
part 'cards/gauge_card.dart';
part 'cards/widgets/card_wrapper.widget.dart';
part 'cards/entities_card.dart';
part 'cards/alarm_panel_card.dart';
part 'cards/horizontal_srack_card.dart';
part 'cards/markdown_card.dart';
part 'cards/media_control_card.dart';
part 'cards/unsupported_card.dart';
part 'cards/error_card.dart';
part 'cards/vertical_stack_card.dart';
part 'cards/glance_card.dart';
part 'pages/play_media.page.dart';
part 'entities/entity_page_layout.widget.dart';
part 'entities/media_player/widgets/media_player_seek_bar.widget.dart';
part 'entities/media_player/widgets/media_player_progress_bar.widget.dart';
part 'pages/whats_new.page.dart';
part 'pages/fullscreen.page.dart';
part 'popups.dart';
part 'cards/badges.dart';
part 'managers/app_settings.dart';

EventBus eventBus = new EventBus();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
const String appName = 'HA Client';
const appVersionNumber = '1.0.1';
final String appVersionAdd = secrets['version_type'] ?? '';
final String appVersion = '$appVersionNumber${appVersionAdd.isNotEmpty ? '-' : ''}$appVersionAdd';
const whatsNewUrl = 'http://ha-client.app/service/whats_new_1.0.1.md';

Future<void> _reportError(dynamic error, dynamic stackTrace) async {
    // Print the exception to the console.
    if (Logger.isInDebugMode) {
      Logger.e('Caught error: $error', skipCrashlytics: true);
      Logger.p(stackTrace);
    }
    Crashlytics.instance.recordError(error, stackTrace);

}

void main() async {
  Crashlytics.instance.enableInDevMode = false;
  SyncfusionLicense.registerLicense(secrets['syncfusion_license_key']); 

  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.e("Caut Flutter runtime error: ${details.exception}", skipCrashlytics: true);
    if (Logger.isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    Crashlytics.instance.recordFlutterError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  AppTheme theme = AppTheme.values[prefs.getInt('app-theme') ?? AppTheme.defaultTheme.index];

  runZoned(() {
      runApp(new HAClientApp(
        theme: theme,
      ));
  }, onError: (error, stack) {
    _reportError(error, stack);
  });
}

class HAClientApp extends StatefulWidget {

  final AppTheme theme;

  const HAClientApp({Key key, this.theme: AppTheme.defaultTheme}) : super(key: key);

  @override
  _HAClientAppState createState() => new _HAClientAppState();

}

class _HAClientAppState extends State<HAClientApp> {
  StreamSubscription<List<PurchaseDetails>> _purchaseUpdateSubscription;
  StreamSubscription _themeChangeSubscription;
  AppTheme _currentTheme = AppTheme.defaultTheme;
  
  @override
  void initState() {
    InAppPurchaseConnection.enablePendingPurchases();
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _purchaseUpdateSubscription = purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
    _currentTheme = widget.theme;
    _themeChangeSubscription = eventBus.on<ChangeThemeEvent>().listen((event){
      setState(() {
        _currentTheme = event.theme;
      });
    });
    workManager.Workmanager.initialize(
      updateDeviceLocationIsolate,
      isInDebugMode: false
    );
    super.initState();
  }

  void _handlePurchaseUpdates(purchase) {
    if (purchase is List<PurchaseDetails>) {
      if (purchase[0].status == PurchaseStatus.purchased) {
        eventBus.fire(ShowPopupEvent(
          popup: Popup(
            title: "Thanks a lot!",
            body: "Thank you for supporting HA Client development!",
            positiveText: "Ok"
          )
        ));
      } else {
        Logger.d("Purchase change handler: ${purchase[0].status}");
      }
    } else {
      Logger.e("Something wrong with purchase handling. Got: $purchase");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: appName,
      theme: HAClientTheme().getThemeData(_currentTheme),
      darkTheme: HAClientTheme().darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => MainPage(title: 'HA Client'),
        "/app-settings": (context) => AppSettingsPage(),
        "/connection-settings": (context) => AppSettingsPage(showSection: AppSettingsSection.connectionSettings),
        "/integration-settings": (context) => AppSettingsPage(showSection: AppSettingsSection.integrationSettings),
        "/putchase": (context) => PurchasePage(title: "Support app development"),
        "/play-media": (context) => PlayMediaPage(
          mediaUrl: "${ModalRoute.of(context).settings.arguments != null ? (ModalRoute.of(context).settings.arguments as Map)['url'] : ''}",
          mediaType: "${ModalRoute.of(context).settings.arguments != null ? (ModalRoute.of(context).settings.arguments as Map)['type'] ?? '' : ''}",
        ),
        "/webview": (context) => standaloneWebview.WebviewScaffold(
          url: "${(ModalRoute.of(context).settings.arguments as Map)['url']}",
          appBar: new AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()
            ),
            title: new Text("${(ModalRoute.of(context).settings.arguments as Map)['title']}"),
          ),
        ),
        "/whats-new": (context) => WhatsNewPage(),
        "/quick-start": (context) => QuickStartPage(),
        "/haclient_zha": (context) => ZhaPage(),
        "/auth": (context) => new standaloneWebview.WebviewScaffold(
          url: "${ConnectionManager().oauthUrl}",
          appBar: new AppBar(
            leading: IconButton(
              icon: Icon(Icons.help),
              onPressed: () => Launcher.launchURLInCustomTab(context: context, url: "https://ha-client.app/help/connection")
            ),
            title: new Text("Login"),
            actions: <Widget>[
              FlatButton(
                child: Text("Long-lived token", style: Theme.of(context).textTheme.button.copyWith(
                  decoration: TextDecoration.underline
                )),
                onPressed: () {
                  eventBus.fire(ShowPopupEvent(
                    goBackFirst: true,
                    popup: TokenLoginPopup()
                  ));
                },
              )
            ],
          ),
        )
      },
    );
  }

  @override
  void dispose() {
    _purchaseUpdateSubscription.cancel();
    _themeChangeSubscription.cancel();
    super.dispose();
  }
}
