import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'dart:io';

const String appTitle = 'RPC-Tool (now in flutter!)';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle(appTitle);
    await windowManager.setSize(const Size(700, 800));
    await windowManager.setMinimumSize(const Size(500, 500));
    int build = int.tryParse(getWindowsBuild()) ?? 0;
    if (Platform.isWindows && build < 22000) {
      await windowManager.setBackgroundColor(SystemTheme.isDarkMode ? Colors.black : Colors.white);
    }
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });

  await SystemTheme.accentColor.load();
  WindowEffect effect = WindowEffect.disabled;
  if (Platform.isWindows) {
    int build = int.tryParse(getWindowsBuild()) ?? 0;
    if (build >= 22000) {
      effect = WindowEffect.mica;
    } else {
      effect = WindowEffect.disabled;
    }
  }
  await Window.setEffect(
    effect: effect,
    dark: SystemTheme.isDarkMode,
  );

  DiscordRPC.initialize();

  runApp(const MyApp());
}

String getWindowsBuild() {
  String version = Platform.operatingSystemVersion;
  RegExp exp = RegExp(r'([0-9]{5})');

  return exp.firstMatch(version)![0] ?? "";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'RPC-Tool',
      theme: FluentThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'RPC-Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String clientID = "";
  String details = "";
  String state = "";
  String startTime = "";
  String endTime = "";
  String imageKey = "";
  String imageText = "";
  String smallImageKey = "";
  String smallImageText = "";
  String partyID = "";
  String partySize = "";
  String partyMax = "";

  bool started = false;

  late DiscordRPC rpc;
  FlyoutController controller = FlyoutController();

  void startRPC() {
    rpc = DiscordRPC(applicationId: clientID);
    rpc.start(autoRegister: true);

    int? start = int.tryParse(startTime);
    int? end = int.tryParse(endTime);

    int? size = int.tryParse(partySize);
    int? max = int.tryParse(partyMax);

    rpc.updatePresence(
      DiscordPresence(
        state: state,
        details: details,
        startTimeStamp: start,
        endTimeStamp: end,
        largeImageKey: imageKey,
        largeImageText: imageText,
        smallImageKey: smallImageKey,
        smallImageText: smallImageText,
        partyId: partyID,
        partySize: size,
        partySizeMax: max,
      ),
    );

    displayInfoBar(context, builder: (context, close) {
      return const InfoBar(
        title: Text('Started RPC!'),
        severity: InfoBarSeverity.success,
      );
    });

    setState(() {
      started = !started;
    });
  }

  void stopRPC() {
    rpc.clearPresence();
    rpc.shutDown();

    displayInfoBar(context, builder: (context, close) {
      return const InfoBar(
        title: Text('Stopped RPC!'),
        severity: InfoBarSeverity.success,
      );
    });

    setState(() {
      started = !started;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: ScaffoldPage.scrollable(
          bottomBar:
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 10, top: 10),
              child: FilledButton(
                child: Text('Start'),
                onPressed: started ? null : startRPC,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              child: Button(
                child: Text('Stop'),
                onPressed: started ? stopRPC : null,
                focusable: false,
              ),
            )
          ]),
          children: <Widget>[
            InfoLabel(
              label: 'Enter client ID:',
              child: TextBox(
                placeholder: 'Client ID',
                expands: false,
                onChanged: (str) {
                  clientID = str;
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Text',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                InfoLabel(
                  label: 'Top text:',
                  child: TextBox(
                    placeholder: 'Details',
                    expands: false,
                    onChanged: (str) {
                      details = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Bottom text:',
                  child: TextBox(
                    placeholder: 'State',
                    expands: false,
                    onChanged: (str) {
                      state = str;
                    },
                  ),
                ),
              ]
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: w,
                      ))
                  .toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Timestamp',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                InfoLabel(
                  label: 'Start:',
                  child: TextBox(
                    placeholder: 'Start timestamp in ms',
                    expands: false,
                    onChanged: (str) {
                      startTime = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'End:',
                  child: TextBox(
                    placeholder: 'End timestamp in ms',
                    expands: false,
                    onChanged: (str) {
                      endTime = str;
                    },
                  ),
                ),
              ]
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: w,
                      ))
                  .toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Large image',
                    style: FluentTheme.of(context).typography.subtitle),
                InfoLabel(
                  label: 'Key:',
                  child: TextBox(
                    placeholder: 'Pretty self-explanatory',
                    expands: false,
                    onChanged: (str) {
                      imageKey = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Text:',
                  child: TextBox(
                    placeholder: 'Text of large image when you hover over it',
                    expands: false,
                    onChanged: (str) {
                      imageText = str;
                    },
                  ),
                ),
              ]
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: w,
                      ))
                  .toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Small image',
                    style: FluentTheme.of(context).typography.subtitle),
                InfoLabel(
                  label: 'Key:',
                  child: TextBox(
                    placeholder: 'Pretty self-explanatory',
                    expands: false,
                    onChanged: (str) {
                      smallImageKey = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Text:',
                  child: TextBox(
                    placeholder: 'Pretty self-explanatory too',
                    expands: false,
                    onChanged: (str) {
                      smallImageText = str;
                    },
                  ),
                ),
              ]
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: w,
                      ))
                  .toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Party',
                    style: FluentTheme.of(context).typography.subtitle),
                InfoLabel(
                  label: 'Party ID:',
                  child: TextBox(
                    placeholder: 'Any value',
                    expands: false,
                    onChanged: (str) {
                      partyID = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Party size:',
                  child: TextBox(
                    placeholder: 'Optional',
                    expands: false,
                    onChanged: (str) {
                      partySize = str;
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Party max:',
                  child: TextBox(
                    placeholder: 'Optional',
                    expands: false,
                    onChanged: (str) {
                      partyMax = str;
                    },
                  ),
                ),
              ]
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: w,
                      ))
                  .toList(),
            ),
            Text('Windows version: ${Platform.operatingSystemVersion}')
          ]
              .map((w) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    child: w,
                  ))
              .toList(),
        ),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Button(
          style: ButtonStyle(
            backgroundColor: ButtonState.all<Color>(Colors.transparent),
            border: ButtonState.all<BorderSide>(BorderSide.none),
          ),
          child: const Text('File'),
          onPressed: () {},
        ),
        Button(
          style: ButtonStyle(
            backgroundColor: ButtonState.all<Color>(Colors.transparent),
            border: ButtonState.all<BorderSide>(BorderSide.none),
          ),
          child: const Text('Help'),
          onPressed: () {},
        )
      ].map((w) => Padding(padding: const EdgeInsets.only(right: 5), child: w)).toList()),
    ]);
  }
}
