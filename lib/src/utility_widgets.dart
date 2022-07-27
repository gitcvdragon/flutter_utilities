library utility_widgets;

// Dart imports:
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

// Package imports:
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// Project imports:
import 'package:flutter_utilities/flutter_utilities.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

export 'package:connectivity_plus/connectivity_plus.dart'
    show ConnectivityResult;

part 'package:flutter_utilities/src/parts/connectivity_notification.dart';
part 'package:flutter_utilities/src/parts/loading_button.dart';
part 'package:flutter_utilities/src/parts/shrinkable_floating_action_button.dart';

class Null extends StatelessWidget {
  const Null();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 0,
      width: 0,
    );
  }
}

const Widget empty = Null();

/*class PreExe extends StatelessWidget {
  final void Function()? preExecute;
  final Widget? child;
  const PreExe({
    Key? key,
    required this.preExecute,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, preExecute);
    return child ?? const Null();
  }
}*/

class PostExe extends StatefulWidget {
  final void Function()? postExecute;
  final Widget? child;
  const PostExe({
    Key? key,
    required this.postExecute,
    required this.child,
  }) : super(key: key);

  @override
  State<PostExe> createState() => _PostExeState();
}

class _PostExeState extends State<PostExe> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      widget.postExecute?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const Null();
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String text;
  final Widget? child;
  final List<Widget>? actions;
  final MainAxisAlignment actionsAlignment;
  final EdgeInsetsGeometry padding;
  const ConfirmationDialog({
    Key? key,
    this.text = 'Are you sure?',
    this.child,
    this.actions,
    this.actionsAlignment = MainAxisAlignment.end,
    this.padding = const EdgeInsets.all(30),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(
              height: 20,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: (child != null)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        child!,
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  : const Null(),
            ),
            Row(
              mainAxisAlignment: actionsAlignment,
              children: actions ??
                  [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    TextButton(
                      child: const Text('Confirm'),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  final String url;
  final bool openFullScreen;
  final Duration fadeInDuration;
  const ImageView({
    Key? key,
    required this.url,
    this.openFullScreen = false,
    this.fadeInDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: url,
      child: GestureDetector(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => FullScreenImageView(
              imageUrl: url,
              heroTag: url,
            ),
          );
        },
        child: CachedNetworkImage(
          imageUrl: url,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey,
            child: const Center(
              child: Text('Snap! Image failed to load!'),
            ),
          ),
          progressIndicatorBuilder: (context, url, progress) => SizedBox(
            height: 30,
            width: 30,
            child: AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                value: progress.progress,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatefulWidget {
  final Object? heroTag;
  final Uint8List? imageData;
  final double blurValue;
  final String? imageUrl;
  const FullScreenImageView({
    this.imageUrl,
    this.imageData,
    this.heroTag,
    this.blurValue = 50,
  });

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late final TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;
  final double minScale = 0.8;
  final double maxScale = 2.0;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
    return;
  }

  Future<void> _handleDoubleTap() async {
    final position = _doubleTapDetails!.localPosition;
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.imageData != null || widget.imageUrl != null);
    if (widget.imageData == null && widget.imageUrl == null) {
      return const Null();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurValue,
          sigmaY: widget.blurValue,
        ),
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  constrained: false,
                  minScale: minScale,
                  maxScale: maxScale,
                  transformationController: _transformationController,
                  child: Hero(
                    tag: widget.heroTag ??
                        widget.imageUrl ??
                        widget.imageData ??
                        UniqueKey(),
                    child: (widget.imageUrl != null)
                        ? CachedNetworkImage(
                            imageUrl: widget.imageUrl!,
                            errorWidget: (context, url, error) => const Center(
                              child: Text('Snap! Failed to load!'),
                            ),
                            fit: BoxFit.contain,
                            progressIndicatorBuilder:
                                (context, url, progress) => SizedBox(
                              height: 30,
                              width: 30,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                            ),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          )
                        : (widget.imageData != null)
                            ? Image.memory(
                                widget.imageData!,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.contain,
                              )
                            : const Null(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                /*color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,*/
                backgroundColor: Colors.black.withOpacity(0.1),
                tooltip: 'Close',
                child: const Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Selectable extends StatelessWidget {
  final bool isSelected;
  final Color selectedColor;
  final Widget child;
  final double selectedBorderWidth;
  final BorderStyle selectedBorderStyle;
  final void Function()? onSelect;
  const Selectable({
    Key? key,
    this.isSelected = false,
    required this.child,
    this.selectedColor = Colors.white,
    this.selectedBorderWidth = 3,
    this.selectedBorderStyle = BorderStyle.solid,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedColor,
                  width: selectedBorderWidth,
                  style: selectedBorderStyle,
                ),
              ),
              child: child,
            )
          : child,
    );
  }
}

/*
@Deprecated(
  "Use ShrinkableFloatingActionButton instead, which is new, with better animations and more customizable",
)
class AdaptiveFloatingActionButton extends StatefulWidget {
  final Widget label;
  final Widget icon;
  final ScrollController scrollController;
  final VoidCallback? onPressed;

  final bool shrinkOnForwardScroll;
  final bool shrinkOnBackwardScroll;

  final bool extendOnForwardScroll;
  final bool extendOnBackwardScroll;

  final Duration delayBeforeExtend;

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

  @Deprecated(
    "Use ShrinkableFloatingActionButton instead, which is new, with better animations and more customizable",
  )
  const AdaptiveFloatingActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.scrollController,
    required this.onPressed,
    this.shrinkOnForwardScroll = false,
    this.shrinkOnBackwardScroll = false,
    this.extendOnForwardScroll = false,
    this.extendOnBackwardScroll = false,
    this.delayBeforeExtend = const Duration(seconds: 1),
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.heroTag,
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
  })  : assert(
          (shrinkOnForwardScroll && !extendOnForwardScroll) ||
              (!shrinkOnForwardScroll),
        ),
        assert(
          (shrinkOnBackwardScroll && !extendOnBackwardScroll) ||
              !shrinkOnBackwardScroll,
        ),
        super(key: key);

  @override
  _AdaptiveFloatingActionButtonState createState() =>
      _AdaptiveFloatingActionButtonState();
}

class _AdaptiveFloatingActionButtonState
    extends State<AdaptiveFloatingActionButton> {
  final ValueNotifier<bool> _isScrolling = ValueNotifier<bool>(false);
  final Stopwatch _stopwatch = Stopwatch();
  Timer? y;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    _isScrolling.dispose();
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
    _isScrolling.value = false;
    _stopwatch.stop();
    _stopwatch.reset();
  }

  void _resetListener() {
    //printExceptRelease('Resetting listener and listening again for another ${widget.delayBeforeExtend}');
    _stopwatch.start();
    _isScrolling.value = true;
    _stopwatch.reset();
    y?.cancel();
    y = Timer(widget.delayBeforeExtend, _isNotScrollingCallback);
  }

  void _isNotScrollingCallback() {
    if (_stopwatch.elapsed >= widget.delayBeforeExtend) {
      _stopListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isScrolling,
      builder: (context, isScrolling, c) => FloatingActionButton.extended(
        isExtended: !isScrolling,
        onPressed: widget.onPressed,
        label: widget.label,
        icon: widget.icon,
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
        shape: widget.shape,
        materialTapTargetSize: widget.materialTapTargetSize,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
      ),
    );
  }
}
*/

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  //final Brightness? brightness;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  //final TextTheme? textTheme;
  final bool primary;
  final bool? centerTitle;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double? toolbarHeight;
  final double? leadingWidth;
  //final bool? backwardsCompatibility;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Widget searchField;
  final void Function(String) onSearchFieldChanged;

  final Widget searchIcon;
  final String searchTooltip;
  final Widget closeIcon;
  final String closeTooltip;

  final VoidCallback? onClose;

  final Duration animationDuration;

  SearchAppBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    //this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    //this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    //this.backwardsCompatibility,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.searchField = _textField,
    this.onSearchFieldChanged = _onTextFieldChanged,
    this.searchIcon = const Icon(Icons.search),
    this.searchTooltip = 'Search',
    this.closeIcon = const Icon(Icons.cancel),
    this.closeTooltip = 'Close',
    this.animationDuration = const Duration(milliseconds: 300),
    this.onClose,
  }) : super(key: key);

  static void _onTextFieldChanged(String x) {}

  static const Widget _textField = TextField(
    cursorColor: Colors.white,
    decoration: InputDecoration(border: InputBorder.none, hintText: 'Search'),
    style: TextStyle(color: Colors.white),
    autofocus: true,
    onChanged: _onTextFieldChanged,
  );

  @override
  final Size preferredSize = AppBar().preferredSize;

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: AnimatedSwitcher(
        duration: widget.animationDuration,
        child: _isSearchEnabled
            ? widget.searchField
            : Row(
                mainAxisAlignment: (widget.centerTitle ?? false)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  widget.title ??
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                ],
              ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: widget.animationDuration,
          child: _isSearchEnabled
              ? IconButton(
                  tooltip: widget.closeTooltip,
                  onPressed: () {
                    setState(() {
                      _isSearchEnabled = false;
                      widget.onClose?.call();
                    });
                  },
                  icon: widget.closeIcon,
                )
              : IconButton(
                  tooltip: widget.searchTooltip,
                  onPressed: () {
                    setState(() {
                      _isSearchEnabled = true;
                    });
                  },
                  icon: widget.searchIcon,
                ),
        ),
        ...widget.actions ?? [],
      ],
      key: widget.key,
      leading: _isSearchEnabled
          ? const SizedBox(
              height: 0,
              width: 0,
            )
          : widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      flexibleSpace: widget.flexibleSpace,
      bottom: widget.bottom,
      elevation: widget.elevation,
      shadowColor: widget.shadowColor,
      shape: widget.shape,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      //brightness: widget.brightness,
      iconTheme: widget.iconTheme,
      actionsIconTheme: widget.actionsIconTheme,
      //textTheme: widget.textTheme,
      primary: widget.primary,
      excludeHeaderSemantics: widget.excludeHeaderSemantics,
      titleSpacing: widget.titleSpacing,
      toolbarOpacity: widget.toolbarOpacity,
      bottomOpacity: widget.bottomOpacity,
      toolbarHeight: widget.toolbarHeight,
      leadingWidth: widget.leadingWidth,
      //backwardsCompatibility: widget.backwardsCompatibility,
      toolbarTextStyle: widget.toolbarTextStyle,
      titleTextStyle: widget.titleTextStyle,
      systemOverlayStyle: widget.systemOverlayStyle,
    );
  }
}

