import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/app_details.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({Key? key}) : super(key: key);

  _launchGithub() {
    launchUrl(
      Uri.parse(AppDetails.repositoryLink),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? themeColorApp = Theme.of(context).colorScheme.primary;

    return Scaffold(
        appBar: AppBar(
          title: const Text("App Info"),
        ),
        body: ListView(children: <Widget>[
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blueAccent,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text("${AppDetails.appName} ${AppDetails.appVersion}",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: themeColorApp)),
          ),
          const SizedBox(height: 15),
          ListTile(
            title: Text("Dev",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeColorApp)),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              "Application created using Flutter and the Dart language, used for testing and learning.",
            ),
          ),
          ListTile(
            title: Text("Source Code",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeColorApp)),
          ),
          ListTile(
            onTap: () {
              _launchGithub();
            },
            leading: const Icon(Icons.open_in_new_outlined),
            title: const Text("View on GitHub",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    color: Colors.blue)),
          ),
          ListTile(
            title: Text("Quote",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeColorApp)),
          ),
          const ListTile(
            leading: Icon(Icons.messenger_outline),
            title: Text(
              "Greetings, my friend. We are all interested in the future, for that is where you and I are going to spend the rest of our lives. "
              "And remember, my friend: Future events such as these will affect you in the future. "
              "You are interested in the unknown, the mysterious, the unexplainable. "
              "That is why you are here. And now, for the first time, we are bringing to you the full story of what happened on that fateful day. "
              "We are giving you all the evidence, based only on the secret testimony of the miserable souls who survived this terrifying ordeal. "
              "The incidents, the places. My friend, we cannot keep this a secret any longer. Let us punish the guilty; let us reward the innocent. "
              "My friend, can your heart stand the shocking facts about grave robbers from outer space?",
            ),
          ),
        ]));
  }
}
