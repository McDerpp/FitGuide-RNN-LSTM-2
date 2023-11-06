import 'dart:async';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'isolateProcessPDV.dart';
import 'package:flutter/foundation.dart';

// Note: heavy imports...may cause lots of load times in between running
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:frontend/pose_detections/detector_view.dart';
import '/painters/pose_painter.dart';

// UI related imports
import 'customWidgetPDV.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class PoseDetectorView extends StatefulWidget {
  bool isInferencing = false;
  // tfl.TfLiteType model;

  PoseDetectorView({super.key});

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

// NOTE TO SELF -> improve variable initialization(might take up lots of memory since not all variables will be used in one go(inferencing/collectingData))

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ---------------------inferencing mode variables----------------------------------------------------------
  RootIsolateToken rootIsolateTokenNormalization = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenNoMovement = RootIsolateToken.instance!;
  RootIsolateToken rootIsolateTokenInferencing = RootIsolateToken.instance!;

  List<double> prevCoordinates = [];
  List<double> currentCoordinates = [];
  List<List<double>> inferencingList = [];
  List<List<double>> tempPrevCurr = [];
  bool checkFramesCaptured = false;
  int framesCapturedCtr = 0;

  String dynamicText = 'no movement detected';
  String dynamicCtr = '0';
  int execTotalFrames = 0;
  int numExec = 0;
  double avgFrames = 0.0;

  List<Map<String, dynamic>> queueNormalizeData = [];
  List<Map<String, dynamic>> queueMovementData = [];
  List<Map<String, dynamic>> queueInferencingData = [];
  int noMovementCtr = 0;
  // ---------------------inferencing mode variables----------------------------------------------------------

  // ---------------------countdown variables----------------------------------------------------------
  late int _seconds;
  late Timer _timer;
  // ---------------------countdown variables----------------------------------------------------------

  // ---------------------collecting data mode variables----------------------------------------------------------
  List<double> temp = [];
  List<dynamic> coordinatesData = [];
  bool isSet = true;
  bool isDataCollected = true;

  // ---------------------collecting data mode variables----------------------------------------------------------

  // ---------------------countdown variables----------------------------------------------------------
  final int _duration = 10;
  final CountDownController _controller = CountDownController();
  bool nowPerforming = false;
  bool countDowntoPerform = false;
  bool checkCountDowntoPerform = false;
  int currentDuration = 3;
  String dynamicCountDownText = 'Ready';

  // ---------------------collecting data mode variables----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    if (widget.isInferencing == false) {}
    _seconds = 60;
  }