class AnimatedCountInt extends StatelessWidget {
  final int begin;
  final int end;
  final Widget Function(BuildContext, int, Widget?) builder;
  final Duration duration;
  final Curve curve;
  const AnimatedCountInt({
    Key? key,
    required this.begin,
    required this.end,
    required this.builder,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: begin, end: end),
      duration: duration,
      builder: builder,
    );
  }
}

class AnimatedCountDouble extends StatelessWidget {
  final double begin;
  final double end;
  final Widget Function(BuildContext, double, Widget?) builder;
  final Duration duration;
  final Curve curve;
  const AnimatedCountDouble({
    Key? key,
    required this.begin,
    required this.end,
    required this.builder,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      builder: builder,
    );
  }
}

class SpinIt extends StatefulWidget {
  final Widget child;
  final Duration singleSpinDuration;
  final Curve curve;
  const SpinIt({
    Key? key,
    required this.child,
    this.singleSpinDuration = const Duration(seconds: 1),
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  _SpinItState createState() => _SpinItState();
}

class _SpinItState extends State<SpinIt> with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.singleSpinDuration,
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}

class ConstAnimatedListView extends StatefulWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(Widget listItem, Animation<double> animation)
      insertAnimation;
  final Widget Function(Widget listItem, Animation<double> animation)
      removeAnimation;
  final int initialItemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  const ConstAnimatedListView({
    Key? key,
    required this.itemBuilder,
    this.insertAnimation = _insertAnimation,
    this.removeAnimation = _removeAnimation,
    this.initialItemCount = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  static Widget _insertAnimation(Widget child, Animation<double> animation) =>
      SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );

  static Widget _removeAnimation(Widget child, Animation<double> animation) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );

