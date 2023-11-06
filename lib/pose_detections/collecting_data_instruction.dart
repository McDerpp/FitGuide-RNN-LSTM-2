import 'package:flutter/material.dart';

import 'pose_detector_view.dart';
import 'package:frontend/pose_detections/customWidgetPDV.dart';
import 'package:google_fonts/google_fonts.dart';

class collectingDataInstructionPage extends StatelessWidget {
  const collectingDataInstructionPage({super.key});

  void nextPageFunc(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoseDetectorView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: RichText(
                          text: TextSpan(
                            text: "Collecting data",
                            style: GoogleFonts.lato(
                              fontSize: 35,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )),
                  instructionText(
                      FontWeight.w600, 18, 15, 5, Colors.red, "Overview :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "collecting of data is done by getting coordinates of the placements of certain parts of the body on the screen. Sets of these recorded coordinates are considered sequences and the use can think of it as like a frame by frame representation of your movements. All of these will be used in training the AI model for the exercise that the user is doing. "),
                  instructionText(FontWeight.w600, 18, 15, 5, Colors.red,
                      "Step 1 (Be in the screen) :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "The whole body must be present in the screen in order to start getting and produce a good data, otherwise it wont record anything. The user will know when the body is detected by seeing overlay of a skeleton."),
                  instructionText(FontWeight.w600, 18, 15, 5, Colors.red,
                      "Step 2 (Perform, do the exercise) :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "After step 1, the user can now proceed with doing the exercise. However, there are things that the user should take into consideration. A good and consistent pacing is required when executing the exercise, fast and inconsistent execution can create problems along the line. Number of executions is another thing, being able to perform more exercise can be beneficial."),
                  instructionText(FontWeight.w600, 18, 15, 5, Colors.red,
                      "Step 3 (Stop briefly, about less than a sec) :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "In between execution of the exercise, the user is required to stop for less than a sec. It is crucial to stop to let the app know that the user is done with one execution."),
                  instructionText(FontWeight.w600, 18, 15, 5, Colors.red,
                      "Step 4 (Repeat step 3 and 4) :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "Repeat the process until you have sufficient execution performed. Recommended number of execution is atleast 50 to be able to produce a decent model. More than 100 number of execution would yield a good model."),
                  instructionText(FontWeight.w600, 18, 15, 5, Colors.red,
                      "Step 5 (Submit!) :"),
                  instructionText(FontWeight.w400, 12, 25, 2, Colors.white,
                      "The user is now done with collecting data, now the user will have to fill in some data about the exercise recently performed. After everything, you can finally submit it and train it. Now, what's left to do is to wait for it, some time might be needed to train it, the user will get a notification as soon as the training is done."),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 80.0,
              ), // Adjust the value as needed
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      nextPageButton(
                        "Get started",
                        Colors.red,
                        nextPageFunc,
                        context,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
