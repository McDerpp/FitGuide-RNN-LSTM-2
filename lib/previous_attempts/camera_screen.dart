// // import 'dart:convert';

// // import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// // import 'package:flutter/material.dart';

// // import 'package:image/image.dart' as img;
// // import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:flutter/services.dart';
// // import 'package:frontend/ML_kit.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// final options = PoseDetectorOptions(
//     model: PoseDetectionModel.base, mode: PoseDetectionMode.stream);

// // final options = PoseDetectorOptions();
// final poseDetector = PoseDetector(options: options);

// late Socket socket;
// String serverResponse = "";
// Uint8List yuv420Data = Uint8List(0);
// Uint8List receivedData = Uint8List(0);

// // this is just for initializing for the details needed....this is initialize again inside the class for the actual usage
// // late CameraDescription camera;
// // CameraController _controller = CameraController(
// //   camera,
// //   ResolutionPreset.high,
// //   enableAudio: false,
// //   imageFormatGroup: Platform.isAndroid
// //       ? ImageFormatGroup.nv21 // for Android
// //       : ImageFormatGroup.bgra8888, // for iOS
// // );

// InputImage? _inputImageFromCameraImage(Map<String, dynamic> inputs) {
//   print("processing input image");
//   var raw = inputs['raw'];
//   var length = inputs['length'];
//   var first = inputs['first'];
//   var width = inputs['width'];
//   var height = inputs['height'];
//   var controller = inputs['controller'];
//   var lensDirection = inputs['lensDirection'];
//   var sensorOrientationdata = inputs['sensorOrientationdata'];

//   print("=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=");
//   // print("bytes -> ${first.bytes}");

//   print('raw-> ${inputs['raw']}');
//   print('length-> ${inputs['length']}');
//   print('first-> ${inputs['first']}');
//   print('width-> ${inputs['width']}');
//   print('height-> ${inputs['height']}');
//   print('controller-> ${inputs['controller']}');
//   print('lensDirection-> ${inputs['lensDirection']}');
//   print('sensorOrientationdata-> ${inputs['sensorOrientationdata']}');

//   print("=+=+=+=+=+=+=++=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=");

//   final _orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     // DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.portraitDown: 360,
//     DeviceOrientation.landscapeRight: 270,
//   };

//   print("processing input image1");

//   // final Map<String, dynamic> data = {
//   //   'raw': image.format.raw,
//   //   'length': image.planes.length,
//   //   'first': image.planes.first,
//   //   'width': image.width.toDouble(),
//   //   'height': widget.camera,
//   //   'controller': _controller.value.deviceOrientation,
//   //   'camera': widget.camera.lensDirection,
//   // };

//   // CameraImage image = inputs['image'];
//   // CameraController _controller = inputs['controller'];
//   // CameraDescription camera = inputs['camera'];
//   // late CameraController _controller;

//   // final cameras = await availableCameras();
//   // final camera = cameras.first;

// // make sure the configuration is the same on the actual one that is being used below
//   // _controller = CameraController(
//   //   camera,
//   //   ResolutionPreset.high,
//   //   enableAudio: false,
//   //   imageFormatGroup: Platform.isAndroid
//   //       ? ImageFormatGroup.nv21 // for Android
//   //       : ImageFormatGroup.bgra8888, // for iOS
//   // );

//   // get image rotation
//   // it is used in android to convert the InputImage from Dart to Java
//   // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
//   // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
//   // final camera = _camera[_cameraIndex];

// // !!!!!!!!!!!!!!!!!!!!!!!-------THIS IS THE PROBLEM---------!!!!!
//   final sensorOrientation = sensorOrientationdata;
//   print("processing input image2");

//   InputImageRotation? rotation;
//   if (Platform.isIOS) {
//     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//   } else if (Platform.isAndroid) {
//     var rotationCompensation = _orientations[controller];
//     print("_orientations[controller] $_orientations[controller]");
//     if (rotationCompensation == null) return null;
//     if (lensDirection == CameraLensDirection.front) {
//       // front-facing
//       rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//     } else {
//       // back-facing
//       print("processing input image3");

//       rotationCompensation =
//           // (sensorOrientation - rotationCompensation + 360) % 360;   this is the original
//           (sensorOrientation - rotationCompensation + 360*2) % 360;

