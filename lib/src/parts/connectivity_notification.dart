part of '../utility_widgets.dart';

class ConnectivityNotificationConfig {
  final ConnectivityNotificationConfigItem offline;
  final ConnectivityNotificationConfigItem mobileData;
  final ConnectivityNotificationConfigItem wifi;
  final ConnectivityNotificationConfigItem ethernet;
  final ConnectivityNotificationConfigItem bluetooth;
  final ConnectivityNotificationConfigItem vpn;
  final ConnectivityNotificationConfigItem other;

  const ConnectivityNotificationConfig({
    required this.offline,
    required this.mobileData,
    required this.wifi,
    required this.ethernet,
    required this.bluetooth,
    required this.vpn,
    required this.other,
  });

  const ConnectivityNotificationConfig.defaultConfig({
    this.offline = const ConnectivityNotificationConfigItem.offline(),
    this.mobileData = const ConnectivityNotificationConfigItem.online(),
    this.wifi = const ConnectivityNotificationConfigItem.online(),
    this.ethernet = const ConnectivityNotificationConfigItem.online(),
    this.bluetooth = const ConnectivityNotificationConfigItem.online(),
    this.vpn = const ConnectivityNotificationConfigItem.online(),
    this.other = const ConnectivityNotificationConfigItem.online(),
  });

  @override
  bool operator ==(Object otherObject) {
    if (identical(this, otherObject)) return true;

    return otherObject is ConnectivityNotificationConfig &&
        otherObject.offline == offline &&
        otherObject.mobileData == mobileData &&
        otherObject.wifi == wifi &&
        otherObject.ethernet == ethernet &&
        otherObject.bluetooth == bluetooth &&
        otherObject.vpn == vpn &&
        otherObject.other == other;
  }

  @override
  int get hashCode {
    return offline.hashCode ^
        mobileData.hashCode ^
        wifi.hashCode ^
        ethernet.hashCode ^
        bluetooth.hashCode ^
        vpn.hashCode ^
        other.hashCode;
  }

  @override
  String toString() {
    return 'ConnectivityNotificationConfig(offline: $offline, mobileData: $mobileData, wifi: $wifi, ethernet: $ethernet, bluetooth: $bluetooth, vpn: $vpn, other: $other)';
  }

  ConnectivityNotificationConfig copyWith({
    ConnectivityNotificationConfigItem? offline,
    ConnectivityNotificationConfigItem? mobileData,
    ConnectivityNotificationConfigItem? wifi,
    ConnectivityNotificationConfigItem? ethernet,
    ConnectivityNotificationConfigItem? bluetooth,
    ConnectivityNotificationConfigItem? vpn,
    ConnectivityNotificationConfigItem? other,
  }) {
    return ConnectivityNotificationConfig(
      offline: offline ?? this.offline,
      mobileData: mobileData ?? this.mobileData,
      wifi: wifi ?? this.wifi,
      ethernet: ethernet ?? this.ethernet,
      bluetooth: bluetooth ?? this.bluetooth,
      vpn: vpn ?? this.vpn,
      other: other ?? this.other,
    );
  }
}

class ConnectivityNotificationConfigItem {
  final String text;
  final Color color;

  const ConnectivityNotificationConfigItem({
    required this.text,
    required this.color,
  });

  const ConnectivityNotificationConfigItem.online({
    this.text = "Online",
    this.color = Colors.green,
  });

  const ConnectivityNotificationConfigItem.offline({
    this.text = "Offline",
    this.color = Colors.red,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityNotificationConfigItem &&
        other.text == text &&
        other.color == color;
  }

  @override
  int get hashCode => text.hashCode ^ color.hashCode;

  @override
  String toString() =>
      'ConnectivityNotificationConfigItem(text: $text, color: $color)';
}

class ConnectivityNotification extends StatefulWidget {
  final Widget child;

  final ConnectivityNotificationConfig config;

  final double height;
  final Duration hideDelay;
  final Duration hideDuration;
  final bool hideIfOffline;
  final Duration colorChangeDuration;
  final Duration messageFadeTransitionDuration;
  final void Function(ConnectivityResult, BuildContext)?
      onConnectivityStatusChanged;
  final TextDirection textDirection;
  final VoidCallback? onOfflineOnStart;
  final bool show;
  final bool onTop;

  const ConnectivityNotification({
    super.key,
    required this.child,
    this.config = const ConnectivityNotificationConfig.defaultConfig(),
    this.textDirection = TextDirection.ltr,
    this.height = 20,
    this.hideDelay = const Duration(seconds: 3),
    this.hideDuration = const Duration(milliseconds: 500),
    this.hideIfOffline = false,
    this.colorChangeDuration = const Duration(milliseconds: 100),
    this.messageFadeTransitionDuration = const Duration(milliseconds: 50),
    this.onConnectivityStatusChanged,
    this.onOfflineOnStart,
    this.show = true,
    this.onTop = false,
  });

