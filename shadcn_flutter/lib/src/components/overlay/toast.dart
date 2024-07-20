import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

typedef ToastBuilder = Widget Function(
    BuildContext context, ToastOverlay overlay);

ToastOverlay showToast({
  required BuildContext context,
  required ToastBuilder builder,
  ToastLocation location = ToastLocation.bottomRight,
  bool dismissible = true,
  Curve curve = Curves.easeOutCubic,
  Duration entryDuration = const Duration(milliseconds: 500),
  VoidCallback? onClosed,
  Duration showDuration = const Duration(seconds: 5),
}) {
  final layer = Data.maybeOf<_ToastLayerState>(context);
  assert(layer != null, 'No ToastLayer found in context');
  final themes = InheritedTheme.capture(from: context, to: layer!.context);
  final data = Data.capture(from: context, to: layer.context);
  final entry = ToastEntry(
    builder: builder,
    location: location,
    dismissible: dismissible,
    curve: curve,
    duration: entryDuration,
    themes: themes,
    data: data,
    onClosed: onClosed,
  );
  var attachedEntry = layer.addEntry(entry);
  Timer(showDuration, () {
    attachedEntry.close();
  });
  return attachedEntry;
}

enum ToastLocation {
  topLeft(
    childrenAlignment: Alignment.bottomCenter,
    alignment: Alignment.topLeft,
  ),
  topCenter(
    childrenAlignment: Alignment.bottomCenter,
    alignment: Alignment.topCenter,
  ),
  topRight(
    childrenAlignment: Alignment.bottomCenter,
    alignment: Alignment.topRight,
  ),
  bottomLeft(
    childrenAlignment: Alignment.topCenter,
    alignment: Alignment.bottomLeft,
  ),
  bottomCenter(
    childrenAlignment: Alignment.topCenter,
    alignment: Alignment.bottomCenter,
  ),
  bottomRight(
    childrenAlignment: Alignment.topCenter,
    alignment: Alignment.bottomRight,
  );