//       print("rotationCompensation-> $rotationCompensation");
//     }
//     rotation = InputImageRotationValue.fromRawValue(rotationCompensation!);
//   }
//   if (rotation == null) return null;

//   // get image format
//   final format = InputImageFormatValue.fromRawValue(raw);
//   print("processing input image4");

//   // validate format depending on platform
//   // only supported formats:
//   // * nv21 for Android
//   // * bgra8888 for iOS
//   if (format == null ||
//       (Platform.isAndroid && format != InputImageFormat.nv21) ||
//       (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

//   // since format is constraint to nv21 or bgra8888, both only have one plane
//   if (length != 1) return null;
//   final plane = first;
//   print("processing input image5");

//   // compose InputImage using bytes
//   return InputImage.fromBytes(
//     bytes: plane.bytes,
//     metadata: InputImageMetadata(
//       size: Size(width, height),
//       rotation: rotation, // used only in Android
//       format: format, // used only in iOS
//       bytesPerRow: plane.bytesPerRow, // used only in iOS
//     ),
//   );
// }

// Future<Map<String, dynamic>> poseEstimationProcess(
//     Map<String, dynamic> inputs) async {
//   var rootIsolateToken = inputs['token'];

//   BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
//   print("ISOLATE!");
//   final inputImage = _inputImageFromCameraImage(inputs);
//   final List<Pose> poses = await poseDetector.processImage(inputImage!);
//   List<double> poseCoordinates = [];
//   Map<String, dynamic> data = {};

//   for (Pose pose in poses) {
//     // to access all landmarks
//     print("posesssssss -> $pose");
//     print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
//     pose.landmarks.forEach((_, landmark) {
//       final type = landmark.type;
//       final x = landmark.x;
//       final y = landmark.y;
//       print(type);
//     });
//     print("ISOLATE2!");

//     // to access specific landmarks
//     final landmarkAnkleLeft = pose.landmarks[PoseLandmarkType.leftAnkle];
//     final landmarkAnkleRight = pose.landmarks[PoseLandmarkType.rightAnkle];

//     final landmarkKneeLeft = pose.landmarks[PoseLandmarkType.leftKnee];
//     final landmarkKneeRight = pose.landmarks[PoseLandmarkType.rightKnee];

//     final landmarkHipLeft = pose.landmarks[PoseLandmarkType.leftHip];
//     final landmarkHipRight = pose.landmarks[PoseLandmarkType.rightHip];

//     final landmarkShoulderLeft = pose.landmarks[PoseLandmarkType.leftShoulder];
//     final landmarkShoulderRight =
//         pose.landmarks[PoseLandmarkType.rightShoulder];

//     final landmarkElbowLeft = pose.landmarks[PoseLandmarkType.leftElbow];
//     final landmarkElbowRight = pose.landmarks[PoseLandmarkType.rightElbow];

//     final landmarkWristLeft = pose.landmarks[PoseLandmarkType.leftWrist];
//     final landmarkWristRight = pose.landmarks[PoseLandmarkType.rightWrist];

//     print(
//         "======================================(landmarkWristRight)=================================================");
//     print("right wrist x -> ${landmarkWristRight?.x}");
//     print("right wrist y -> ${landmarkWristRight?.y}");
//     print(
//         "======================================(landmarkAnkleLeft)=================================================");
//     print(landmarkAnkleLeft?.x);
//     print(landmarkAnkleLeft?.y);

//     // final Map<String, dynamic> data = {
//     //   'landmarkAnkleLeft': pose.landmarks[PoseLandmarkType.leftAnkle],
//     //   'landmarkAnkleRight': pose.landmarks[PoseLandmarkType.rightAnkle],
//     //   'landmarkKneeLeft': pose.landmarks[PoseLandmarkType.leftKnee],
//     //   'landmarkKneeRight': pose.landmarks[PoseLandmarkType.rightKnee],
//     //   'landmarkHipLeft': pose.landmarks[PoseLandmarkType.leftHip],
//     //   'landmarkHipRight': pose.landmarks[PoseLandmarkType.rightHip],
//     //   'landmarkShoulderLeft': pose.landmarks[PoseLandmarkType.leftShoulder],
//     //   'landmarkShoulderRight': pose.landmarks[PoseLandmarkType.rightShoulder],
//     //   'landmarkElbowLeft': pose.landmarks[PoseLandmarkType.leftElbow],
//     //   'landmarkElbowRight': pose.landmarks[PoseLandmarkType.rightElbow],
//     //   'landmarkWristLeft': pose.landmarks[PoseLandmarkType.leftWrist],
//     //   'landmarkWristRight': pose.landmarks[PoseLandmarkType.rightWrist],
//     // };

