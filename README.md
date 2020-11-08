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
I'll fully recode the app cleaner and add a Fourier transform to remove/reduce high frequencies (considered as noise) and probably change my method for the integration of the data. I'll probably be using an interpolated polynomial based on a bunch of points (I need to check if it's easy to remove points using the Newton method) to have a smoother description of the movement (even if there is the same precision at the beginning, and even worse due to the suppression of the high frequencies, I'll try to have a better integration of the movement with this method).
After a fourier transformation, the signal can be also easily integrated or derived so i don't need a polynomial interpolation perhaps.
Finaly i think that the method above should be associated with somethng to detect when the device isn't moving (and not on a constant speed) for removing/reducing drift when the device is stopped. For that i think that detecting the acceleration pattern of voluntary movement can be useful (with that we'll be only integrating parts of the signal corresponding to a movment and reseting the speed to 0 after)
