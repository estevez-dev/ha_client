part of '../main.dart';

class Launcher {

  static void launchURL(String url) async {
    if (await urlLauncher.canLaunch(url)) {
      await urlLauncher.launch(url);
    } else {
      Logger.e( "Could not launch $url");
    }
  }

  static void launchURLInCustomTab({BuildContext context, String url, bool enableDefaultShare: true, bool showPageTitle: true}) async {
    try {
      await launch(
        "$url",
        option: new CustomTabsOption(
          toolbarColor: context != null ? Theme.of(context).primaryColor : Colors.blue,
          enableDefaultShare: enableDefaultShare,
          enableUrlBarHiding: true,
          showPageTitle: showPageTitle,
          animation: new CustomTabsAnimation.slideIn(),
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      Logger.w("Can't open custom tab: ${e.toString()}");
      Logger.w("Launching in default browser");
      Launcher.launchURL(url);
    }
  }

}