import 'package:flutter/material.dart';

/// Título de [AppBar] que nunca se corta con "...": [AppBar] fuerza
/// softWrap:false + ellipsis por default en cualquier título, sin importar
/// el ancho de pantalla. Acá lo pisamos para que envuelva a una 2da línea
/// antes de truncar.
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      softWrap: true,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
