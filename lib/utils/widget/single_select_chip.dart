import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';

class SingleSelectChip extends StatefulWidget {
  final List<String> chipList;
  final Function(String) onSelectionChanged;

  SingleSelectChip(this.chipList, {this.onSelectionChanged});

  @override
  State<StatefulWidget> createState() => _SingleSelectChipState();
}

class _SingleSelectChipState extends State<SingleSelectChip> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
        widget.chipList.length,
        (index) {
          return Container(
            padding: EdgeInsets.all(Sizes.s7),
            child: ChoiceChip(
              elevation: Sizes.s0,
              selectedColor: AppColors.green,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: Sizes.s1, color: AppColors.greyLight),
                  borderRadius: BorderRadius.all(Radius.circular(Sizes.s20))),
              selected: _selectedIndex == index,
              labelPadding: EdgeInsets.symmetric(
                  horizontal: Sizes.s13, vertical: Sizes.s3),
              label: Text(
                widget.chipList[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: FontFamily.regular,
                    fontSize: FontSizes.s13,
                    color: _selectedIndex == index
                        ? AppColors.white
                        : AppColors.fontGray),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedIndex = index;
                    widget.onSelectionChanged(widget.chipList[index]);
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
