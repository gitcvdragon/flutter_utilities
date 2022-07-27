part of utility_widgets;

const FloatingActionButtonThemeData _modifiedThemeData =
    FloatingActionButtonThemeData(
  sizeConstraints: BoxConstraints.tightFor(
    height: 48.0,
  ),
);

final Tween<double> _transitionTween = Tween<double>(
  begin: 1,
  end: 0,
);

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionButton tag>';
}

class ShrinkableFloatingActionButton extends StatefulWidget {
  final Widget label;
  final Widget icon;
  final ScrollController scrollController;
  final VoidCallback? onPressed;

  final bool shrinkOnForwardScroll;
  final bool shrinkOnBackwardScroll;

  final bool extendOnForwardScroll;
  final bool extendOnBackwardScroll;

  final Duration delayBeforeAutoExtend;

  final String? tooltip;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Object? heroTag;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final Color? splashColor;
  final double? highlightElevation;
  final double? disabledElevation;
  final MouseCursor? mouseCursor;
  final ShapeBorder? shape;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? iconLabelSpacing;
  final Duration shrinkDuration;
  final Duration extendDuration;
  final Curve curve;
  final bool mini;
  final bool? enableFeedback;

  const ShrinkableFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.scrollController,
    required this.onPressed,
    this.shrinkOnForwardScroll = false,
    this.shrinkOnBackwardScroll = false,
    this.extendOnForwardScroll = false,
    this.extendOnBackwardScroll = false,
    this.delayBeforeAutoExtend = const Duration(seconds: 1),
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.heroTag = const _DefaultHeroTag(),
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.splashColor,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.materialTapTargetSize,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.iconLabelSpacing,
    this.shrinkDuration = const Duration(milliseconds: 200),
    this.extendDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.mini = false,
    this.enableFeedback,
  })  : assert(
          (shrinkOnForwardScroll && !extendOnForwardScroll) ||
              (!shrinkOnForwardScroll),
        ),
        assert(
          (shrinkOnBackwardScroll && !extendOnBackwardScroll) ||
              !shrinkOnBackwardScroll,
        );

  @override
  ShrinkableFloatingActionButtonState createState() =>
      ShrinkableFloatingActionButtonState();
}

class ShrinkableFloatingActionButtonState
    extends State<ShrinkableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late final Stopwatch _stopwatch;
  Timer? y;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.shrinkDuration,
      reverseDuration: widget.extendDuration,
    );
    widget.scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _listener() {
    //printExceptRelease(widget.scrollController.position.userScrollDirection);
    switch (widget.scrollController.position.userScrollDirection) {
      case ScrollDirection.idle:
        _stopListener();
        break;

      case ScrollDirection.forward:
        if (widget.extendOnForwardScroll) {
          _stopListener();
        }
        if (widget.shrinkOnForwardScroll) {
          _resetListener();
        }
        break;

      case ScrollDirection.reverse:
        if (widget.extendOnBackwardScroll) {
          _stopListener();
        }
        if (widget.shrinkOnBackwardScroll) {
          _resetListener();
        }
        break;
    }
  }

  void _stopListener() {
    //printExceptRelease('No scroll activity. Stopping listener');
    extend();
    _stopwatch.stop();
    _stopwatch.reset();
  }

  void _resetListener() {
    //printExceptRelease('Resetting listener and listening again for another ${widget.delayBeforeExtend}');
    shrink();
    _stopwatch.start();
    _stopwatch.reset();
    y?.cancel();
    y = Timer(widget.delayBeforeAutoExtend, _ifNotScrollingCallback);
  }

  /// Calling this will only extend the FAB
  Future<void> extend() async {
    await _animationController.reverse();
  }

  /// Calling this will only shrink the FAB, will not extend it back
  Future<void> shrink() async {
    await _animationController.forward();
  }

  void _ifNotScrollingCallback() {
    if (_stopwatch.elapsed >= widget.delayBeforeAutoExtend) {
      _stopListener();
    }
  }

  double get _iconLabelSpacing =>
      widget.iconLabelSpacing ??
      Theme.of(context).floatingActionButtonTheme.extendedIconLabelSpacing ??
      8.0;

  double get _iconSize =>
      IconTheme.of(context).size ??
      DefaultTextStyle.of(context).style.fontSize!;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        floatingActionButtonTheme: _modifiedThemeData,
      ),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (48 - _iconSize) / 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon,
              SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: _transitionTween.animate(
                  CurveTween(curve: widget.curve).animate(_animationController),
                ),
                child: FadeTransition(
                  opacity: _transitionTween.animate(_animationController),
                  child: Padding(
                    padding: EdgeInsets.only(left: _iconLabelSpacing),
                    child: Center(
                      child: widget.label,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        tooltip: widget.tooltip,
        foregroundColor: widget.foregroundColor,
        backgroundColor: widget.backgroundColor,
        focusColor: widget.focusColor,
        hoverColor: widget.hoverColor,
        heroTag: widget.heroTag,
        elevation: widget.elevation,
        focusElevation: widget.focusElevation,
        hoverElevation: widget.hoverElevation,
        splashColor: widget.splashColor,
        highlightElevation: widget.highlightElevation,
        disabledElevation: widget.disabledElevation,
        mouseCursor: widget.mouseCursor,
        shape: widget.shape ?? const StadiumBorder(),
        materialTapTargetSize: widget.materialTapTargetSize,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mini: widget.mini,
        enableFeedback: widget.enableFeedback,
      ),
    );
  }
}
