import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../res/app_colors.dart';
import '../../controllers/attendance_controller.dart';
import '../../res/strings.dart';
import '../../utils/sizes.dart';
import 'custom_text_widget.dart';
import 'utils.dart';

class TableComplexExample extends StatefulWidget {
  final AttendanceController attendanceController;
  final Function onFocusChange;

  TableComplexExample(
      this.attendanceController, String absents, this.onFocusChange);

  @override
  _TableComplexExampleState createState() =>
      _TableComplexExampleState(this.attendanceController, onFocusChange);
}

class _TableComplexExampleState extends State<TableComplexExample> {
  PageController _pageController;

  DateTime selectedDate;

  Function onFocusChanged;
  ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  Set<DateTime> _selectedDays = Set<DateTime>();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime _rangeStart;
  DateTime _rangeEnd;

  CalendarController event;

  _TableComplexExampleState(
      AttendanceController attendanceController, this.onFocusChanged);

  @override
  void initState() {
    super.initState();
    event = Get.put(CalendarController(widget.attendanceController));
    initMethods();
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    event.selectedEvents.value.dispose();
    super.dispose();
  }

  getSelectedDays() async {
    // await event.setEvents(null);
    _selectedDays =
        LinkedHashSet<DateTime>(equals: isSameDay, hashCode: event.getHashCode);
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> ev = [];
    try {
      event.kEvents.value.forEach((key, value) {
        if (key.day.compareTo(day.day) == 0 &&
            key.month.compareTo(day.month) == 0 &&
            key.year.compareTo(day.year) == 0) {
          ev.add(value.first);
        }
      });

      //  ev.add(Event("day,C", "", "", ""));

      return ev;
    } catch (ex) {
      print(ex);
      return [Event("day,C", day.toIso8601String(), "", "")];
    } finally {
      event.uiUpdate();
    }
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = event.daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_selectedDays.contains(selectedDay)) {
      _selectedDays.remove(selectedDay);
    } else {
      _selectedDays.add(selectedDay);
    }

    _focusedDay.value = focusedDay;
    _rangeStart = null;
    _rangeEnd = null;
    // _rangeSelectionMode = RangeSelectionMode.toggledOff;
    // });