//     data['landmarkAnkleLeft_x'] = pose.landmarks[PoseLandmarkType.leftAnkle]?.x;
//     data['landmarkAnkleLeft_y'] = pose.landmarks[PoseLandmarkType.leftAnkle]?.y;

//     data['landmarkAnkleRight_x'] =
//         pose.landmarks[PoseLandmarkType.rightAnkle]?.x;
//     data['landmarkAnkleRight_y'] =
//         pose.landmarks[PoseLandmarkType.rightAnkle]?.y;

//     data['landmarkKneeLeft_x'] = pose.landmarks[PoseLandmarkType.leftKnee]?.x;
//     data['landmarkKneeLeft_y'] = pose.landmarks[PoseLandmarkType.leftKnee]?.y;

//     data['landmarkKneeRight_x'] = pose.landmarks[PoseLandmarkType.rightKnee]?.x;
//     data['landmarkKneeRight_y'] = pose.landmarks[PoseLandmarkType.rightKnee]?.y;

//     data['landmarkHipLeft_x'] = pose.landmarks[PoseLandmarkType.leftHip]?.x;
//     data['landmarkHipLeft_y'] = pose.landmarks[PoseLandmarkType.leftHip]?.y;

//     data['landmarkHipRight_x'] = pose.landmarks[PoseLandmarkType.rightHip]?.x;
//     data['landmarkHipRight_y'] = pose.landmarks[PoseLandmarkType.rightHip]?.y;

//     data['landmarkShoulderLeft_x'] =
//         pose.landmarks[PoseLandmarkType.leftShoulder]?.x;
//     data['landmarkShoulderLeft_y'] =
//         pose.landmarks[PoseLandmarkType.leftShoulder]?.y;

//     data['landmarkShoulderRight_x'] =
//         pose.landmarks[PoseLandmarkType.rightShoulder]?.x;
//     data['landmarkShoulderRight_y'] =
//         pose.landmarks[PoseLandmarkType.rightShoulder]?.y;

//     data['landmarkElbowLeft_x'] = pose.landmarks[PoseLandmarkType.leftElbow]?.x;
//     data['landmarkElbowLeft_y'] = pose.landmarks[PoseLandmarkType.leftElbow]?.y;

//     data['landmarkElbowRight_x'] =
//         pose.landmarks[PoseLandmarkType.rightElbow]?.x;
//     data['landmarkElbowRight_y'] =
//         pose.landmarks[PoseLandmarkType.rightElbow]?.y;

//     data['landmarkWristLeft_x'] = pose.landmarks[PoseLandmarkType.leftWrist]?.x;
//     data['landmarkWristLeft_y'] = pose.landmarks[PoseLandmarkType.leftWrist]?.y;

//     data['landmarkWristRight_x'] =
//         pose.landmarks[PoseLandmarkType.rightWrist]?.x;
//     data['landmarkWristRight_y'] =
//         pose.landmarks[PoseLandmarkType.rightWrist]?.y;

//     var testtestsetse = data['landmarkWristRight'];
//     data['allPose'] = poses;

//     print("isolate print wrist x -> ${data['landmarkWristRight_x']}");
//     print("isolate print wrist x -> ${data['landmarkWristRight_y']}");
//   }

//   print("DONE!");
//   print("poses25345 -> ${data['allPose']}");
//   print("poses25345type -> ${data['allPose'].runtimeType}");

//   return data;
// }

// // // ==============================================================================================================================================================================================

// // isolate---------------------------------------------------------------------------

// class DrawingPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 5.0;

//     final paint2 = Paint()
//       ..color = Colors.red
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 5.0;

//     final paint3 = Paint()
//       ..color = Colors.yellow
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 5.0;

//     final startPoint = Offset(-50.0, -50.0);
//     final endPoint = Offset(250.0, 250.0);

