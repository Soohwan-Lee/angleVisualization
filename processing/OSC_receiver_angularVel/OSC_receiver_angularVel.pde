import netP5.*;
import oscP5.*;

OscP5 oscar;

// Variables to store previous values
float prevYaw = 0;
float prevPitch = 0;
float prevRoll = 0;

// Variables to store current values
float currYaw = 0;
float currPitch = 0;
float currRoll = 0;

// Variables to store angular velocities
float yawVelocity = 0;
float pitchVelocity = 0;
float rollVelocity = 0;

// Variable to store previous time
int prevTime;
int currTime;
int deltaTime_threshold = 0;
int deltaTime = 0;

void setup() {
  size(400, 400);  // You can set the size of your window here if needed
  oscar = new OscP5(this, 6000);
  oscar.plug(this, "yaw", "/yaw");
  oscar.plug(this, "pitch", "/pitch");
  oscar.plug(this, "roll", "/roll");

  prevTime = millis();
}

void draw() {
  // No drawing code needed for now
  currTime = millis();
  deltaTime = (currTime - prevTime);  // Convert milliseconds to seconds
}

void yaw(float yaw) {
  //int currTime = millis();
  currYaw = yaw;
  //float deltaTime = (currTime - prevTime) / 1000.0;  // Convert milliseconds to seconds
  //int deltaTime = (currTime - prevTime) / 1000;  // Convert milliseconds to seconds


  if (deltaTime > deltaTime_threshold) {
    yawVelocity = abs((currYaw - prevYaw) / deltaTime * 1000);
    prevYaw = currYaw;
    prevTime = currTime;
    println("yaw: " + yaw + " | angular velocity: " + yawVelocity);
  }
}

void pitch(float pitch) {
  //int currTime = millis();
  currPitch = pitch;
  //float deltaTime = (currTime - prevTime) / 1000.0;  // Convert milliseconds to seconds
  //int deltaTime = (currTime - prevTime) / 1000;  // Convert milliseconds to seconds


  if (deltaTime > deltaTime_threshold) {
    pitchVelocity = abs((currPitch - prevPitch) / deltaTime * 1000);
    prevPitch = currPitch;
    prevTime = currTime;
    println("pitch: " + pitch + " | angular velocity: " + pitchVelocity);
  }
}

void roll(float roll) {
  //int currTime = millis();
  currRoll = roll;
  //float deltaTime = (currTime - prevTime) / 1000.0;  // Convert milliseconds to seconds
  //int deltaTime = (currTime - prevTime) / 1000;  // Convert milliseconds to seconds

  if (deltaTime > deltaTime_threshold) {
    rollVelocity = abs((currRoll - prevRoll) / deltaTime * 1000);
    prevRoll = currRoll;
    prevTime = currTime;
    println("roll: " + roll + " | angular velocity: " + rollVelocity);
  }
}
