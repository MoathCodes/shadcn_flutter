import 'package:example/pages/docs/components/carousel/carousel_example_1.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../widget_usage_example.dart';
import '../component_page.dart';
import 'carousel/carousel_example_2.dart';

class CarouselExample extends StatelessWidget {
  const CarouselExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      name: 'carousel',
      description:
          'A carousel slider widget, support infinite scroll and custom child widget.',
      displayName: 'Carousel',
      children: [
        WidgetUsageExample(
          title: 'Horizontal Carousel Example',
          path: 'lib/pages/docs/components/carousel/carousel_example_1.dart',
          child: CarouselExample1(),
        ),
        WidgetUsageExample(
          title: 'Vertical Carousel Example',
          path: 'lib/pages/docs/components/carousel/carousel_example_2.dart',
          child: CarouselExample2(),
        ),
      ],
    );
  }
}

class NumberedContainer extends StatelessWidget {
  final int index;
  final double? width;
  final double? height;
  final bool fill;
  const NumberedContainer({
    Key? key,
    required this.index,
    this.width,
    this.height,
    this.fill = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill
            ? Colors.primaries[
                (Colors.primaries.length - 1 - index) % Colors.primaries.length]
            : null,
        borderRadius: theme.borderRadiusMd,
      ),
      child: Center(
        child: Text(
          index.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