//     final startPoint2 = Offset(50.0, 50.0);
//     final endPoint2 = Offset(250.0, 250.0);

//     final startPoint3 = Offset(0, 0);
//     final endPoint3 = Offset(10, 10);

//     canvas.drawLine(startPoint, endPoint, paint);
//     canvas.drawLine(startPoint2, endPoint2, paint2);
//     canvas.drawLine(startPoint3, endPoint3, paint3);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class PosePainter extends CustomPainter {
//   PosePainter({
//     required this.pose,
//     required this.imageSize,
//   });

//   late Pose pose;
//   // late Size imageSize;
//   late Size imageSize = Size(0, 0);

//   final circlePaint = Paint()..color = const Color.fromRGBO(0, 255, 0, 0.8);
//   final linePaint = Paint()
//     ..color = const Color.fromRGBO(255, 0, 0, 0.8)
//     ..strokeWidth = 2;

//   @override
//   void paint(Canvas canvas, Size size) {
//     print("INSIDE THE POSEPAINTER");

//     print("number of pose check");
//     // print("POSE_POSE-> ${pose.landmarks}");
//     pose.landmarks.forEach((_, landmark) {
//       final type = landmark.type;
//       final x = landmark.x;
//       final y = landmark.y;
//       print("type inside -> $type  x->$x   x->$y");
//     });

//     final double hRatio =
//         imageSize.width == 0 ? 1 : size.width / imageSize.width;
//     final double vRatio =
//         imageSize.height == 0 ? 1 : size.height / imageSize.height;

//     Offset offsetForPart(PoseLandmark part) {
//       return Offset(part.x * hRatio, part.y * vRatio);
//     }

//     for (final part in pose.landmarks.values) {
//       // Draw a circular indicator for the landmark.
//       canvas.drawCircle(offsetForPart(part), 5, circlePaint);

//       // Draw text label for the landmark.
//       TextSpan span = TextSpan(
//         text: part.type.toString().substring(16),
//         style: const TextStyle(
//           color: Color.fromRGBO(0, 128, 255, 1),
//           fontSize: 10,
//         ),
//       );
//       TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left);
//       tp.textDirection = TextDirection.ltr;
//       tp.layout();
//       tp.paint(canvas, offsetForPart(part));
//     }

//     // Draw connections between the landmarks.
//     final landmarksByType = {
//       for (final it in pose.landmarks.values) it.type: it
//     };
//     // for (final connection in connections) {
//     //   final point1 = offsetForPart(landmarksByType[connection[0]]!);
//     //   final point2 = offsetForPart(landmarksByType[connection[1]]!);
//     //   canvas.drawLine(point1, point2, linePaint);
//     // }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

// class CameraScreen extends StatefulWidget {
//   final CameraDescription camera;
//   const CameraScreen({Key? key, required this.camera}) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late List<Pose> _detectedPose;
//   late Size imageSize;

//   // void connectToServer() async {
//   //   try {
//   //     socket = await Socket.connect('10.0.2.2', 1234);
//   //   } catch (e) {
//   //     print("Error: $e");
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     // connectToServer();

//     int ctr = 0;
//     int ctrSend = 0;
//     // _detectedPose = Pose(landmarks: {});
//     _detectedPose = <Pose>[];
//     imageSize = const Size(250, 125);

//     print("INSIDE!!!!!!!!");
//     // late final camera; // your camera instance
//     // _controller = CameraController(
//     //   widget.camera,
//     //   ResolutionPreset.medium,
//     //   enableAudio: false,
//     // );

// // this is the 2nd initialization for the actual usage this time...
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//       // ResolutionPreset.high,

//       enableAudio: false,
//       imageFormatGroup: Platform.isAndroid
//           ? ImageFormatGroup.nv21 // for Android
//           : ImageFormatGroup.bgra8888, // for iOS
//     );

//     // MLkit
//     // final _orientations = {
//     //   DeviceOrientation.portraitUp: 0,
//     //   DeviceOrientation.landscapeLeft: 90,
//     //   DeviceOrientation.portraitDown: 180,
//     //   DeviceOrientation.landscapeRight: 270,
//     // };

//     // _openSocketConnection();
//     _controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

