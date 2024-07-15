import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'docs/components/carousel_example.dart';

class ResizableTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(100),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: ResizablePanel(
        direction: Axis.horizontal,
        children: [
          ResizablePane(
            child: NumberedContainer(
              index: 2,
              height: 200,
            ),
            initialSize: 120,
            minSize: 100,
            maxSize: 200,
            collapsedSize: 80,
            initialCollapsed: true,
          ),
          ResizablePane(
            child: NumberedContainer(
              index: 0,
              height: 200,
            ),
            initialSize: 80,
            maxSize: 160,
            minSize: 20,
            collapsedSize: 5,
          ),
          ResizablePane.flex(
            child: NumberedContainer(
              index: 1,
              height: 200,
            ),
            flex: 2,
            // maxSize: 400,
            minSize: 20,
          ),
          ResizablePane.flex(
            child: NumberedContainer(
              index: 3,
              height: 200,
            ),
            flex: 1,
            // maxSize: 100,
            minSize: 20,
          ),
          ResizablePane(
            child: NumberedContainer(
              index: 4,
              height: 200,
            ),
            initialSize: 80,
            maxSize: 250,
            minSize: 20,
            collapsedSize: 5,
          ),
        ],
      ),
    );
  }
}
