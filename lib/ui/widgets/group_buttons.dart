import 'package:educanet/ui/widgets/screen_util.dart';
import 'package:flutter/material.dart';

class GroupButtons extends StatelessWidget {
  final Function(String) onGroupButtonPressed;

  GroupButtons({required this.onGroupButtonPressed});

  @override
  Widget build(BuildContext context) {
    List<String> groups = [
      '1A', '1B', '1C', '1D', '1E', '1F',
      '2A', '2B', '2C', '2D', '2E', '2F',
      '3A', '3B', '3C', '3D', '3E', '3F', '3G'
    ];

    // Usamos la función getCrossAxisCount de ScreenUtil
    int crossAxisCount = ScreenUtil.getCrossAxisCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.0,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () => onGroupButtonPressed(groups[index]),
          child: Text(groups[index], style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.purple,
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
          ),
        );
      },
    );
  }
}