//       _controller.startImageStream((CameraImage image) async {
//         final Map<String, dynamic> data = {
//           'raw': image.format.raw,
//           'length': image.planes.length,
//           'first': image.planes.first,
//           'width': image.width.toDouble(),
//           'height': image.height.toDouble(),
//           'controller': _controller.value.deviceOrientation,
//           'lensDirection': widget.camera.lensDirection,
//           'sensorOrientationdata': widget.camera.sensorOrientation,
//           'token': rootIsolateToken,
//         };
//         print("previewSize -> ${_controller.value.previewSize}");

//         Map<String, dynamic> poseCoordinatesResults =
//             await compute(poseEstimationProcess, data);
        
//         print("going in");
//         if (poseCoordinatesResults['allPose'] != null) {
//           print("its NOT a null");

//           print("end of poseCoordinatesResults");

//           // _detectedPose = poseCoordinatesResults['allPose'];
//         } else {
//           print("its a null");

//           _detectedPose = <Pose>[];
//         }
//         print("going in 1");

//         print("_detectedPose_123123 -> $_detectedPose");
//         print("going in 3");

//         imageSize = _controller.value.previewSize!;
//         print("going in 4");

//         print("imageSize_123123 -> $imageSize");
//         // print("imageSize_1543 -> $_controller.value.previewSize");

//         print("going in 5");

//         // data['landmarkAnkleLeft'] = pose.landmarks[PoseLandmarkType.leftAnkle];
//         // data['landmarkAnkleRight'] = pose.landmarks[PoseLandmarkType.rightAnkle];
//         // data['landmarkKneeLeft'] = pose.landmarks[PoseLandmarkType.leftKnee];
//         // data['landmarkKneeRight'] = pose.landmarks[PoseLandmarkType.rightKnee];
//         // data['landmarkHipLeft'] = pose.landmarks[PoseLandmarkType.leftHip];
//         // data['landmarkHipRight'] = pose.landmarks[PoseLandmarkType.rightHip];
//         // data['landmarkShoulderLeft'] =
//         //     pose.landmarks[PoseLandmarkType.leftShoulder];
//         // data['landmarkShoulderRight'] =
//         //     pose.landmarks[PoseLandmarkType.rightShoulder];
//         // data['landmarkElbowLeft'] = pose.landmarks[PoseLandmarkType.leftElbow];
//         // data['landmarkElbowRight'] = pose.landmarks[PoseLandmarkType.rightElbow];
//         // data['landmarkWristLeft'] = pose.landmarks[PoseLandmarkType.leftWrist];
//         // data['landmarkWristRight'] = pose.landmarks[PoseLandmarkType.rightWrist];

//         ctr = ctr + 1;
//         print(ctr);

//         // if (ctr == 10) {
//         //   ctr = 0;
//         //   ctrSend = ctrSend + 1;
//         //   print("ctrSend-> $ctrSend");

//         // Uint8List receivedData = Uint8List(0);

//         // socket.write(resultIsolate);
//         // print("@#######!#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#!@#");

//         // print("raw-> ${image.format.raw}");
//         // print("group-> ${image.format.group}");
//         // print("width-> ${image.width}");
//         // print("height-> ${image.height}");
//         // print("planes1-> ${image.planes.elementAt(0).bytes.length}");
//         // print("planes2-> ${image.planes.elementAt(1).bytes.length}");
//         // print("planes3-> ${image.planes.elementAt(2).bytes.length}");

//         // socket.write(image.planes.elementAt(0).bytes.sublist(0, (image.planes.elementAt(0).bytes.length * 0.20).toInt()));
//         // socket.write(image.planes.elementAt(0).bytes.sublist((image.planes.elementAt(0).bytes.length * 0.20).toInt(), (image.planes.elementAt(0).bytes.length * 0.40).toInt()));
//         // socket.write(image.planes.elementAt(0).bytes.sublist((image.planes.elementAt(0).bytes.length * 0.40).toInt(), (image.planes.elementAt(0).bytes.length * 0.60).toInt()));
//         // socket.write(image.planes.elementAt(0).bytes.sublist((image.planes.elementAt(0).bytes.length * 0.60).toInt(), (image.planes.elementAt(0).bytes.length * 0.80).toInt()));
//         // socket.write(image.planes.elementAt(0).bytes.sublist((image.planes.elementAt(0).bytes.length * 0.80).toInt(), (image.planes.elementAt(0).bytes.length).toInt()));