  @override
  ConstAnimatedListViewState createState() => ConstAnimatedListViewState();
}

class ConstAnimatedListViewState extends State<ConstAnimatedListView> {
  late int _itemCount;

  int get itemCount => _itemCount;

  Future<void> insertItem(
    final int index, {
    final Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (index < 0) {
      return;
    }
    listKey.currentState!.insertItem(index, duration: duration);
    ++_itemCount;
    await Future.delayed(duration);
  }

  Future<void> removeItem(
    final int index, {
    final Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (index < 0) {
      return;
    }
    listKey.currentState!.removeItem(
      index,
      (context, animation) => widget.removeAnimation(
        widget.itemBuilder(context, index),
        animation,
      ),
      duration: duration,
    );
    --_itemCount;
    await Future.delayed(duration);
  }

  late final GlobalKey<AnimatedListState> listKey;

  @override
  void initState() {
    super.initState();
    listKey = GlobalKey<AnimatedListState>();
    _itemCount = widget.initialItemCount;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      itemBuilder: (context, index, animation) =>
          widget.insertAnimation(widget.itemBuilder(context, index), animation),
      initialItemCount: widget.initialItemCount,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      clipBehavior: widget.clipBehavior,
    );
  }
}

class DoubleBackToExit extends StatefulWidget {
  final Duration doublePressDuration;
  final Widget child;
  final VoidCallback? showMessage;
  const DoubleBackToExit({
    Key? key,
    required this.child,
    this.doublePressDuration = const Duration(seconds: 2),
    required this.showMessage,
  }) : super(key: key);

