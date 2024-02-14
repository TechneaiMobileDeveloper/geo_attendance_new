import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../utils/sizes.dart';
import 'custom_text_widget.dart';

class CustomDropDown extends StatelessWidget {
  final List<DropDownModal> items;
  final DropDownModal dropdownvalue;
  final Function(DropDownModal) onChange;
  final bool isUnderline;
  final double width;
  final bool isBoarder;
  final double borderWidth;
  final double boarderRadius;
  final Color textColor, iconColor;

  final Color boarderColor;

  const CustomDropDown({
    Key key,
    this.items,
    this.dropdownvalue,
    this.onChange,
    this.isUnderline,
    this.isBoarder,
    this.borderWidth = 1.0,
    this.boarderRadius = 15,
    this.textColor = AppColors.primary,
    this.iconColor = AppColors.primary,
    this.boarderColor = AppColors.primary,
    this.width = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      width: width,
      decoration: BoxDecoration(
          border: Border.all(color: boarderColor, width: borderWidth),
          borderRadius: BorderRadius.all(Radius.circular(boarderRadius))),
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10.0, right: 10.0, top: 0, bottom: 0),
          child: DropdownButton(
            isExpanded: true,
            underline: const SizedBox(
              height: 0,
            ),
            // Initial Value
            value: dropdownvalue,

            // Down Arrow Icon
            icon: Icon(Icons.keyboard_arrow_down, color: iconColor),

            // Array list of items
            items: items.map((DropDownModal items) {
              return DropdownMenuItem(
                  value: items,
                  child: CustomText(
                      text: items.name,
                      fontSize: FontSizes.s14,
                      fontWight: FontWeight.normal));
            }).toList(),
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (DropDownModal newValue) => onChange(newValue),
          ),
        ),
      ),
    );
  }
}

class DropDownModal {
  String name;
  int index;

  DropDownModal({this.name, this.index});

  @override
  String toString() {
    return ("$name $index");
  }
}
