import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> chipList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.chipList, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List<String>.empty(growable: true);

  _buildChoiceList() {
    List<Widget> choices = List<Widget>.empty(growable: true);
    widget.chipList.forEach((item) {
      choices.add(Container(
        padding: EdgeInsets.all(Sizes.s7),
        child: ChoiceChip(
          elevation: Sizes.s0,
          selectedColor: AppColors.green,
          backgroundColor: AppColors.white,
          label: Text(
            item,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selectedChoices.contains(item)
                  ? AppColors.white
                  : AppColors.fontGray,
              fontFamily: FontFamily.regular,
              fontSize: FontSizes.s13,
            ),
          ),
          labelPadding:
              EdgeInsets.symmetric(horizontal: Sizes.s16, vertical: Sizes.s3),
          shape: RoundedRectangleBorder(
              side: BorderSide(width: Sizes.s1, color: AppColors.greyLight),
              borderRadius: BorderRadius.all(Radius.circular(Sizes.s20))),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