  @override
  _DoubleBackToExitState createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  bool tapped = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (tapped) {
          return true;
        }
        tapped = true;
        widget.showMessage?.call();
        Timer(widget.doublePressDuration, () {
          tapped = false;
        });
        return false;
      },
      child: widget.child,
    );
  }
}

class LoadMore extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final Future<void> Function() loadMore;
  final Widget loadingIndicator;
  final bool reverse;
  final double fetchBeforeEdgeOffset;
  final int maxAutoRecursions;
  final bool loadMoreAtStartIfRequired;

  const LoadMore({
    Key? key,
    required this.child,
    required this.scrollController,
    required this.loadMore,
    this.loadingIndicator = const LinearProgressIndicator(),
    this.reverse = false,
    this.fetchBeforeEdgeOffset = 100,
    this.maxAutoRecursions = 5,
    this.loadMoreAtStartIfRequired = true,
  }) : super(key: key);

  @override
  _LoadMoreState createState() => _LoadMoreState();
}

class _LoadMoreState extends State<LoadMore> {
  late final ValueNotifier<bool> _loadingMore;

  @override
  void initState() {
    super.initState();
    _loadingMore = ValueNotifier<bool>(false);
    widget.scrollController.addListener(_loadMore);
    if (widget.loadMoreAtStartIfRequired) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await _loadMore();
      });
    }
  }

  @override
  void dispose() {
    _loadingMore.dispose();
    super.dispose();
  }

  bool get _shouldLoadMore =>
      (widget.scrollController.hasClients) &&
      (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent -
              widget.fetchBeforeEdgeOffset);

  Future<void> _loadMore() async {
    if (_loadingMore.value) {
      return;
    }
    if (!widget.scrollController.hasClients) {
      printExceptRelease(
        "ScrollController is not attached to any ScrollViews, so cancelling loadMore()",
      );
      return;
    }
    int triesLeft = widget.maxAutoRecursions;
    while (_shouldLoadMore && ((triesLeft--) > 0)) {
      if (mounted) {
        _loadingMore.value = true;
      }
      await widget.loadMore();
      if (mounted) {
        _loadingMore.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.reverse)
          ValueListenableBuilder<bool>(
            valueListenable: _loadingMore,
            builder: (context, loadingMore, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: loadingMore ? widget.loadingIndicator : const Null(),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            ),
          ),
        Expanded(child: widget.child),
        if (!widget.reverse)
          ValueListenableBuilder<bool>(
            valueListenable: _loadingMore,
            builder: (context, loadingMore, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: loadingMore ? widget.loadingIndicator : const Null(),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class EmptyIndicator extends StatelessWidget {
  final String message;
  const EmptyIndicator({
    Key? key,
    this.message = 'Empty in here...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}

Widget _errorWidgetBuilder(DataGenerateObservable observable) =>
    Text("Error occured: ${observable.error}");

class ErrorIndicator<T extends DataGenerateObservable> extends StatelessWidget {
  final T observable;
  final Widget Function(T)? widgetBuilder;
  final String buttonText;

  const ErrorIndicator({
    Key? key,
    required this.observable,
    this.widgetBuilder = _errorWidgetBuilder,
    this.buttonText = 'Try Again',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetBuilder!(observable),
          Padding(
            padding: const EdgeInsets.all(20),
            child: LoadingElevatedButton(
              child: Text(buttonText),
              onPressed: observable.generate,
            ),
          ),
        ],
      ),
    );
  }
}

class DataGenerateObserver<T extends DataGenerateObservable>
    extends StatelessWidget {
  final Widget Function(T) builder;
  final T observable;
  final Widget loadingIndicator;
  final Widget Function(T)? errorWidgetBuilder;
  final String emptyMessage;
  final String tryAgainButtonText;
  final bool Function(T) dataIsEmpty;
  final bool Function(T)? shouldShowLoading;

  const DataGenerateObserver({
    Key? key,
    required this.observable,
    required this.builder,
    required this.dataIsEmpty,
    this.loadingIndicator = const Center(
      child: CircularProgressIndicator(),
    ),
    this.emptyMessage = 'Empty in here...',
    this.errorWidgetBuilder = _errorWidgetBuilder,
    this.tryAgainButtonText = 'Try Again',
    this.shouldShowLoading,
  }) : super(key: key);

  bool get _shouldShowLoading => shouldShowLoading?.call(observable) ??
          observable is PartDataGenerateObservable
      ? observable.hasNoData
      : observable.isLoading;
  /*{
    if (observable is PartDataGenerateObservable) {
      return observable.initializing;
    }
    return observable.isLoading;
  }*/

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _shouldShowLoading
          ? const LoadingIndicator()
          : (observable.isError)
              ? ErrorIndicator(
                  observable: observable,
                  widgetBuilder: errorWidgetBuilder,
                  buttonText: tryAgainButtonText,
                )
              : (dataIsEmpty(observable))
                  ? EmptyIndicator(
                      message: emptyMessage,
                    )
                  : builder(observable),
    );
  }
}

@immutable
class ShakeWidget extends StatelessWidget {
  final Duration duration;
  final double strength;
  final Widget child;
  final Curve curve;
  final Axis direction;

  const ShakeWidget({
    Key? key,
    this.duration = const Duration(milliseconds: 500),
    this.strength = 20,
    this.curve = Curves.bounceOut,
    required this.child,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  /// convert 0-1 to 0-1-0
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, animation, child) => Transform.translate(
        offset: (direction == Axis.horizontal)
            ? Offset(strength * shake(animation), 0)
            : Offset(0, strength * shake(animation)),
        child: child,
      ),
      child: child,
    );
  }
}

class ProperContext extends StatelessWidget {
  final Widget child;

  const ProperContext({
    Key? key,
    required this.child,
  }) : super(key: key);

  static late BuildContext _context;
  static BuildContext get context => _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return child;
  }
}

Widget _defaultTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> anotherAnimation,
  Widget child,
) =>
    FadeScaleTransition(
      animation: animation,
      child: child,
    );

