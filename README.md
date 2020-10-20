# Triometter
Trying to get the position of an android phone in 3D space relative to another marked old position using his accelerometer and "rotation sensor".
I used Android Studio to make the app and Processing Java for the Desktop Receiver.

# Why ?
Because I was curious to see if it was possible (and this can have a lot of applications if worked), for example to help GPS on small distance.

# Disclaimer
That is an old project made for my [ISN](https://eduscol.education.fr/cid59678/presentation.html) class and exam in 2018/2019, the code is ugly and the target of this was just an experiment to see if it is possible and resulted as a failure to have a precise position (Proof of Concept failed), that was coded to see if it was possible fast, not to make a beautiful project. Be prepared to have blood flow out of your eyes.

# Test Result
Tested on Nokia 5 and Redmi Note 8 Pro.
This resulted as a failure because a small error on acceleration make a big error on the speed, resulting in a drift of the position, we can detect move and direction, but this lead rapidly to too much drift to see any moves.
In the idea for reducing the drift, we need to add another input to know at certain time if the phone is moving or not (like pictures taken from camera ?) or some artificial drift detection and reduction but idk what.

# Note
If you are interested but you don't know how to start and you have difficulties to use it contact me !

# Future improvments
I'll fully recode the app cleaner and add a fourirer transform to remove high frequencies (considered as noise) and probably change my method for the integration of the datas... more later
