import hypermedia.net.*;

UDP udp;  // define the UDP object
int port = 9600;

// Variables to store current values
float currPitch = 0;
float currRoll = 0;
float pitchAngularSpeed = 0;
float rollAngularSpeed = 0;

float tiltX = 0; // Tilt around the X-axis (forward and backward)
float tiltY = 0; // Tilt around the Y-axis (side to side)

void setup() {
  size(640, 360, P3D); // Set up the 3D rendering context
  noStroke(); // No outlines for shapes
  udp = new UDP(this, port);
  udp.listen(true);
  println("UDP Client initialized at port " + port);
}

void draw() {
  background(255); // Set background to white

  // Adjust the camera to better view the cylinder
  translate(width / 2, height * 3 / 4, 0);

  // TiltX is now based on currPitch for forward/backward tilt
  // TiltY is now based on currRoll for side to side tilt
  tiltX = map(currPitch, -90, 90, PI/2, -PI / 2); // Allows full vertical movement range
  tiltY = map(currRoll, -90, 90, -PI/2, PI/2); // Allows full horizontal movement range

  float red = map(pitchAngularSpeed, 0, 150, 0, 255);
  float blue = map(rollAngularSpeed, 0, 150, 0, 255);

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

    // Check if there are exactly four elements
    if (parts.length == 4) {
      // Create an array to store the parsed floats
      float[] floats = new float[4];

      // Convert each part to a float
      try {
        for (int i = 0; i < parts.length; i++) {
          floats[i] = float(parts[i]);
        }
        return floats;
      } catch (NumberFormatException e) {
        println("Error: One of the values is not a valid float.");
        return null;
      }
    } else {
      println("Error: The data does not contain exactly four float values.");
      return null;
    }
  } else {
    println("Trash Data");
    return null;
  }
}

// Custom function to draw a cylinder
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
