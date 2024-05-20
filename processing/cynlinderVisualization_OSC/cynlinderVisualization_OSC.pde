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

float tiltX = 0; // Tilt around the X-axis (forward and backward)
float tiltY = 0; // Tilt around the Y-axis (side to side)

void setup() {
  size(640, 360, P3D); // Set up the 3D rendering context
  noStroke(); // No outlines for shapes
  oscar = new OscP5(this, 6000);
  oscar.plug(this, "yaw", "/yaw");
  oscar.plug(this, "pitch", "/pitch");
  oscar.plug(this, "roll", "/roll");

  prevTime = millis();
}

void draw() {
  currTime = millis();
  deltaTime = (currTime - prevTime);  // Convert milliseconds to seconds
  
  background(255); // Set background to white

  // Adjust the camera to better view the cylinder
  translate(width / 2, height * 3 / 4, 0);
  // Optional: Adjust the scene for better visualization
  // This initial rotation is removed to simplify understanding of tilt directions

  // Update tilt based on mouse position for demonstration
  // In a real scenario, replace these with data from your sensors
  // TiltX is now based on mouseY for forward/backward tilt
  // TiltY is now based on mouseX for side to side tilt
  tiltX = map(currPitch, -90, 90, -PI/2, PI / 2); // Allows full vertical movement range
  tiltY = map(currRoll, -180, 180, PI, -PI); // Allows full horizontal movement range
  
  float red = map(pitchVelocity, 0, 150, 0, 255);
  float blue = map(rollVelocity, 0, 150, 0, 255);
  //println("tiltX: " + str(tiltX));
  //println("tiltY: " + str(tiltY));

  // Apply the tilt to the cylinder
  // First apply tiltY for side to side movement
  rotateY(tiltY);
  // Then apply tiltX for forward/backward movement
  rotateX(tiltX);

  // Draw the cylinder
  fill(int(red), 10, int(blue)); // Set cylinder color
  stroke(0, 0, 0, 30); // Set cylinder stroke color
  pushMatrix();
  // The cylinder is translated along the Z-axis to ensure it rotates around its base
  translate(0, 0, -100); // Adjust if necessary to position the cylinder correctly
  cylinder(30, 100); // Draw cylinder with radius 50 and height 200
  popMatrix();
}

// Custom function to draw a cylinder remains unchanged
void cylinder(float r, float h) {
  float angle;
  float[] x = new float[361];
  float[] y = new float[361];

  for (int i = 0; i < x.length; i++) {
    angle = radians(i);
    x[i] = r * cos(angle);
    y[i] = r * sin(angle);
  }

  beginShape(TRIANGLE_FAN);
  vertex(0, 0, -h / 2);
  for (int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], -h / 2);
  }
  endShape();

  beginShape(TRIANGLE_FAN);
  vertex(0, 0, h / 2);
  for (int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], h / 2);
  }
  endShape();

  beginShape(QUAD_STRIP);
  for (int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], -h / 2);
    vertex(x[i], y[i], h / 2);
  }
  endShape();
}

//void yaw(float yaw) {
//  //int currTime = millis();
//  currYaw = yaw;
//  //float deltaTime = (currTime - prevTime) / 1000.0;  // Convert milliseconds to seconds
//  //int deltaTime = (currTime - prevTime) / 1000;  // Convert milliseconds to seconds


//  if (deltaTime > deltaTime_threshold) {
//    yawVelocity = abs((currYaw - prevYaw) / deltaTime * 1000);
//    prevYaw = currYaw;
//    prevTime = currTime;
//    println("yaw: " + yaw + " | angular velocity: " + yawVelocity);
//  }
//}

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
