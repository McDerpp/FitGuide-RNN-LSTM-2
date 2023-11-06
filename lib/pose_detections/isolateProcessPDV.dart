
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

// Future<bool> inferencing(List<List<double>> coordinates) async {
//   bool isCorrect = false;
//   double output = 0;

//   try {
//     final head = await tfl.Interpreter.fromAsset(
//         'assets\models\wholeModel\otestingtesting(loss_0.063)(acc_0.982).tflite');
//     head.run(coordinates, output);
//   } catch (error) {
//     print("inferencing initializing error! -> $error");
//   }

//   return isCorrect;
// }

List<double> coordinatesRelativeBoxIsolate(Map<String, dynamic> inputs) {
  var rootIsolateToken = inputs['token'];
  Iterable<PoseLandmark> rawCoordiantes = inputs['inputImage'];
  // print("coordinatesRelativeBox ---> ${rawCoordiantes.first.x}");

  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  List<double> translatedCoordinates = [];
  double allowance = .03;

  double minCoordinatesX = rawCoordiantes.first.x;
  double minCoordinatesY = rawCoordiantes.first.y;

  double maxCoordinatesX = rawCoordiantes.first.x;
  double maxCoordinatesY = rawCoordiantes.first.y;

  var valueXRange;
  var valueYRange;

  var rawX;
  var rawY;

  for (var pose in rawCoordiantes) {
    if (minCoordinatesX >= pose.x) {
      minCoordinatesX = pose.x;
    }
    if (minCoordinatesY >= pose.y) {
      minCoordinatesY = pose.y;
    }

    if (maxCoordinatesX <= pose.x) {
      maxCoordinatesX = pose.x;
    }
    if (maxCoordinatesY <= pose.y) {
      maxCoordinatesY = pose.y;
    }
  }

  for (var pose in rawCoordiantes) {
    valueXRange =
        (pose.x - minCoordinatesX) / (maxCoordinatesX - minCoordinatesX);
    valueYRange =
        (pose.y - minCoordinatesY) / (maxCoordinatesY - minCoordinatesY);

    // flattening it ahead of time for later processes later...
    translatedCoordinates.add(valueXRange);
    translatedCoordinates.add(valueYRange);
  }

  return translatedCoordinates;
}

bool checkMovement(Map<String, dynamic> input) {
  var prevCoordinates = input['prevCoordinates'];
  var currentCoordinates = input['currentCoordinates'];
  var token = input['token'];

  bool noMovement = false;
  double changeRange = 0.07;
  int noMovementCtr = 0;

  for (int ctr = 0; ctr < prevCoordinates.length; ctr++) {
    if (prevCoordinates.elementAt(ctr) - changeRange <=
            currentCoordinates.elementAt(ctr) &&
        prevCoordinates.elementAt(ctr) + changeRange >=
            currentCoordinates.elementAt(ctr)) {
      noMovementCtr++;
      // print("checking(not moving) - $ctr");
    } else {
      // print(
      //     "===========================[YOU MOOOOOVED!]======================================");
      return false;
    }
  }
  // print(
  //     "======================================================================================");

  // print("noMovementCtr --> $noMovementCtr");
  if (noMovementCtr >= 65) {
    return true;
  } else {
    return false;
  }
}