  final Alignment alignment;
  final Alignment childrenAlignment;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const ToastLocation({
    required this.alignment,
    required this.childrenAlignment,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

enum ExpandMode {
  alwaysExpanded,
  expandOnHover,
  expandOnTap,
  disabled,
}

class ToastLayer extends StatefulWidget {
  final Widget child;
  final int maxStackedEntries;
  final EdgeInsets padding;
  final ExpandMode expandMode;
  final Offset collapsedOffset;
  final double collapsedScale;
  final Curve expandingCurve;
  final Duration expandingDuration;
  final double collapsedOpacity;
  final double entryOpacity;
  final double spacing;
  final BoxConstraints toastConstraints;

  const ToastLayer({
    super.key,
    required this.child,
    this.maxStackedEntries = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.expandMode = ExpandMode.expandOnHover,
    this.collapsedOffset = const Offset(0, 12),
    this.collapsedScale = 0.9,
    this.expandingCurve = Curves.easeOutCubic,
    this.expandingDuration = const Duration(milliseconds: 500),
    this.collapsedOpacity = 1,
    this.entryOpacity = 0.0,
    this.spacing = 8,
    this.toastConstraints = const BoxConstraints.tightFor(width: 320),
  });

  @override
  State<ToastLayer> createState() => _ToastLayerState();
}

class _ToastLocationData {
  final List<_AttachedToastEntry> entries = [];
  bool _expanding = false;
  int _hoverCount = 0;
}

class _ToastLayerState extends State<ToastLayer> {
  final Map<ToastLocation, _ToastLocationData> entries = {
    ToastLocation.topLeft: _ToastLocationData(),
    ToastLocation.topCenter: _ToastLocationData(),
    ToastLocation.topRight: _ToastLocationData(),
    ToastLocation.bottomLeft: _ToastLocationData(),
    ToastLocation.bottomCenter: _ToastLocationData(),
    ToastLocation.bottomRight: _ToastLocationData(),
  };

  void _triggerEntryClosing() {
    setState(() {
      // this will rebuild the toast entries
    });
  }

  ToastOverlay addEntry(ToastEntry entry) {
    var attachedToastEntry = _AttachedToastEntry(entry, this);
    setState(() {
      var entries = this.entries[entry.location];
      entries!.entries.add(attachedToastEntry);
    });
    return attachedToastEntry;
  }

  void removeEntry(ToastEntry entry) {
    _AttachedToastEntry? last = entries[entry.location]!
        .entries
        .where((e) => e.entry == entry)
        .lastOrNull;
    if (last != null) {
      setState(() {
        entries[entry.location]!.entries.remove(last);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int reservedEntries = widget.maxStackedEntries;
    List<Widget> children = [
      widget.child,
    ];
    for (var locationEntry in entries.entries) {
      var location = locationEntry.key;
      var entries = locationEntry.value.entries;
      var expanding = locationEntry.value._expanding;
      int startVisible =
          (entries.length - (widget.maxStackedEntries + reservedEntries)).max(
              0); // reserve some invisible toast as for the ghost entry depending animation speed
      Alignment entryAlignment = location.childrenAlignment * -1;
      List<Widget> positionedChildren = [];
      int toastIndex = 0;
      for (var i = entries.length - 1; i >= startVisible; i--) {
        var entry = entries[i];
        positionedChildren.insert(
          0,
          OverlaidToastEntry(
            key: entry.key,
            entry: entry.entry,
            expanded:
                expanding || widget.expandMode == ExpandMode.alwaysExpanded,
            visible: toastIndex < widget.maxStackedEntries,
            dismissible: entry.entry.dismissible,
            previousAlignment: location.childrenAlignment,
            curve: entry.entry.curve,
            duration: entry.entry.duration,
            themes: entry.entry.themes,
            data: entry.entry.data,
            closing: entry._isClosing,
            collapsedOffset: widget.collapsedOffset,
            collapsedScale: widget.collapsedScale,
            expandingCurve: widget.expandingCurve,
            expandingDuration: widget.expandingDuration,
            collapsedOpacity: widget.collapsedOpacity,
            entryOpacity: widget.entryOpacity,
            onClosed: () {
              removeEntry(entry.entry);
              entry.entry.onClosed?.call();
            },
            entryOffset: Offset(
              widget.padding.left * entryAlignment.x.clamp(0, 1) +
                  widget.padding.right * entryAlignment.x.clamp(-1, 0),
              widget.padding.top * entryAlignment.y.clamp(0, 1) +
                  widget.padding.bottom * entryAlignment.y.clamp(-1, 0),
            ),
            entryAlignment: entryAlignment,
            spacing: widget.spacing,
            index: toastIndex,
            actualIndex: entries.length - i - 1,
            child: ConstrainedBox(
              constraints: widget.toastConstraints,
              child: entry.entry.builder(context, entry),
            ),
          ),
        );
        if (!entry._isClosing.value) {
          toastIndex++;
        }
      }
      if (positionedChildren.isEmpty) {
        continue;
      }
      children.add(
        Positioned.fill(
          child: Padding(
            padding: widget.padding,
            child: Align(
              alignment: location.alignment,
              child: MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                onEnter: (event) {
                  locationEntry.value._hoverCount++;
                  if (widget.expandMode == ExpandMode.expandOnHover) {
                    setState(() {
                      locationEntry.value._expanding = true;
                    });
                  }
                },
                onExit: (event) {
                  int currentCount = ++locationEntry.value._hoverCount;
                  Future.delayed(Duration(milliseconds: 300), () {
                    if (currentCount == locationEntry.value._hoverCount) {
                      setState(() {
                        locationEntry.value._expanding = false;
                      });
                    }
                  });
                },
                child: ConstrainedBox(
                  constraints: widget.toastConstraints,
                  child: Stack(
                    alignment: location.alignment,
                    clipBehavior: Clip.none,
                    fit: StackFit.passthrough,
                    children: positionedChildren,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Data(
      data: this,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: children,
      ),
    );
  }
}

abstract class ToastOverlay {
  bool get isShowing;
  void close();
}

class _AttachedToastEntry implements ToastOverlay {
  final GlobalKey<_OverlaidToastEntryState> key = GlobalKey();
  final ToastEntry entry;

  _ToastLayerState? _attached;

  @override
  bool get isShowing => _attached != null;

  ValueNotifier<bool> _isClosing = ValueNotifier(false);

  _AttachedToastEntry(this.entry, this._attached);

  @override
  void close() {
    if (_attached == null) {
      return;
    }
    _isClosing.value = true;
    _attached!._triggerEntryClosing();
    _attached = null;
  }
}

class ToastEntry {
  final ToastBuilder builder;
  final ToastLocation location;
  final bool dismissible;
  final Curve curve;
  final Duration duration;
  final CapturedThemes themes;
  final CapturedData data;
  final VoidCallback? onClosed;

  ToastEntry({
    required this.builder,
    required this.location,
    this.dismissible = true,
    this.curve = Curves.easeInOut,
    this.duration = kDefaultDuration,
    required this.themes,
    required this.data,
    this.onClosed,
  });
}

class OverlaidToastEntry extends StatefulWidget {
  final ToastEntry entry;
  final bool expanded;
  final bool visible;
  final bool dismissible;
  final Alignment previousAlignment;
  final Curve curve;
  final Duration duration;
  final CapturedThemes themes;
  final CapturedData data;
  final ValueListenable<bool> closing;
  final VoidCallback onClosed;
  final Offset collapsedOffset;
  final double collapsedScale;
  final Curve expandingCurve;
  final Duration expandingDuration;
  final double collapsedOpacity;
  final double entryOpacity;
  final Widget child;
  final Offset entryOffset;
  final Alignment entryAlignment;
  final double spacing;
  final int index;
  final int actualIndex;

  const OverlaidToastEntry({
    super.key,
    required this.entry,
    required this.expanded,
    this.visible = true,
    this.dismissible = true,
    this.previousAlignment = Alignment.center,
    this.curve = Curves.easeInOut,
    this.duration = kDefaultDuration,
    required this.themes,
    required this.data,
    required this.closing,
    required this.onClosed,
    required this.collapsedOffset,
    required this.collapsedScale,
    this.expandingCurve = Curves.easeInOut,
    this.expandingDuration = kDefaultDuration,
    this.collapsedOpacity = 0.8,
    this.entryOpacity = 0.0,
    required this.entryOffset,
    required this.child,
    required this.entryAlignment,
    required this.spacing,
    required this.index,
    required this.actualIndex,
  });

  @override
  State<OverlaidToastEntry> createState() => _OverlaidToastEntryState();
}

class _OverlaidToastEntryState extends State<OverlaidToastEntry> {
  bool _dismissing = false;
  double _dismissProgress = 0;
  late int index;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.themes.wrap(
      widget.data.wrap(
        AnimatedBuilder(
            animation: widget.closing,
            builder: (context, child) {
              return AnimatedValueBuilder(
                  value: widget.index.toDouble(),
                  curve: widget.curve,
                  duration: widget.duration,
                  builder: (context, indexProgress, child) {
                    return AnimatedValueBuilder(
                      initialValue: widget.index > 0 ? 1.0 : 0.0,
                      value: widget.closing.value && !_dismissing ? 0.0 : 1.0,
                      curve: widget.curve,
                      duration: widget.duration,
                      onEnd: (value) {
                        if (value == 0.0 && widget.closing.value) {
                          widget.onClosed();
                        }
                      },
                      builder: (context, showingProgress, child) {
                        return AnimatedValueBuilder(
                            value: widget.visible ? 1.0 : 0.0,
                            curve: widget.curve,
                            duration: widget.duration,
                            builder: (context, visibleProgress, child) {
                              return AnimatedValueBuilder(
                                  value: widget.expanded ? 1.0 : 0.0,
                                  curve: widget.expandingCurve,
                                  duration: widget.expandingDuration,
                                  builder: (context, expandProgress, child) {
                                    return buildToast(
                                        expandProgress,
                                        showingProgress,
                                        visibleProgress,
                                        indexProgress);
                                  });
                            });
                      },
                    );
                  });
            }),
      ),
    );
  }

  Widget buildToast(double expandProgress, double showingProgress,
      double visibleProgress, double indexProgress) {
    double nonCollapsingProgress = (1.0 - expandProgress) * showingProgress;
    var offset = widget.entryOffset * (1.0 - showingProgress);

    // when its behind another toast, shift it up based on index
    offset += Offset(
          (widget.collapsedOffset.dx * widget.previousAlignment.x) *
              nonCollapsingProgress,
          (widget.collapsedOffset.dy * widget.previousAlignment.y) *
              nonCollapsingProgress,
        ) *
        indexProgress;

    // and then add the spacing when its in expanded mode
    offset += Offset(
          (widget.spacing * widget.previousAlignment.x) * expandProgress,
          (widget.spacing * widget.previousAlignment.y) * expandProgress,
        ) *
        indexProgress;

    var fractionalOffset = Offset(
      widget.entryAlignment.x * (1.0 - showingProgress),
      widget.entryAlignment.y * (1.0 - showingProgress),
    );

    // when its behind another toast AND is expanded, shift it up based on index and the size of self
    fractionalOffset += Offset(
          expandProgress * widget.previousAlignment.x,
          expandProgress * widget.previousAlignment.y,
        ) *
        indexProgress;

    var opacity = tweenValue(
      widget.entryOpacity,
      1.0,
      showingProgress * visibleProgress,
    );

    // fade out the toast behind
    opacity *=
        pow(widget.collapsedOpacity, indexProgress * nonCollapsingProgress);

    double scale =
        1.0 * pow(widget.collapsedScale, indexProgress * (1 - expandProgress));

    return Align(
      alignment: widget.entryAlignment,
      child: Transform.translate(
        offset: offset,
        child: FractionalTranslation(
          translation: fractionalOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
