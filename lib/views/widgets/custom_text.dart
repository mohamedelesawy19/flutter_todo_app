import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.title,
    this.size = 17,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w400,
    this.decoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : super(key: key);

  final String title;
  final double size;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: fontWeight,
          decoration: decoration),
    );
  }
}
