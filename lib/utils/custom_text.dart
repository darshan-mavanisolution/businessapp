import 'package:flutter/cupertino.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.title, {
    super.key,
    this.fontSize,
    this.height,
    this.textColor,
    this.textAlign,
    this.fontWeight,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
  });

  final String title;
  final double? fontSize;
  final double? height;
  final double? letterSpacing;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: commonTextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        textColor: textColor,
        height: height,
        overflow: overflow,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

TextStyle commonTextStyle({Color? textColor, double? fontSize, double? letterSpacing, FontWeight? fontWeight, double? height, TextOverflow? overflow}) {
  return TextStyle(
    height: height,
    color: textColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
    overflow: overflow,
    letterSpacing: letterSpacing,
    fontFamily: "Inter",
  );
}
