import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/utils/sizes.dart';
import 'package:geo_attendance_system/utils/text_styles.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    Key key,
    this.trimLines = 2,
  })  : assert(text != null),
        super(key: key);

  final String text;
  final int trimLines;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  @override
  Widget build(BuildContext context) {
    final colorClickableText = AppColors.green;
    final widgetColor = Colors.black;
    TextSpan link = TextSpan(
        text: _readMore ? "... read more" : " read less",
        style: TextStyles.defaultRegular.copyWith(
          fontSize: FontSizes.s13,
          color: colorClickableText,
        ),
        recognizer: TapGestureRecognizer()..onTap = _onTapLink);
    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final text = TextSpan(
            text: widget.text,
            style: TextStyles.defaultRegular.copyWith(
              fontSize: FontSizes.s13,
              height: 1.3,
            ));
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,
          //better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        var textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: _readMore ? widget.text.substring(0, endIndex) : widget.text,
            style: TextStyles.defaultRegular.copyWith(
              height: 1.3,
              color: widgetColor,
              fontSize: FontSizes.s13,
            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
              text: widget.text,
              style: TextStyles.defaultRegular.copyWith(
                height: 1.3,
                fontSize: FontSizes.s13,
              ));
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );
    return result;
  }
}