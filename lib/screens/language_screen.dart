import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  LanguagesScreenState createState() => LanguagesScreenState();
}

class LanguagesScreenState extends State<LanguagesScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.language,
      child: LanguageListWidget(
        widgetType: WidgetType.LIST,
        onLanguageChange: (v) async {
          await appStore.setLanguage(v.languageCode!);
          setState(() {});

          // Force app restart to apply font changes
          RestartAppWidget.init(context);
        },
      ),
    );
  }
}
