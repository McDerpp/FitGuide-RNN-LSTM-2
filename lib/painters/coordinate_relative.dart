// // remember to use callbacks instead

// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// List<double> coordinates_relative_box(List<Pose> rawCoordiantes) {
//   print("coordinates_relative_box");
//   late List<double> translated_coordinates;
//   translated_coordinates = [];

//   double min_coordinates_x = rawCoordiantes.first.landmarks.values.first.x;
//   double min_coordinates_y = rawCoordiantes.first.landmarks.values.first.y;

//   double max_coordinates_x = rawCoordiantes.first.landmarks.values.first.x;
//   double max_coordinates_y = rawCoordiantes.first.landmarks.values.first.y;

//   var value_x_range;
//   var value_y_range;

//   var raw_x;
//   var raw_y;

//   for (var poseList in rawCoordiantes) {
//     for (var pose in poseList.landmarks.values) {
//       if (min_coordinates_x >= pose.x) {
//         min_coordinates_x = pose.x;
//       }
//       if (min_coordinates_x >= pose.y) {
//         min_coordinates_x = pose.y;
//       }

//       if (max_coordinates_x <= pose.x) {
//         max_coordinates_x = pose.x;
//       }
//       if (max_coordinates_x <= pose.y) {
//         max_coordinates_x = pose.y;
//       }
//     }
//   print("min_coordinates_x-> $min_coordinates_x");
//   print("min_coordinates_y $min_coordinates_y");
//   print("max_coordinates_x $max_coordinates_x");
//   print("max_coordinates_y $max_coordinates_y");

//     for (var pose in poseList.landmarks.values) {
//       value_x_range = (pose.x - min_coordinates_x) / (max_coordinates_x - min_coordinates_x);
//       value_y_range = (pose.y - min_coordinates_y) / (max_coordinates_y - min_coordinates_y);
//       print(
//           "value_x_range-->$value_x_range value_y_range-->$value_y_range --------------------------------------------()");
//       // flattening it ahead of time for later processes later...
//       translated_coordinates.add(value_x_range);
//       translated_coordinates.add(value_y_range);
//     }
//   }

//   return translated_coordinates;
// }
