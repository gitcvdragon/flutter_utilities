part of utility_widgets;

typedef FeedbackCallback = Future<bool?> Function();

enum TaskStatus { notStarted, inProgress, successful, failed }

abstract class LoadingButtonStateMixin {
  bool _isMounted = true;
  final ValueNotifier<TaskStatus> _taskStatus =
      ValueNotifier<TaskStatus>(TaskStatus.notStarted);

  Future<void> Function()? onAction(
     FeedbackCallback? x,
     Duration resetDuration,
  ) =>
      (x == null)
          ? null
          : () async {
              if (_taskStatus.value == TaskStatus.inProgress) {
                return;
              }
              if (_isMounted) {
                _taskStatus.value = TaskStatus.inProgress;
              }
              switch (await x()) {
                case true:
                  _taskStatus.value = TaskStatus.successful;
                  Future.delayed(resetDuration, () {
                    if (_isMounted) {
                      _taskStatus.value = TaskStatus.notStarted;
                    }
                  });
                  break;
                case false:
                  _taskStatus.value = TaskStatus.failed;
                  Future.delayed(resetDuration, () {
                    if (_isMounted) {
                      _taskStatus.value = TaskStatus.notStarted;
                    }
                  });
                  break;
                case null:
                  if (_isMounted) {
                    _taskStatus.value = TaskStatus.notStarted;
                  }
              }
            };

  Widget _childBuilder({
    required  TaskStatus taskStatus,
    required  Widget idle,
    required  Widget inProgress,
    required  Widget successful,
    required  Widget failed,
  }) {
    switch (taskStatus) {
      case TaskStatus.notStarted:
        return idle;
      case TaskStatus.inProgress:
        return inProgress;
      case TaskStatus.successful:
        return successful;
      case TaskStatus.failed:
        return failed;
    }
  }

  Widget builder({
    required  Widget idle,
    required  Widget inProgress,
    required  Widget successful,
    required  Widget failed,
  }) =>
      ValueListenableBuilder<TaskStatus>(
        valueListenable: _taskStatus,
        builder: (context, taskStatus, c) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          child: _childBuilder(
            taskStatus: taskStatus,
            idle: idle,
            inProgress: inProgress,
            successful: successful,
            failed: failed,
          ),
        ),
      );

  void disposeLoadingButton() {
    _isMounted = false;
    _taskStatus.dispose();
  }
}

class LoadingIconButton extends StatefulWidget {
  final Widget icon;
  final FeedbackCallback? onPressed;
  final double iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final MouseCursor mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool enableFeedback;
  final BoxConstraints? constraints;

  final Duration onCompletionStatusShowDuration;
  final Widget inProgress;
  final Widget successful;
  final Widget failed;

  const LoadingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onCompletionStatusShowDuration = const Duration(seconds: 1),
    this.inProgress = const SpinIt(
      child: Icon(
        EvilIcons.spinner_3,
        size: 20,
      ),
    ),
    this.successful = const Icon(Icons.done),
    this.failed = const Icon(Icons.clear),
    this.iconSize = 24.0,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor = SystemMouseCursors.click,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback = true,
    this.constraints,
  });

  @override
  _LoadingIconButtonState createState() => _LoadingIconButtonState();
}

class _LoadingIconButtonState extends State<LoadingIconButton>
    with LoadingButtonStateMixin {
  @override
  void dispose() {
    disposeLoadingButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onAction(
        widget.onPressed,
        widget.onCompletionStatusShowDuration,
      ),
      icon: builder(
        idle: widget.icon,
        inProgress: widget.inProgress,
        successful: widget.successful,
        failed: widget.failed,
      ),
      iconSize: widget.iconSize,
      visualDensity: widget.visualDensity,
      padding: widget.padding,
      alignment: widget.alignment,
      splashRadius: widget.splashRadius,
      color: widget.color,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      highlightColor: widget.highlightColor,
      splashColor: widget.splashColor,
      disabledColor: widget.disabledColor,
      mouseCursor: widget.mouseCursor,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      tooltip: widget.tooltip,
      enableFeedback: widget.enableFeedback,
      constraints: widget.constraints,
    );
  }
}

class LoadingFloatingActionButton extends StatefulWidget {
  final Widget child;
  final FeedbackCallback? onPressed;
  final String? tooltip;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Object? heroTag;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final MouseCursor? mouseCursor;
  final bool mini;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final MaterialTapTargetSize? materialTapTargetSize;
  final bool isExtended;

  final Duration onCompletionStatusShowDuration;
  final Widget inProgress;
  final Widget successful;
  final Widget failed;

  const LoadingFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onCompletionStatusShowDuration = const Duration(seconds: 1),
    this.inProgress = const SpinIt(
      child: Icon(
        EvilIcons.spinner_3,
        size: 20,
      ),
    ),
    this.successful = const Icon(Icons.done),
    this.failed = const Icon(Icons.clear),
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.mini = false,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.isExtended = false,
  });

  @override
  _LoadingFloatingActionButtonState createState() =>
      _LoadingFloatingActionButtonState();
}