    event.selectedEvents.value.value = _getEventsForDays(_selectedDays);
    //todo
    // Get.to(AttendanceMaster(
    //   selectedDate: DateFormat("dd-MMM yyyy").format(selectedDay),
    // ));
  }

  void _onMonthSelected() {}

  void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      //    event.selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      // event.selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      //  event.selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return _CalendarHeader(
              monthCallback: monthCallback,
              focusedDay: value,
              event: event,
              clearButtonVisible: canClearSelection,
              onTodayButtonTap: () {
                setState(() => _focusedDay.value = DateTime.now());
              },
              onClearButtonTap: () {
                setState(() {
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedDays.clear();
                  event.selectedEvents.value =
                      [].obs as ValueNotifier<List<Event>>;
                });
              },
              onLeftArrowTap: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            );
          },
        ),
        Obx(() {
          return event.kEvents.value.isNotEmpty
              ? TableCalendar(
                  calendarBuilders: CalendarBuilders(
                      singleMarkerBuilder: (context, data, Event e) {
                        return Container();
                      },
                      todayBuilder: null,
                      defaultBuilder:
                          (BuildContext context, DateTime a, DateTime b) {
                        try {
                          Event mEvent;
                          if (event.kEvents.value.entries.length > 0) {
                            mEvent = event.kEvents.value.entries
                                .firstWhere((element) =>
                                    (element.key.day == a.day) &&
                                    (element.key.month == a.month) &&
                                    (element.key.year == a.year))
                                .value
                                .first;
                          } else {
                            mEvent =
                                event.kEvents.value.entries.first.value.first;
                          }

                          print(mEvent.title);
                          if (mEvent.title.split(",")[1] == "A") {
                            return cellWidget(
                                Colors.red, Colors.white, a.day.toString(),
                                event: mEvent);
                          } else if (mEvent.title.split(",")[1] == "P") {
                            return cellWidget(
                                Colors.green, Colors.white, a.day.toString(),
                                event: mEvent);
                          } else if (mEvent.title.split(",")[1] == "H1") {
                            return cellWidget(
                                Colors.red, Colors.white, a.day.toString(),
                                isHalfDay: 1, event: mEvent);
                          } else {
                            return cellWidget(
                                Colors.green, Colors.white, a.day.toString(),
                                isHalfDay: 2, event: mEvent);
                          }
                        } catch (ex) {
                          return cellWidget(Colors.transparent, Colors.black,
                              a.day.toString(),
                              event: null);
                        }
                      }),
                  firstDay: event.kFirstDay.value,
                  lastDay: event.kLastDay.value,
                  focusedDay: _focusedDay.value,
                  headerVisible: false,
                  selectedDayPredicate: (day) => _selectedDays.contains(day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day),
                  rangeSelectionMode: _rangeSelectionMode,
                  holidayPredicate: (day) {
                    return false;
                  },
                  calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primary),
                      markersAlignment: Alignment.bottomLeft),
                  onRangeSelected: _onRangeSelected,
                  onCalendarCreated: (controller) =>
                      _pageController = controller,
                  onPageChanged: (focusedDay) {
                    _focusedDay.value = focusedDay;
                    event.setEvents(widget.attendanceController,
                        date:
                            "${focusedDay.year}-${focusedDay.month.toString().padLeft(2, "0")}");
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  })
              : event.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(
                      child: Container(
                      height: Get.height * 0.8,
                      child: Center(
                        child: CustomText(
                          text: Strings.noRecordsFound,
                          fontSize: FontSizes.s17,
                        ),
                      ),
                    ));
        }),
        Obx(
          () => ValueListenableBuilder<List<Event>>(
            valueListenable: event.selectedEvents.value,
            builder: (context, value, _) {
              return Container(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () =>
                            print('value index :: ${value[index].inTime}'),
                        title: Text('Check In-${value[index].inTime}'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  monthCallback(DateTime dateTime) {
    setState(() {
      _focusedDay.value = dateTime;
    });
    onFocusChanged(dateTime);

    // todo
    event.setEvents(widget.attendanceController,
        date:
            "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, "0")}");
    //  event.setEvents();
  }

  void initMethods() async {
    await getSelectedDays();
    _selectedDays.add(_focusedDay.value);
    // _selectedEvents = ValueNotifier(_getEventsForDays(List.generate(
    //     1,
    //     (i) => DateTime(
    //         event.kToday.year, event.kToday.month, event.kToday.day))));
    // _selectedEvents = ValueNotifier(_getEventsForDays(List.generate(
    //     30,
    //     (i) => DateTime(
    //         event.kToday.year, event.kToday.month, event.kToday.day + i))));
    setState(() {});
  }

  Widget cellWidget(Color activeColor, Color textColor, String day,
      {int isHalfDay = 0, Event event}) {
    return Center(
      child: Container(
          height: Get.height * 0.32,
          width: Get.width * 0.32,
          margin: EdgeInsets.all(Sizes.s1),
          decoration: (isHalfDay == 1 || isHalfDay == 2)
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.5,
                      0.5,
                    ],
                    colors: event.title.split(",")[1] == "H1"
                        ? [
                            Colors.green,
                            Colors.red,
                          ]
                        : [
                            Colors.red,
                            Colors.green,
                          ],
                  ),
                  border: Border.all(color: AppColors.black, width: 0.1))
              : BoxDecoration(
                  color: activeColor,
                  border: Border.all(color: AppColors.black, width: 0.1)),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Text(
                  day,
                  style: TextStyle(color: textColor, fontSize: FontSizes.s10),
                ),
              ),
              Container(
                child: Visibility(
                  visible: (event ?? Event("", "", "", "")).inTime.isNotEmpty,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10.0, left: 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                              "In: ${(event ?? Event("", "", "", "")).inTime}",
                          fontSize: FontSizes.s8,
                          color: textColor,
                        ),
                        CustomText(
                          text:
                              "OutTime: ${(event ?? Event("", "", "", "")).outTime}",
                          fontSize: FontSizes.s8,
                          color: textColor,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final Function monthCallback;
  final bool clearButtonVisible;
  final CalendarController event;

  const _CalendarHeader(
      {Key key,
      this.focusedDay,
      this.onLeftArrowTap,
      this.onRightArrowTap,
      this.onTodayButtonTap,
      this.onClearButtonTap,
      this.clearButtonVisible,
      this.monthCallback,
      this.event})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.MMM().format(focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: Sizes.s16),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    headerText,
                    style: TextStyle(
                        fontSize: FontSizes.s14, color: AppColors.black),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.0,
                    color: AppColors.black,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _onMonthSelected(context, this.monthCallback),
                ),
              ],
            ),
          ),
          //   Expanded(
          //     flex: 1,
          //     child: SizedBox(
          //     width: Sizes.s60,
          //     child: Text(
          //       yearText,
          //       style: TextStyle(fontSize: FontSizes.s13,color: AppColors.primary),
          //     ),
          // ),
          //   ),
          //   Expanded(
          //     flex: 1,
          //     child: IconButton(
          //     icon: Icon(Icons.keyboard_arrow_down, size: 20.0,color: AppColors.primary,),
          //     visualDensity: VisualDensity.compact,
          //     onPressed:()=>_onMonthSelected(context,this.monthCallback),
          // ),
          //   ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.calendar_today,
                size: 20.0,
                color: AppColors.greyText,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: onTodayButtonTap,
            ),
          ),
          if (clearButtonVisible)
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20.0,
                  color: AppColors.greyText,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: onClearButtonTap,
              ),
            ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.greyText,
              ),
              onPressed: onLeftArrowTap,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.greyText),
                onPressed: onRightArrowTap),
          ),
        ],
      ),
    );
  }

  _onMonthSelected(context, callback) {
    showMonthPicker(
      context: context,
      firstDate: DateTime(event.kToday.year, event.kToday.month - 6),
      lastDate: DateTime(event.kToday.year, event.kToday.month + 6),
      initialDate: focusedDay,
    ).then((date) {
      if (date != null) {
        callback(date);
      }
    });
  }
}
