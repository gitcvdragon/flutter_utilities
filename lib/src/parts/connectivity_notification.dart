part of utility_widgets;

class ConnectivityNotification extends StatefulWidget {
  final Widget child;
  final String offlineText;
  final String onlineUsingMobileDataText;
  final String onlineUsingWiFiText;
  final String onlineUsingEthernetText;
  final String onlineUsingBluetoothText;

  final Color offlineColor;
  final Color onlineUsingMobileDataColor;
  final Color onlineUsingWifiColor;
  final Color onlineUsingEthernetColor;
  final Color onlineUsingBluetoothColor;

  final double height;
  final Duration hideDelay;
  final Duration hideDuration;
  final bool hideIfOffline;
  final Duration colorChangeDuration;
  final Duration messageFadeTransitionDuration;
  final void Function(ConnectivityResult)? onConnectivityStatusChanged;
  final VoidCallback? onOfflineOnStart;
  final bool show;

  const ConnectivityNotification({
    super.key,
    required this.child,
    this.offlineText = 'No Connection',
    this.onlineUsingMobileDataText = 'Connected using Mobile Data',
    this.onlineUsingWiFiText = 'Connected using WiFi',
    this.onlineUsingEthernetText = 'Connected using Ethernet',
    this.onlineUsingBluetoothText = 'Connected using Bluetooth',
    this.offlineColor = Colors.red,
    this.onlineUsingMobileDataColor = Colors.green,
    this.onlineUsingWifiColor = Colors.green,
    this.onlineUsingEthernetColor = Colors.green,
    this.onlineUsingBluetoothColor = Colors.green,
    this.height = 20,
    this.hideDelay = const Duration(seconds: 3),
    this.hideDuration = const Duration(milliseconds: 500),
    this.hideIfOffline = false,
    this.colorChangeDuration = const Duration(milliseconds: 100),
    this.messageFadeTransitionDuration = const Duration(milliseconds: 50),
    this.onConnectivityStatusChanged,
    this.onOfflineOnStart,
    this.show = true,
  });

  @override
  _ConnectivityNotificationState createState() =>
      _ConnectivityNotificationState();
}

class _ConnectivityNotificationState extends State<ConnectivityNotification> {
  late final StreamSubscription _connectivityListenerSubsCription;
  late final ValueNotifier<ConnectivityResult> _connectivityStatus;
  late final ValueNotifier<double> _height;
  late final ValueNotifier<String> _statusMessage;
  late final ValueNotifier<Color> _color;

  @override
  void initState() {
    super.initState();
    _height = ValueNotifier<double>(0);
    _statusMessage = ValueNotifier<String>(widget.offlineText);
    _color = ValueNotifier(widget.offlineColor);
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
        final ConnectivityResult connectivityResult = _connectivityStatus.value;
        widget.onConnectivityStatusChanged?.call(connectivityResult);
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
        _color.value = widget.offlineColor;
        _height.value = widget.height;
        _statusMessage.value = widget.offlineText;
        if (widget.hideIfOffline) {
          Future.delayed(widget.hideDelay, () {
            if (connectivityResult == ConnectivityResult.none) {
              _height.value = 0;
            }
          });
        }
        break;
      case ConnectivityResult.mobile:
        _color.value = widget.onlineUsingMobileDataColor;
        _statusMessage.value = widget.onlineUsingMobileDataText;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.mobile) {
            _height.value = 0;
          }
        });
        break;
      case ConnectivityResult.wifi:
        _color.value = widget.onlineUsingWifiColor;
        _statusMessage.value = widget.onlineUsingWiFiText;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.wifi) {
            _height.value = 0;
          }
        });
        break;
      case ConnectivityResult.ethernet:
        _color.value = widget.onlineUsingEthernetColor;
        _statusMessage.value = widget.onlineUsingEthernetText;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.ethernet) {
            _height.value = 0;
          }
        });
        break;
      case ConnectivityResult.bluetooth:
        _color.value = widget.onlineUsingBluetoothColor;
        _statusMessage.value = widget.onlineUsingBluetoothText;
        Future.delayed(widget.hideDelay, () {
          if (connectivityResult == ConnectivityResult.bluetooth) {
            _height.value = 0;
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blue,
      builder: (context, child) => Column(
        children: [
          Expanded(child: widget.child),
          Material(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            type: MaterialType.transparency,
            child: Directionality(
              textDirection: TextDirection.ltr,
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
          ),
        ],
      ),
    );
  }
}
