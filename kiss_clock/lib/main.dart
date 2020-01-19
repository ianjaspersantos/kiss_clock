import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vector_math/vector_math.dart' show radians;

import 'drawn_hand.dart';

final double radiansPerTick = radians(360 / 60);
final double radiansPerHour = radians(360 / 12);

final NumberToWord numberToWord = NumberToWord();

void main() {
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(
    ClockCustomizer((model) {
      return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ClockModel>.value(value: model),
          ChangeNotifierProvider<KissClockState>.value(value: KissClockState.initState()),
        ],
        child: KissClock(),
      );
    }),
  );
}

class KissClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ClockModel, KissClockState>(
      builder: (context, clockModel, kissClockState, child) {
        final hh = DateFormat(clockModel.is24HourFormat ? 'HH' : 'hh').format(kissClockState.dateTime).toInt();
        final mm = DateFormat('mm').format(kissClockState.dateTime).toInt();

        final hour = numberToWord.convert('en-in', hh).trim().capitalize();
        final minute = numberToWord.convert('en-in', mm).trim().capitalize();

        return AnimatedContainer(
          color: Theme.of(context).brightness == Brightness.light ? Colors.deepPurple : Colors.black,
          duration: const Duration(
            milliseconds: 400,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: <Widget>[
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: kissClockState.days.map<Widget>((json) {
                      final prefix = json['prefix'] as String;
                      final weekday = json['weekday'] as int;
                      final selected = weekday == kissClockState.dateTime.weekday;

                      final shadows = [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.amberAccent,
                          offset: Offset.zero,
                        ),
                      ];

                      final textStyleDay = TextStyle(
                        color: Colors.amber,
                        fontFamily: 'RobotoMono',
                        fontSize: constraints.maxHeight * 0.06,
                        fontStyle: FontStyle.normal,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w100,
                        height: 1.0,
                        letterSpacing: 2.0,
                        shadows: selected ? shadows : [],
                      );

                      return Text(
                        '$prefix',
                        style: textStyleDay,
                      );
                    }).toList(),
                  );
                },
              ),
              VerticalDivider(
                color: Colors.amber,
                thickness: 0.2,
                width: 48,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final drawnHandSecond = DrawnHand(
                            angleRadians: kissClockState.dateTime.second * radiansPerTick,
                            color: Colors.amberAccent[100],
                            size: 1.0,
                            thickness: 1.0,
                          );

                          final drawnHandMinute = DrawnHand(
                            angleRadians: kissClockState.dateTime.minute * radiansPerTick,
                            color: Colors.amberAccent[400],
                            size: 0.8,
                            thickness: 2.0,
                          );

                          final drawnHandHour = DrawnHand(
                            angleRadians: kissClockState.dateTime.hour * radiansPerHour + (kissClockState.dateTime.minute / 60) * radiansPerHour,
                            color: Colors.amberAccent[700],
                            size: 0.6,
                            thickness: 4.0,
                          );

                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.deepPurple : Colors.black,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5.0,
                                  color: Colors.amber[50],
                                  offset: Offset(-2.0, -2.0),
                                ),
                                BoxShadow(
                                  blurRadius: 5.0,
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.amber,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                drawnHandSecond,
                                drawnHandMinute,
                                drawnHandHour,
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final shadows = [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.amberAccent,
                              offset: Offset.zero,
                            ),
                          ];

                          final textStyleHour = TextStyle(
                            color: Colors.amber,
                            fontFamily: 'RobotoMono',
                            fontSize: constraints.maxHeight / 2.7,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            letterSpacing: 2.0,
                            shadows: shadows,
                          );

                          final textStyleMinute = TextStyle(
                            color: Colors.amber[50],
                            fontFamily: 'RobotoMono',
                            fontSize: constraints.maxHeight / 2.7,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            letterSpacing: 2.0,
                            shadows: shadows,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FittedBox(
                                child: Text(
                                  '${hour.toUpperCase()}',
                                  style: textStyleHour,
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  '${mm == 0 ? 'O`CLOCK' : mm < 10 ? 'O`${minute.toUpperCase()}' : '${minute.toUpperCase()}'}',
                                  style: textStyleMinute,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class KissClockState extends ChangeNotifier {
  KissClockState.initState() {
    _perSecond();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<Map<String, Object>> days = [
    {'prefix': 'MON', 'weekday': DateTime.monday},
    {'prefix': 'TUE', 'weekday': DateTime.tuesday},
    {'prefix': 'WED', 'weekday': DateTime.wednesday},
    {'prefix': 'THU', 'weekday': DateTime.thursday},
    {'prefix': 'FRI', 'weekday': DateTime.friday},
    {'prefix': 'SAT', 'weekday': DateTime.saturday},
    {'prefix': 'SUN', 'weekday': DateTime.sunday},
  ];

  DateTime _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  set dateTime(DateTime dateTime) {
    if (_dateTime != dateTime) {
      _dateTime = dateTime;
      notifyListeners();
    }
  }

  Timer _timer;

  Timer get timer => _timer;

  set timer(Timer timer) {
    if (_timer != timer) {
      _timer = timer;
      notifyListeners();
    }
  }

  void _perSecond() {
    dateTime = DateTime.now();

    timer = Timer(
      const Duration(seconds: 1) - Duration(milliseconds: dateTime.millisecond),
      _perSecond,
    );
  }
}
