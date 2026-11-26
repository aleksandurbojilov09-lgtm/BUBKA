import 'package:flutter/widgets.dart';

class BubkaApp extends StatelessWidget {
  const BubkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'BUBKA',
      color: const Color(0xFFFFFFFF),
      debugShowCheckedModeBanner: false,
      textStyle: const TextStyle(color: Color(0xFF000000), fontSize: 16),
      builder: (context, child) => const ColoredBox(
        color: Color(0xFFFFFFFF),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('BUBKA'), Text('0.0.1')],
            ),
          ),
        ),
      ),
    );
  }
}