PageRouteBuilder<T> customPageRoute<T>(
  Widget child, {
  RouteSettings? settings,
  required Widget Function(BuildContext, Animation<double>, Animation<double>)
      pageBuilder,
  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      transitionsBuilder = _defaultTransitionsBuilder,
  Duration transitionDuration = const Duration(milliseconds: 300),
  Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  bool opaque = true,
  bool barrierDismissible = false,
  Color? barrierColor,
  String? barrierLabel,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, anotherAnimation) => child,
    transitionsBuilder: transitionsBuilder,
    settings: settings,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    opaque: opaque,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
}

typedef MultiValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  Map<T, dynamic> values,
  Widget? child,
);

class MultiValueListenableBuilder<T> extends StatefulWidget {
  final Map<T, ValueListenable<dynamic>> valueListenables;
  final MultiValueWidgetBuilder builder;
  final Widget? child;

  const MultiValueListenableBuilder({
    Key? key,
    required this.valueListenables,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  State<MultiValueListenableBuilder<T>> createState() =>
      _MultiValueListenableBuilderState<T>();
}

class _MultiValueListenableBuilderState<T>
    extends State<MultiValueListenableBuilder<T>> {
  late Map<T, dynamic> values;

  @override
  void initState() {
    super.initState();
    //value = widget.valueListenable.value;
    values = _extractValues();
    //widget.valueListenable.addListener(_valueChanged);
    _registerListener(widget.valueListenables);
  }

  /*@override
  void didUpdateWidget(ValueListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
  }*/

  @override
  void didUpdateWidget(covariant MultiValueListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.valueListenables.values
        .isAnagramOf(widget.valueListenables.values)) {
      _removeListener(oldWidget.valueListenables);
      values = _extractValues();
      _registerListener(widget.valueListenables);
    }
  }

  @override
  void dispose() {
    //widget.valueListenable.removeListener(_valueChanged);
    _removeListener(widget.valueListenables);
    super.dispose();
  }

  void _valueChanged() {
    setState(() {
      values = _extractValues();
    });
  }

/*
  S getValue<S>(T key, {S Function()? onError}) {
    if (values.containsKey(key)) {
      return values[key] as S;
    }
    if (onError == null) {
      throw "Error! Key not found!";
    }
    return onError();
  }
*/
  Map<T, dynamic> _extractValues() {
    final Map<T, ValueListenable<dynamic>> valueListenables =
        widget.valueListenables;
    final Map<T, dynamic> result = Map<T, dynamic>.fromIterables(
      valueListenables.keys,
      valueListenables.values.map(
        (e) => e.value,
      ),
    );
    return result;
  }

  void _registerListener(Map<T, ValueListenable<dynamic>> valueListenables) {
    final List<ValueListenable<dynamic>> listenables =
        valueListenables.values.toList();
    for (final x in listenables) {
      x.addListener(_valueChanged);
    }
  }

  void _removeListener(Map<T, ValueListenable<dynamic>> valueListenables) {
    final List<ValueListenable<dynamic>> listenables =
        valueListenables.values.toList();
    for (final x in listenables) {
      x.removeListener(_valueChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, values, widget.child);
  }
}

class SearchField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final Widget prefixIcon;
  final EdgeInsetsGeometry margin;
  final bool? isFilled;

  const SearchField({
    Key? key,
    required this.controller,
    this.labelText = 'Search',
    this.hintText,
    this.prefixIcon = const Icon(Icons.search),
    this.margin = const EdgeInsets.all(10),
    this.isFilled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: isFilled,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, filterText, _) => SizedBox(
              height: 30,
              width: 40,
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 200),
                child: filterText.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        onPressed: controller.clear,
                      )
                    : empty,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