  @override
  _ConnectivityNotificationState createState() =>
      _ConnectivityNotificationState();
}

class _ConnectivityNotificationState extends State<ConnectivityNotification> {
  late final StreamSubscription _connectivityListenerSubsCription;
  late final ValueNotifier<ConnectivityResult?> _connectivityStatus;
  late final ValueNotifier<double> _height;
  late final ValueNotifier<String> _statusMessage;
  late final ValueNotifier<Color> _color;

  @override
  void initState() {
    super.initState();
    _height = ValueNotifier<double>(0);
    _statusMessage = ValueNotifier<String>(widget.config.offline.text);
    _color = ValueNotifier(widget.config.offline.color);
    final Connectivity c = Connectivity();

    c.checkConnectivity().then((connectivityResult) {
      _connectivityStatus =
          ValueNotifier<ConnectivityResult>(connectivityResult);
      if (widget.show) {
        _setParameters(connectivityResult);
      }
      if (connectivityResult == ConnectivityResult.none) {
        widget.onOfflineOnStart?.call();
      }
      _connectivityListenerSubsCription =
          c.onConnectivityChanged.listen((connectivityResult) {
        _connectivityStatus.value = connectivityResult;
      });

      _connectivityStatus.addListener(() {
        final ConnectivityResult? connectivityResult =
            _connectivityStatus.value;

        if (connectivityResult == null) {
          return;
        }

        widget.onConnectivityStatusChanged?.call(
          connectivityResult,
          context,
        );
        if (widget.show) {
          _setParameters(connectivityResult);
        }
      });
    });
  }

  @override
  void dispose() {
    _connectivityStatus.dispose();
    _connectivityListenerSubsCription.cancel();
    _height.dispose();
    _color.dispose();
    _statusMessage.dispose();
    super.dispose();
  }

  void _setParameters(ConnectivityResult connectivityResult) {
    switch (connectivityResult) {
      case ConnectivityResult.none:
        _color.value = widget.config.offline.color;
        _height.value = widget.height;
        _statusMessage.value = widget.config.offline.text;
        if (widget.hideIfOffline) {
          Future.delayed(widget.hideDelay, () {
            if (connectivityResult == ConnectivityResult.none) {
              _height.value = 0;
            }
          });
        }
      case ConnectivityResult.mobile:
        _color.value = widget.config.mobileData.color;
        _statusMessage.value = widget.config.mobileData.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.mobile) {
            _height.value = 0;
          }
        });
      case ConnectivityResult.wifi:
        _color.value = widget.config.wifi.color;
        _statusMessage.value = widget.config.wifi.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.wifi) {
            _height.value = 0;
          }
        });
      case ConnectivityResult.ethernet:
        _color.value = widget.config.ethernet.color;
        _statusMessage.value = widget.config.ethernet.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.ethernet) {
            _height.value = 0;
          }
        });
      case ConnectivityResult.bluetooth:
        _color.value = widget.config.bluetooth.color;
        _statusMessage.value = widget.config.bluetooth.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.bluetooth) {
            _height.value = 0;
          }
        });
      case ConnectivityResult.vpn:
        _color.value = widget.config.vpn.color;
        _statusMessage.value = widget.config.vpn.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.vpn) {
            _height.value = 0;
          }
        });
      case ConnectivityResult.other:
        _color.value = widget.config.other.color;
        _statusMessage.value = widget.config.other.text;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.other) {
            _height.value = 0;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blue,
      builder: (context, child) {
        final Widget bar = Material(
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          type: MaterialType.transparency,
          child: Directionality(
            textDirection: widget.textDirection,
            child: ValueListenableBuilder<Color>(
              valueListenable: _color,
              builder: (context, color, child) => AnimatedContainer(
                color: color,
                duration: widget.colorChangeDuration,
                child: child,
              ),
              child: ValueListenableBuilder<double>(
                valueListenable: _height,
                builder: (context, height, anotherChild) => AnimatedContainer(
                  height: height,
                  width: MediaQuery.of(context).size.width,
                  duration: widget.hideDuration,
                  child: anotherChild,
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: _statusMessage,
                  builder: (context, statusMessage, _) => AnimatedSwitcher(
                    duration: widget.messageFadeTransitionDuration,
                    child: Text(
                      statusMessage,
                      key: UniqueKey(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        return Column(
          children: [
            if (widget.onTop) bar,
            Expanded(child: widget.child),
            if (!widget.onTop) bar,
          ],
        );
      },
    );
  }
}
