import 'package:url_launcher/url_launcher.dart';

launchUrl(String url) async {
  print("_launchUrl");
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
