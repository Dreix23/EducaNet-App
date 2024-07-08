import 'package:flutter/material.dart';

class EntranceExitControlBar extends StatelessWidget {
  final bool isEntrance;
  final Function(bool) onSelectionChanged;

  const EntranceExitControlBar({
    Key? key,
    required this.isEntrance,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: isEntrance ? Colors.lightGreenAccent[100] : Colors.pinkAccent[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () => onSelectionChanged(true),
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory, // Deshabilita el splash
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Text(
                'Entrada',
                style: TextStyle(
                  color: isEntrance ? Colors.black : Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => onSelectionChanged(false),
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory, // Deshabilita el splash
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Text(
                'Salida',
                style: TextStyle(
                  color: !isEntrance ? Colors.black : Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
