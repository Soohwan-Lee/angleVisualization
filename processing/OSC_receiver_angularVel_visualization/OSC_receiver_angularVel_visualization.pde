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

// Arrays to store the values for graphing
int maxPoints = 300;
float[] yawValues = new float[maxPoints];
float[] pitchValues = new float[maxPoints];
float[] rollValues = new float[maxPoints];
float[] yawVelocityValues = new float[maxPoints];
float[] pitchVelocityValues = new float[maxPoints];
float[] rollVelocityValues = new float[maxPoints];

void setup() {
  size(1000, 800);  // Set the size of the window
  oscar = new OscP5(this, 6000);
  oscar.plug(this, "yaw", "/yaw");
  oscar.plug(this, "pitch", "/pitch");
  oscar.plug(this, "roll", "/roll");

  prevTime = millis();
  textSize(16);
}

void draw() {
  background(0);  // Clear the background
  currTime = millis();
  deltaTime = currTime - prevTime;

  // Update graph data
  updateGraph(yawValues, currYaw);
  updateGraph(pitchValues, currPitch);
  updateGraph(rollValues, currRoll);
  updateGraph(yawVelocityValues, yawVelocity);
  updateGraph(pitchVelocityValues, pitchVelocity);
  updateGraph(rollVelocityValues, rollVelocity);

  // Draw graphs
  drawGraph(yawValues, color(255, 0, 0), 0);
  drawGraph(pitchValues, color(0, 255, 0), 100);
  drawGraph(rollValues, color(0, 0, 255), 200);
  drawGraph(yawVelocityValues, color(255, 255, 0), 300);
  drawGraph(pitchVelocityValues, color(255, 0, 255), 400);
  drawGraph(rollVelocityValues, color(0, 255, 255), 500);

  // Draw Raw Value
  textSize(30);
  fill(255, 0, 0);
  text("Yaw: " + currYaw, 0, 200);
  fill(0, 255, 0);
  text("Pitch: " + currPitch, 0, 300);
  fill(0, 0, 255);
  text("Roll: " + currRoll, 0, 400);
  fill(255, 255, 0);
  text("Yaw Velocity: " + yawVelocity, 0, 500);
  fill(255, 0, 255);
  text("Pitch Velocity: " + pitchVelocity, 0, 600);
  fill(0, 255, 255);
  text("Roll Velocity: " + rollVelocity, 0, 700);
}

void updateGraph(float[] values, float newValue) {
  for (int i = 0; i < values.length - 1; i++) {
    values[i] = values[i + 1];
  }
  values[values.length - 1] = newValue;
}

void drawGraph(float[] values, int col, int yOffset) {
  stroke(col);
  noFill();
  beginShape();
  for (int i = 0; i < values.length; i++) {
    float x = map(i, 0, values.length - 1, 0, width);
    float y = map(values[i], -180, 180, height / 2, 0) + yOffset;
    vertex(x, y);
  }
  endShape();
}

void yaw(float yaw) {
  currYaw = yaw;
  if (deltaTime > deltaTime_threshold) {
    yawVelocity = abs((currYaw - prevYaw) / (float)deltaTime * 1000);
    prevYaw = currYaw;
    prevTime = currTime;
  }
}

void pitch(float pitch) {
  currPitch = pitch;
  if (deltaTime > deltaTime_threshold) {
    pitchVelocity = abs((currPitch - prevPitch) / (float)deltaTime * 1000);
    prevPitch = currPitch;
    prevTime = currTime;
  }
}

void roll(float roll) {
  currRoll = roll;
  if (deltaTime > deltaTime_threshold) {
    rollVelocity = abs((currRoll - prevRoll) / (float)deltaTime * 1000);
    prevRoll = currRoll;
    prevTime = currTime;
  }
}