//         // socket.write(image.planes.elementAt(1).bytes.sublist(0, (image.planes.elementAt(1).bytes.length * 0.20).toInt()));
//         // socket.write(image.planes.elementAt(1).bytes.sublist((image.planes.elementAt(1).bytes.length * 0.20).toInt(), (image.planes.elementAt(1).bytes.length * 0.40).toInt()));
//         // socket.write(image.planes.elementAt(1).bytes.sublist((image.planes.elementAt(1).bytes.length * 0.40).toInt(), (image.planes.elementAt(1).bytes.length * 0.60).toInt()));
//         // socket.write(image.planes.elementAt(1).bytes.sublist((image.planes.elementAt(1).bytes.length * 0.60).toInt(), (image.planes.elementAt(1).bytes.length * 0.80).toInt()));
//         // socket.write(image.planes.elementAt(1).bytes.sublist((image.planes.elementAt(1).bytes.length * 0.80).toInt(), (image.planes.elementAt(1).bytes.length).toInt()));

//         // socket.write(image.planes.elementAt(2).bytes.sublist(0, (image.planes.elementAt(2).bytes.length * 0.20).toInt()));
//         // socket.write(image.planes.elementAt(2).bytes.sublist((image.planes.elementAt(2).bytes.length * 0.20).toInt(), (image.planes.elementAt(2).bytes.length * 0.40).toInt()));
//         // socket.write(image.planes.elementAt(2).bytes.sublist((image.planes.elementAt(2).bytes.length * 0.40).toInt(), (image.planes.elementAt(2).bytes.length * 0.60).toInt()));
//         // socket.write(image.planes.elementAt(2).bytes.sublist((image.planes.elementAt(2).bytes.length * 0.60).toInt(), (image.planes.elementAt(2).bytes.length * 0.80).toInt()));
//         // socket.write(image.planes.elementAt(2).bytes.sublist((image.planes.elementAt(2).bytes.length * 0.80).toInt(), (image.planes.elementAt(2).bytes.length).toInt()));

//         // socket.write(image.planes.elementAt(1).bytes);
//         // socket.write(image.planes.elementAt(2).bytes);

//         // Uint8List resultIsolate = await compute(sendToSocket, image);
//         // socket.write("@");
//         // socket.write(resultIsolate);
//         // socket.write("#");

//         // print('------------------------------------------------------');
//         // // print("length ------> ${resultIsolate.length}");

//         // print(receivedData);
//         // }

//         setState(() {
//           _detectedPose = poseCoordinatesResults['allPose'];

//           // Update the UI with the processed image
//         });
//       });
//     });
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   print("_detectedPose123 ->$_detectedPose");
//   //   if (!_controller.value.isInitialized) {
//   //     return Container();
//   //   }
//   //   return AspectRatio(
//   //     aspectRatio: _controller.value.aspectRatio,
//   //     child: Stack(
//   //       children: [
//   //         CameraPreview(_controller),
//   //         CustomPaint(
//   //           painter: DrawingPainter(), // Provide your custom painter here
//   //           size: Size(300, 300), // Set the size of the CustomPaint widget
//   //         ),
//   //         Positioned(
//   //           top: 16, // Adjust the top position as needed
//   //           left: 16, // Adjust the left position as needed
//   //           child: Column(
//   //             children: [
//   //               Text(
//   //                 'Testing',
//   //                 style: TextStyle(
//   //                   color: Colors.white,
//   //                   fontSize: 20,
//   //                   fontWeight: FontWeight.bold,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     print("INSIDE!!!!!!!!!!!!!!!");
//     print("imageSize->  $imageSize");
//     print("_detectedPose->  $_detectedPose");
//     print("_detectedPoselen->  ${_detectedPose.length}");

//     // Use ClipRect so that custom painter doesn't draw outside of the widget area.
//     return ClipRect(
//       child: CustomPaint(
//         foregroundPainter: PosePainter(
//           pose: _detectedPose.first,
//           imageSize: imageSize,
//         ),
//         child: CameraPreview(_controller),
//       ),
//     );
//   }
// }
