import hypermedia.net.*;

UDP udp;  // define the UDP object
int port = 9600;

// Variables to store current values
float currPitch = 0;
float currRoll = 0;
float pitchAngularSpeed = 0;
float rollAngularSpeed = 0;
float yawAngularSpeed = 0;

// Arrays to store the values for graphing
int maxPoints = 300;
float[] pitchValues = new float[maxPoints];
float[] rollValues = new float[maxPoints];
float[] pitchAngularSpeedValues = new float[maxPoints];
float[] rollAngularSpeedValues = new float[maxPoints];
float[] yawAngularSpeedValues = new float[maxPoints];

int spacing = 170;
int initialPosition = 150;
int initialPositionGraph = -50;

void setup() {
  size(1200, 1000);  // Set the size of the window
  udp = new UDP(this, port);
  udp.listen(true);
  println("UDP Client initialized at port " + port);

  textSize(16);
}

void draw() {
  background(0);  // Clear the background

  // Update graph data
  updateGraph(pitchValues, currPitch);
  updateGraph(rollValues, currRoll);
  updateGraph(pitchAngularSpeedValues, pitchAngularSpeed);
  updateGraph(rollAngularSpeedValues, rollAngularSpeed);
  updateGraph(yawAngularSpeedValues, yawAngularSpeed);

  // Draw graphs
  drawGraph(pitchValues, color(0, 255, 0), initialPositionGraph);
  drawGraph(rollValues, color(0, 0, 255), initialPositionGraph + spacing);
  drawGraph(pitchAngularSpeedValues, color(255, 0, 255), initialPositionGraph + (spacing * 2));
  drawGraph(rollAngularSpeedValues, color(0, 255, 255), initialPositionGraph + (spacing * 3));
  drawGraph(yawAngularSpeedValues, color(255, 165, 0), initialPositionGraph + (spacing * 4));

  // Draw Raw Value
  textSize(30);
  fill(0, 255, 0);
  text("Pitch: " + currPitch, 0, initialPosition);
  fill(0, 0, 255);
  text("Roll: " + currRoll, 0, initialPosition + spacing);
  fill(255, 0, 255);
  text("Pitch Angular Speed: " + pitchAngularSpeed, 0, initialPosition + (spacing * 2));
  fill(0, 255, 255);
  text("Roll Angular Speed: " + rollAngularSpeed, 0, initialPosition + (spacing * 3));
  fill(255, 165, 0);
  text("Yaw Angular Speed: " + yawAngularSpeed, 0, initialPosition + (spacing * 4));
}

void receive(byte[] data, String ip, int port) {
  String inputData = new String(data);

  if (inputData != null) {
    inputData = trim(inputData);  // Remove leading and trailing spaces
    println("Initial Data: " + inputData);  // print initial string

    float[] parsedData = parseStringData(inputData);
    if (parsedData != null) {
      currPitch = parsedData[0];
      currRoll = parsedData[1];
      pitchAngularSpeed = parsedData[2];
      rollAngularSpeed = parsedData[3];
      yawAngularSpeed = parsedData[4];
    }
  }
}

float[] parseStringData(String data) {
  // Check for '<' at the beginning and '>' at the end
  if (data.length() > 0 && data.charAt(0) == '<' && data.charAt(data.length() - 1) == '>') {
    // Remove '<' and '>'
    data = data.substring(1, data.length() - 1);

    // Split the string by commas
    String[] parts = data.split(",");

    // Check if there are exactly five elements
    if (parts.length == 5) {
      // Create an array to store the parsed floats
      float[] floats = new float[5];

      // Convert each part to a float
      try {
        for (int i = 0; i < parts.length; i++) {
          floats[i] = float(parts[i]);
        }
        return floats;
      }
      catch (NumberFormatException e) {
        println("Error: One of the values is not a valid float.");
        return null;
      }
    } else {
      println("Error: The data does not contain exactly five float values.");
      return null;
    }
  } else {
    println("Trash Data");
    return null;
  }
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
