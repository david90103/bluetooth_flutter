import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetooth/widgets.dart';
import 'dart:convert';
import 'home.dart';
import 'common/database.dart';

// class BluePage extends StatefulWidget {
//   static String tag = 'login-page';
//   @override
//   BluePageState createState() => new BluePageState();
// }

// class BluePageState extends State<BluePage> with TickerProviderStateMixin {
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   @override
//   void initState() {
//     super.initState();
//     flutterBlue.scanResults.listen((scanResult) {
//       for (ScanResult s in scanResult) {
//         print('${s.device.name} found! rssi: ${s.rssi}');
//       }
//       if (scanResult.length == 0) print('no device');
//     });
//   }
// }

class BluePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                      children: snapshot.data
                          .map((d) => ListTile(
                                title: Text(d.name),
                                subtitle: Text(d.id.toString()),
                                trailing: StreamBuilder<BluetoothDeviceState>(
                                  stream: d.state,
                                  initialData:
                                      BluetoothDeviceState.disconnected,
                                  builder: (c, snapshot) {
                                    if (snapshot.data ==
                                        BluetoothDeviceState.connected) {
                                      return RaisedButton(
                                        child: Text('OPEN'),
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    DeviceScreen(device: d))),
                                      );
                                    }
                                    return Text(snapshot.data.toString());
                                  },
                                ),
                              ))
                          .toList(),
                    ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                      children: snapshot.data
                          .map(
                            (r) => ScanResultTile(
                                  result: r,
                                  onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        r.device.connect();
                                        return DeviceScreen(device: r.device);
                                      })),
                                ),
                          )
                          .toList(),
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  MonitorDatabase database;

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
  }

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
                service: s,
                characteristicTiles: s.characteristics
                    .map(
                      (c) => CharacteristicTile(
                            characteristic: c,
                            onReadPressed: () => c.read(),
                            onWritePressed: () => c.write(_getRandomBytes()),
                            onNotificationPressed: () {
                              c.setNotifyValue(!c.isNotifying);
                              c.value.listen((value) {
                                HomePageState.buffer += value;

                                while (true) {
                                  int index = HomePageState.buffer
                                      .indexOf('\n'.codeUnitAt(0));
                                  if (index >= 0) {
                                    try {
                                      List result = utf8
                                          .decode(HomePageState.buffer)
                                          .split(',');
                                      HomePageState.beat =
                                          _adjustBeat(double.parse(result[0]));
                                      HomePageState.oxygen =
                                          _adjustOxygen(int.parse(result[1]));

                                      for (int i = 0; i < 16; i++) {
                                        HomePageState.breathe.removeAt(0);
                                        HomePageState.breathe
                                            .add(double.parse(result[2 + i]));
                                      }

                                      HomePageState.risk =
                                          int.parse(result[18]);
                                      if (HomePageState.recording)
                                        database.saveRecord(result);
                                    } catch (e) {
                                      print(e);
                                    }
                                    HomePageState.buffer.clear();
                                  } else {
                                    break;
                                  }
                                }
                              });
                            },
                            descriptorTiles: c.descriptors
                                .map(
                                  (d) => DescriptorTile(
                                        descriptor: d,
                                        onReadPressed: () => d.read(),
                                        onWritePressed: () =>
                                            d.write(_getRandomBytes()),
                                      ),
                                )
                                .toList(),
                          ),
                    )
                    .toList(),
              ),
        )
        .toList();
  }

  double _adjustBeat(beat) {
    if (beat < 60) beat = 60.0;
    if (beat > 140) beat = 140.0;
    //檢查浮動是否過大
    double prev = HomePageState.beat;
    if (prev == 0) {
      return beat;
    } else if (prev - beat > 10) {
      return prev - 10;
    } else if (beat - prev > 10) {
      return prev + 10;
    }
    return beat;
  }

  int _adjustOxygen(oxygen) {
    //檢查感測器是否脫落
    if (oxygen == 0) {
      if (HomePageState.dropAlert <= 10) {
        HomePageState.dropAlert++;
      }
    } else {
      HomePageState.dropAlert = 0;
    }
    if (oxygen < 80) oxygen = 80;
    if (oxygen > 100) oxygen = 100;
    //檢查浮動是否過大
    int prev = HomePageState.oxygen;
    if (prev == 0) {
      return oxygen;
    } else if (prev - oxygen > 2) {
      return prev - 2;
    } else if (oxygen - prev > 2) {
      return prev + 2;
    }
    return oxygen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                    leading: (snapshot.data == BluetoothDeviceState.connected)
                        ? Icon(Icons.bluetooth_connected)
                        : Icon(Icons.bluetooth_disabled),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    subtitle: Text('${widget.device.id}'),
                    trailing: StreamBuilder<bool>(
                      stream: widget.device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) => IndexedStack(
                            index: snapshot.data ? 1 : 0,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () =>
                                    widget.device.discoverServices(),
                              ),
                              IconButton(
                                icon: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.grey),
                                  ),
                                  width: 18.0,
                                  height: 18.0,
                                ),
                                onPressed: null,
                              )
                            ],
                          ),
                    ),
                  ),
            ),
            StreamBuilder<int>(
              stream: widget.device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                    title: Text('MTU Size'),
                    subtitle: Text('${snapshot.data} bytes'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => widget.device.requestMtu(223),
                    ),
                  ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