// final Future<Interpreter> interpreter = Interpreter.fromAsset(
//     'assets/models/wholeModel/otestingtesting(loss_0.063)(acc_0.982).tflite');

  List<List<Pose>> poseQueue = [];
  List<List<double>> queueNormalizedListQueue = [];

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    // _poseDetector.close();
    super.dispose();
  }

  Future<void> translateCollectedDatatoTxt(List<dynamic> dataCollected) async {
    Directory externalDir = await getApplicationDocumentsDirectory();
    String externalPath = externalDir!.path;
    String filePath = '$externalPath/coordinatesCollected.txt';
    File file = File(filePath);
    for (List exerciseSet in dataCollected) {
      await file.writeAsString('START\n', mode: FileMode.append);
      print("len_per_set ---> ${exerciseSet.length}");
      print("=========================================================================")

      for (List sequence in exerciseSet) {
        print("test1");
        print("seq_per_set ---> ${exerciseSet.length}");
        print("->> $sequence ");

        for (double individualCoordinate in sequence) {
          print("test2");

          await file.writeAsString('${individualCoordinate.toString()}|',
              mode: FileMode.append);
        }
        await file.writeAsString('\n', mode: FileMode.append);
      }
      await file.writeAsString('END\n', mode: FileMode.append);
      print("=========================================================================")

    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    // createFile();

    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    late final List<Pose> poses;
    // bool noMovement = false;

    setState(() {
      _text = '';
    });

// // ==================================[isolate function processImage ]==================================
    try {
      poses = await _poseDetector.processImage(inputImage);
      Map<String, dynamic> dataNormalizationIsolate = {
        'inputImage': poses.first.landmarks.values,
        'token': rootIsolateTokenNormalization,
      };
      queueNormalizeData.add(dataNormalizationIsolate);
    } catch (error) {
      print("error at proces image ---> $error");
    }

// // ==================================[isolate function processImage ]==================================

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================
    if (queueNormalizeData.isNotEmpty) {
      compute(coordinatesRelativeBoxIsolate, queueNormalizeData.elementAt(0))
          .then((value) {
        queueNormalizeData.removeAt(0);
        tempPrevCurr.add(value);
        // inferencingList.add(value);
        if (nowPerforming == true) {
          temp = value;
          // temp.add(value);
        }

        if (tempPrevCurr.length > 1) {
          prevCoordinates = tempPrevCurr.elementAt(0);
          currentCoordinates = tempPrevCurr.elementAt(1);

          Map<String, dynamic> checkMovementIsolate = {
            'prevCoordinates': prevCoordinates,
            'currentCoordinates': currentCoordinates,
            'token': rootIsolateTokenNoMovement,
          };
          queueMovementData.add(checkMovementIsolate);
          tempPrevCurr.removeAt(0);
        }
      }).catchError((error) {
        print("Error at coordinate relative ---> $error");
      });
    }

// // ==================================[isolate function forcoordinatesRelativeBoxIsolate ]==================================

// // ==================================[isolate function checkMovement ]==================================
    if (queueMovementData.isNotEmpty) {
      compute(checkMovement, queueMovementData.elementAt(0))
          .then((value) async {
        queueMovementData.removeAt(0);
        print("isolateNoMovementResult ---> $value");

        if (value == true && checkFramesCaptured == false) {
          checkFramesCaptured = true;
          framesCapturedCtr++;
          print("frames captured --> $framesCapturedCtr");
          execTotalFrames = execTotalFrames + framesCapturedCtr;
          framesCapturedCtr = 0;

          if (nowPerforming == true) {
            print("stopping");
            isDataCollected = true;
            coordinatesData.add(inferencingList);
            print("current count---> ${coordinatesData.length}");
            inferencingList = [];
            numExec++;
            print(
                "collecting--- ${isDataCollected} -------1---- ${nowPerforming}");
          }

          Map<String, dynamic> inferencingData = {
            'inferencingData': inferencingList,
            'token': rootIsolateTokenInferencing,
          };
        } else if (value == false) {
          framesCapturedCtr++;
          if (nowPerforming == true) {
            checkFramesCaptured = false;

            // inferencingList.add(temp.elementAt(0));
            inferencingList.add(temp);

            isDataCollected = false;
            print("collecting coordinates");
            print(
                "collecting--- ${isDataCollected} ------2----- ${nowPerforming}");
            temp = [];
          }
        }

        if (value == true) {
          // -----------------checking for movement before executing for collecting data--------------------------------------
          if (nowPerforming == false) {
            if (countDowntoPerform == false) {
              _controller.start();
              countDowntoPerform = true;
              dynamicCountDownText = 'Perform';
            }
          }

          if (_controller.getTime().toString() == "3" &&
              nowPerforming == false) {
            nowPerforming = true;
          }
          //---------------after not moving for 3 sec-------------------------

          // execTotalFrames = execTotalFrames + noMovementCtr;

          // Map<String, dynamic> inferencingData = {
          //   'inferencingData': inferencingList.sublist(0, noMovementCtr),
          //   'token': rootIsolateTokenInferencing,
          // };
          noMovementCtr = 0;
          setState(() {
            dynamicText = 'no movement detected';
            dynamicCtr = noMovementCtr.toString();
            try {
              avgFrames = execTotalFrames / numExec;
            } catch (error) {
              avgFrames = 0;
            }
          });
        } else {
          print("outside nowperforming--->, $nowPerforming");

          // noMovementCtr++;
          // -----------------checking for movement before executing for collecting data--------------------------------------

          if (nowPerforming == false) {
            if (countDowntoPerform == true) {
              _controller.reset();
              countDowntoPerform = false;
            }
          }
          // -----------------------------------------------------------------------------------------------------------

          setState(() {
            dynamicText = 'movement detected';
            dynamicCtr = noMovementCtr.toString();
          });
        }
      }).catchError((error) {
        print("Error at checkMovement ---> $error");
      });
    }
    // }
// // ==================================[isolate function checkMovement ]==================================

// // ==================================[isolate function inferencing ]==================================
// // input inferencing here
// // ==================================[isolate function inferencing ]==================================

// // ==================================[isolate function collecting data ]==================================
// // input inferencing here
// // ==================================[isolate function collecting data ]==================================

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';

      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: SizedBox(
          //     width: 320.0, // Set your desired width
          //     height: 240.0,
          //     child: Container(
          //       color: Colors.blue, // Set your desired color
          //       // Add other child widgets or properties here if needed
          //     ),
          //   ),
          // ),

          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0.0, -150.0), // Adjust the y-value to move it up
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Now performing:",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                  Text(
                    "Exercise name here",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                ],
              ),
            ),
          ),

          DetectorView(
            title: 'Pose Detector',
            customPaint: _customPaint,
            text: _text,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),

          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     _startTimer();
          //   },
          //   child: Icon(Icons.play_arrow),
          // ),
          Align(
            alignment: Alignment.topCenter,
            child: CircularCountDownTimer(
              duration: currentDuration,
              initialDuration: 0,
              controller: _controller,
              // width: MediaQuery.of(context).size.width / 2,
              // height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 4,
              ringColor: Colors.white!,
              ringGradient: null,
              fillColor: Colors.red,
              fillGradient: null,
              backgroundColor: const Color.fromARGB(255, 210, 21, 7),
              backgroundGradient: null,
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: false,
              onStart: () {
                print('Countdown Started');
              },
              onComplete: () {
                print('Countdown Ended');
              },
              onChange: (String timeStamp) {
                print('Countdown Changed $timeStamp');
              },
              timeFormatterFunction: (defaultFormatterFunction, duration) {
                if (duration.inSeconds == 0) {
                  return dynamicCountDownText;
                } else {
                  return Function.apply(defaultFormatterFunction, [duration]);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0.0, -20.0), // Adjust the y-value to move it up
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    // dynamicText,
                    dynamicText.toString(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                  Text(
                    numExec.toString(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF00),
                    ),
                  ),
                  Center(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          showCustomDialog(
                            context,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textInfoCtr("Total executed",
                                    numExec.toDouble(), 15, Colors.black),
                                textInfoCtr("Average Frames: ", avgFrames, 15,
                                    Colors.black),
                              ],
                            ),
                          );
                          translateCollectedDatatoTxt(coordinatesData);
                          print('pressing button');
                        },
                        child: Text('Done'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Positioned(
          //     top: 50.0,
          //     left: 20.0,
          //     child: Text(
          //       dynamicCtr,
          //       style: TextStyle(
          //         fontSize: 24.0,
          //         fontWeight: FontWeight.bold,
          //         color: Color(0xFF00FF00),
          //       ),
          //     ),
          //   ),
          // ),

          // Center(
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         print('pressing button111111111');
          //         _controller.start();
          //       },
          //       child: Text('start'),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // return Scaffold(
  //   body: Stack(
  //     children: [
  //       DetectorView(
  //         title: 'Pose Detector',
  //         customPaint: _customPaint,
  //         text: _text,
  //         onImage: _processImage,
  //         initialCameraLensDirection: _cameraLensDirection,
  //         onCameraLensDirectionChanged: (value) =>
  //             _cameraLensDirection = value,
  //       ),
  //       Positioned(
  //         top: 20.0,
  //         left: 20.0,
  //         child: Text(
  //           dynamicText,
  //           style: TextStyle(
  //             fontSize: 24.0,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF00FF00),
  //           ),
  //         ),
  //       ),
  //       Positioned(
  //         top: 50.0,
  //         left: 20.0,
  //         child: Text(
  //           dynamicCtr,
  //           style: TextStyle(
  //             fontSize: 24.0,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF00FF00),
  //           ),
  //         ),
  //       ),
  //       Center(
  //         child: Align(
  //           alignment: Alignment.bottomCenter,
  //           child: ElevatedButton(
  //             onPressed: () {
  //               _showConfirmationDialog();
  //               // translateCollectedDatatoTxt(coordinatesData);
  //               print('pressing button');
  //             },
  //             child: Text('Done'),
  //           ),
  //         ),
  //       ),
  //     ],
  //   ),
  // );
  // }

  // Widget mainPage() {
  //   print("mainpagecall");
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         const SizedBox(
  //           width: 352.0, // Set your desired width
  //           height: 288.0,
  //         ),
  //         // DetectorView(
  //         //   title: 'Pose Detector',
  //         //   customPaint: _customPaint,
  //         //   text: _text,
  //         //   onImage: _processImage,
  //         //   initialCameraLensDirection: _cameraLensDirection,
  //         //   onCameraLensDirectionChanged: (value) =>
  //         //       _cameraLensDirection = value,
  //         // ),
  //         Positioned(
  //           top: 20.0,
  //           left: 20.0,
  //           child: Text(
  //             dynamicText,
  //             style: TextStyle(
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF00FF00),
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           top: 50.0,
  //           left: 20.0,
  //           child: Text(
  //             dynamicCtr,
  //             style: TextStyle(
  //               fontSize: 24.0,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF00FF00),
  //             ),
  //           ),
  //         ),
  //         Center(
  //           child: Align(
  //             alignment: Alignment.bottomCenter,
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 () => showCustomDialog(
  //                     context,
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         textInfoCtr(
  //                             "Execution Analysis ", null, 15, Colors.red),
  //                         textInfoCtr("Execution count: ", numExec.toDouble(),
  //                             15, Colors.black),
  //                         textInfoCtr("Average Frame(per execution): ",
  //                             avgFrames, 15, Colors.black),
  //                       ],
  //                     ));
  //                 // translateCollectedDatatoTxt(coordinatesData);
  //                 print('pressing button');
  //               },
  //               child: Text('Done'),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
