# fitguidef
Frontend-->Flutter

Backend ---> Django

AI framework----> tensorflow/TFlite

Overview:
FitGuide is an exercise app that lets the user monitor the correctness of their desired exercise. This is done by providing users the capability, functionality and ease of use to upload necessary data and be able to train a model based on the exercise they performed with just a click. Which in turn can populate libraries of exercises that other users may be able to discover and use these exercises that have the capability of checking the correctness of the exercise that the user wishes to perform.The app leverages the capability of Recurrent Neural Network Long Short-Term Memory(RNN-LSTM) model to analyze skeleton-based coordinates for spatial pattern and also sequence pattern to enable this app to determine the correctness of the exercise.

Use Case Title: Performing exercise

Actor/s: User

Main Flow:

The user navigates through libraries of exercise programs, the user then chooses the exercise program that corresponds to certain parts of the body that the user desires to have impact.
First thing the user will be able to see are sets of exercises that belong to the chosen exercise program, the user can then choose what exercise he/she wants to perform first.
Before the user can actually perform the exercise, it promptly gives the user several information and instructions on what to do.

Instructions/informations:
Whole body must be seen by the camera before and during performing the exercise..
Room must have good lighting(bad lighting could result in inaccuracy).
Follow the specified position/angle of the body facing the camera.( This could vary across different kinds of exercises.)
In between instances of the exercise, the user must pause a bit, about 1 sec in order to be recorded as one.
The user will be presented with a frame by frame of how to perform the exercise and how much of it.

After being able to read the instructions, the user can now proceed with the exercise, the camera will open up with skeletal overlay. In this way the app will be able to detect the movement of the user. The app will show real time performance evaluation of the exercise in the overlay along with other information.

	Following overlay shown on the screen:
Skeletal overlay
A movement detection (if the user is moving or not)
Counter for exercise performed
Percentage of how the user performed the exercise correctly
Indicator of whether full body is within the screen, otherwise the app wont detect and do inference.

The user has to pause for a brief amount of time  in between exercises, about less than a second  in order to let the app know that the user is done performing one exercise. 
If the user performs any movement, the app records the skeletal coordinates as spatial data and sets of these as sequence data.
If the user stops moving, it inferences the data recorded in the model and outputs the result as percentage of the correctness of the performed exercise.
 if it reaches an acceptable threshold then the counter will go up. 
However in the event that the user is performing badly, the app would abruptly end and prompts the user to try again the whole set and advise to look at the sample exercise to be guided.
When the user performed the exercise at an acceptable rate, then it would be recorded in the profile and on the exercise program as done.
It will then exit and open up the exercise program page to let the user choose and perform other exercises in the exercise program.




Use Case Title: Perform and send coordinates

Actor/s: User

Main Flow:

The user can create his/her model by selecting the designated button in the main menu.
Before the user can start creating the model of the exercise he/she wants, a set of instructions are first presented to the user in how the procedure works and things to do.

Instructions/informations:
Whole body must be seen by the camera before and during performing the exercise.
Room must have good lighting(bad lighting could result in inaccuracy).
In between instances of the exercise, the user must pause a bit, about 1 sec in order to be recorded as one execution.
Exercise must be performed at a reasonable speed/pace to produce a better model.
The more exercise performed/recorded, the better the model it would result, but the minimum is at least 60 sets of the performed exercise.
The exercise being performed must have consistent pacing all throughout.

After being able to read the instructions, the user can now proceed with recording  coordinate data of the performed exercise, the camera will open up with skeletal overlay. In this way app will be able to detect the movement of the user
	
	Following overlay shown on the screen:
Skeletal overlay
A movement detection (if the user is moving or not)
Counter for exercise performed
Indicator of whether full body is within the screen, otherwise the app wont detect and will also not do any recording of data.

The user has to pause briefly in between exercises about less than a sec in order to let the app know that the user is done performing one exercise. 
If the user performs any movement, the app records the skeletal coordinates as spatial data and sets of these as sequence data.
If the user stops moving, the recorded data will be imputed in a txt file as one sequence.
This process goes on repeatedly until the user stops by pressing a button
The process stops when the user presses the button to end it.
After the process ends, the app will give an analysis review on the executed exercise.
Analysis review:
Average sequence of each exercise, this will determine whether the pacing and speed of the executions are acceptable.
Number of executions performed, this will determine if enough data are provided for training
Data criteria:
Average sequence:
Less than 4 is considered as insufficient sequence
5 - 10 sequence is considered as sufficient sequence
More than 10 sequence is considered a good amount of sequence
Number of executions performed, this will determine if enough data are provided for training.
Less than 50 exercise execution is considered as insufficient data
50 - 80 exercise execution is considered as sufficient data
More than 80 exercise execution is considered as a good amount of data

Note: 
These criteria may not be applicable in every scenario, it depends on the complexity of the exercise and its speed. However this is the basis that the researcher had come up with to be able to have good results most of the time.

For instance a push-up is considered to be a simple exercise since you just go up and down, therefore less sequence is needed, but the more sequence the better the model performs. On the other hand an exercise that would resemble closely to a dance with complicated movements would require more sequences to be able to know each part of the movement.

Another thing to consider is the amount of data that is collected which is the amount of execution collected. A push up is a simple exercise, with less probable outcome unlike an exercise with a bit more probable variety outcome, in this scenario push up would require less data and a dance-like exercise would require more data. To elaborate on this matter.let’s look at push up first, a push up is just up and down, this would only create less variety for each execution. While a dance-like exercise would require the user to perform more intricate movements which creates a variety of outcomes. The training of the model would have to capture all those varieties in order to have a more accurate and more forgiving inference 

The user will then be presented with the option of training a model using the data after considering whether the data collected is sufficient in relation to the exercise executed.
The user will also have to input certain information regarding the model and exercise..
	Information needed:
Name/title of the exercise
Position of your body when you performed this(front,side or back)
What part of the body does it have an impact on?




After inputting the necessary data, the user can now submit all the data collected together with the information needed for the exercise to the database.
The server will then get the data on the database for training. The server will output and give notification to the user of the situation of the model’s training, whether the accuracy of the model is good enough and whether it passed several tests.
In the event that the model’s training performed badly, then the model will not be saved. The app will prompt the user to try again.








Use Case Title: Customize exercise program

Actor/s: User

Main Flow:

The user can create and customize an exercise program that may cater to different users and it can be done by pressing the designated button on the main menu.
The user specifies numerous information and a brief description about the exercise program.
Information needed:
Name of exercise program
Brief description
Duration?
Schedule?
Etc
The user can now choose what exercise should be included in the exercise program by selecting from a library of exercises that are made by the user himself/herself or other users.
The user would need to input some information for individual exercises.
Information needed for individual exercise:
Amount of executions for the exercise
Etc?
Optional information for individual exercise:
Brief description/instructions

After adding the exercise with their respective information, the user can finish creating the exercise program by pressing the designated button.