class _LoadingFloatingActionButtonState
    extends State<LoadingFloatingActionButton> with LoadingButtonStateMixin {
  @override
  void dispose() {
    disposeLoadingButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: builder(
        idle: widget.child,
        inProgress: widget.inProgress,
        successful: widget.successful,
        failed: widget.failed,
      ),
      onPressed: onAction(
        widget.onPressed,
        widget.onCompletionStatusShowDuration,
      ),
      tooltip: widget.tooltip,
      foregroundColor: widget.foregroundColor,
      backgroundColor: widget.backgroundColor,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      splashColor: widget.splashColor,
      heroTag: widget.heroTag,
      elevation: widget.elevation,
      focusElevation: widget.focusElevation,
      hoverElevation: widget.hoverElevation,
      highlightElevation: widget.highlightElevation,
      disabledElevation: widget.disabledElevation,
      mouseCursor: widget.mouseCursor,
      mini: widget.mini,
      shape: widget.shape,
      clipBehavior: widget.clipBehavior,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      materialTapTargetSize: widget.materialTapTargetSize,
      isExtended: widget.isExtended,
    );
  }
}

class LoadingElevatedButton extends StatefulWidget {
  final Widget child;
  final FeedbackCallback? onPressed;
  final FeedbackCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;

  final Duration onCompletionStatusShowDuration;
  final Widget inProgress;
  final Widget successful;
  final Widget failed;

  const LoadingElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onCompletionStatusShowDuration = const Duration(seconds: 1),
    this.inProgress = const SpinIt(
      child: Icon(
        EvilIcons.spinner_3,
        size: 20,
      ),
    ),
    this.successful = const Icon(Icons.done),
    this.failed = const Icon(Icons.clear),
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  });

  @override
  _LoadingElevatedButtonState createState() => _LoadingElevatedButtonState();
}

class _LoadingElevatedButtonState extends State<LoadingElevatedButton>
    with LoadingButtonStateMixin {
  @override
  void dispose() {
    disposeLoadingButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: builder(
        idle: widget.child,
        inProgress: widget.inProgress,
        successful: widget.successful,
        failed: widget.failed,
      ),
      onPressed: onAction(
        widget.onPressed,
        widget.onCompletionStatusShowDuration,
      ),
      onLongPress: onAction(
        widget.onLongPress,
        widget.onCompletionStatusShowDuration,
      ),
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
    );
  }
}

class LoadingTextButton extends StatefulWidget {
  final Widget child;
  final FeedbackCallback? onPressed;
  final FeedbackCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;

  final Duration onCompletionStatusShowDuration;
  final Widget inProgress;
  final Widget successful;
  final Widget failed;

  const LoadingTextButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.onCompletionStatusShowDuration = const Duration(seconds: 1),
    this.inProgress = const SpinIt(
      child: Icon(
        EvilIcons.spinner_3,
        size: 20,
      ),
    ),
    this.successful = const Icon(Icons.done),
    this.failed = const Icon(Icons.clear),
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  _LoadingTextButtonState createState() => _LoadingTextButtonState();
}

class _LoadingTextButtonState extends State<LoadingTextButton>
    with LoadingButtonStateMixin {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: builder(
        idle: widget.child,
        inProgress: widget.inProgress,
        successful: widget.successful,
        failed: widget.failed,
      ),
      onPressed: onAction(
        widget.onPressed,
        widget.onCompletionStatusShowDuration,
      ),
      onLongPress: onAction(
        widget.onLongPress,
        widget.onCompletionStatusShowDuration,
      ),
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
    );
  }
}

/*
class LoadingAdaptiveFloatingActionButton extends StatefulWidget {
  final Widget label;
  final Widget icon;
  final ScrollController scrollController;
  final FeedbackCallback? onPressed;

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

  final Duration onCompletionStatusShowDuration;
  final Widget inProgress;
  final Widget successful;
  final Widget failed;

  const LoadingAdaptiveFloatingActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.scrollController,
    required this.onPressed,
    this.onCompletionStatusShowDuration = const Duration(seconds: 1),
    this.inProgress = const SpinIt(
      child: Icon(
        EvilIcons.spinner_3,
        size: 20,
      ),
    ),
    this.successful = const Icon(Icons.done),
    this.failed = const Icon(Icons.clear),
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
  }) : super(key: key);

  @override
  _LoadingAdaptiveFloatingActionButtonState createState() =>
      _LoadingAdaptiveFloatingActionButtonState();
}

class _LoadingAdaptiveFloatingActionButtonState
    extends State<LoadingAdaptiveFloatingActionButton>
    with LoadingButtonStateMixin {
  @override
  void dispose() {
    disposeLoadingButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveFloatingActionButton(
      icon: builder(
        idle: widget.icon,
        inProgress: widget.inProgress,
        successful: widget.successful,
        failed: widget.failed,
      ),
      label: builder(
        idle: widget.label,
        inProgress: const Null(),
        successful: const Null(),
        failed: const Null(),
      ),
      onPressed: onAction(
        widget.onPressed,
        widget.onCompletionStatusShowDuration,
      ),
      scrollController: widget.scrollController,
      shrinkOnForwardScroll: widget.shrinkOnForwardScroll,
      shrinkOnBackwardScroll: widget.shrinkOnBackwardScroll,
      extendOnForwardScroll: widget.extendOnForwardScroll,
      extendOnBackwardScroll: widget.extendOnBackwardScroll,
      delayBeforeExtend: widget.delayBeforeExtend,
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
    );
  }
}
*/
