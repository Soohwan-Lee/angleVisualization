import hypermedia.net.*;

UDP udp;
int port = 9600;

float currPitch = 0;
float currRoll = 0;
float currYaw = 0;
float pitchAngularSpeed = 0;
float rollAngularSpeed = 0;
float yawAngularSpeed = 0;

int numSides = 40;
float radius = 100;
float cylinderHeight = 200;
float twistFactor = 0;
float twistSensitivity = 0.01;

float tiltX = 0;
float tiltY = 0;

void setup() {
  size(800, 600, P3D);
  udp = new UDP(this, port);
  udp.listen(true);
  println("UDP Client initialized at port " + port);
}

void draw() {
  background(255);
  lights();
  translate(width / 2, height * 3 / 4, 0);

  tiltX = map(currPitch, -90, 90, PI/2, -PI/2);
  tiltY = map(currRoll, -90, 90, -PI/2, PI/2);

  rotateY(tiltY);
  rotateX(tiltX);

  twistFactor += radians(yawAngularSpeed) * twistSensitivity;
  twistFactor = constrain(twistFactor, -PI, PI);
  
  // Fill the cylinder with Pitch & Roll AngularSpeed
  //float red = map(abs(pitchAngularSpeed), 0, 150, 0, 255);
  //float blue = map(abs(rollAngularSpeed), 0, 150, 0, 255);
  //fill(int(red), 10, int(blue));
  fill(150,150,150);

  drawTwistedCylinder();

  stroke(255, 0, 0);
  strokeWeight(3);
  line(radius, -cylinderHeight, 0, radius * cos(twistFactor), 0, radius * sin(twistFactor));
}

void drawTwistedCylinder() {
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= numSides; i++) {
    float angle = TWO_PI / numSides * i;
    float x1 = cos(angle) * radius;
    float z1 = sin(angle) * radius;
    float y1 = -cylinderHeight;
    float x2 = cos(angle + twistFactor) * radius;
    float z2 = sin(angle + twistFactor) * radius;
    float y2 = 0;
    
    vertex(x1, y1, z1);
    vertex(x2, y2, z2);
  }
  endShape();

  // Draw top and bottom circles
  beginShape(TRIANGLE_FAN);
  vertex(0, -cylinderHeight, 0);
  for (int i = 0; i <= numSides; i++) {
    float angle = TWO_PI / numSides * i;
    float x = cos(angle) * radius;
    float z = sin(angle) * radius;
    vertex(x, -cylinderHeight, z);
  }
  endShape();

  beginShape(TRIANGLE_FAN);
  vertex(0, 0, 0);
  for (int i = 0; i <= numSides; i++) {
    float angle = TWO_PI / numSides * i;
    float x = cos(angle + twistFactor) * radius;
    float z = sin(angle + twistFactor) * radius;
    vertex(x, 0, z);
  }
  endShape();
}

void receive(byte[] data, String ip, int port) {
  String inputData = new String(data);
  if (inputData != null) {
    inputData = trim(inputData);
    println("Received Data: " + inputData);
    float[] parsedData = parseStringData(inputData);
    if (parsedData != null) {
      currPitch = parsedData[0];
      currRoll = parsedData[1];
      currYaw = parsedData[2];
      pitchAngularSpeed = parsedData[3];
      rollAngularSpeed = parsedData[4];
      yawAngularSpeed = parsedData[5];
    }
  }
}

float[] parseStringData(String data) {
  if (data.length() > 0 && data.charAt(0) == '<' && data.charAt(data.length() - 1) == '>') {
    data = data.substring(1, data.length() - 1);
    String[] parts = data.split(",");
    if (parts.length == 6) {
      float[] floats = new float[6];
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
      println("Error: The data does not contain exactly six float values.");
      return null;
    }
  } else {
    println("Invalid data format");
    return null;
  }
}

//import hypermedia.net.*;

//UDP udp;
//int port = 9600;

//float currPitch = 0;
//float currRoll = 0;
//float yawAngularSpeed = 0;

//int numSides = 40; // Number of sides for the cylinder
//float radius = 100; // Radius of the cylinder
//float cylinderHeight = 400; // Height of the cylinder
//float twistFactor = 0; // Amount of twist based on yawAngularSpeed
//float twistSensitivity = 0.01; // Adjust this to control twist sensitivity

//void setup() {
//  size(800, 600, P3D);
//  udp = new UDP(this, port);
//  udp.listen(true);
//  println("UDP Client initialized at port " + port);
//}

//void draw() {
//  background(255);
//  lights();
//  translate(width / 2, height / 2);
  
//  // Apply rotations based on pitch and roll
//  rotateX(radians(currPitch));
//  rotateZ(radians(-currRoll));
  
//  // Update twist factor based on yawAngularSpeed
//  twistFactor += radians(yawAngularSpeed) * twistSensitivity;
//  twistFactor = constrain(twistFactor, -PI, PI);
  
//  // Draw the twisted and tilted cylinder
//  fill(200); // Light gray color for the cylinder
//  noStroke();
//  beginShape(QUAD_STRIP);
//  for (int i = 0; i <= numSides; i++) {
//    float angle = TWO_PI / numSides * i;
//    float x1 = cos(angle) * radius;
//    float z1 = sin(angle) * radius;
//    float y1 = -cylinderHeight / 2;
//    float x2 = cos(angle + twistFactor) * radius;
//    float z2 = sin(angle + twistFactor) * radius;
//    float y2 = cylinderHeight / 2;
    
//    vertex(x1, y1, z1);
//    vertex(x2, y2, z2);
//  }
//  endShape();
  
//  // Draw red line to show twist
//  stroke(255, 0, 0);
//  strokeWeight(3);
//  line(radius, -cylinderHeight/2, 0, radius * cos(twistFactor), cylinderHeight/2, radius * sin(twistFactor));
//}

//void receive(byte[] data, String ip, int port) {
//  String inputData = new String(data);
  
//  if (inputData != null) {
//    inputData = trim(inputData);
//    println("Received Data: " + inputData);
    
//    float[] parsedData = parseStringData(inputData);
//    if (parsedData != null) {
//      currRoll = parsedData[0];
//      currPitch = parsedData[1];
//      // We don't use yaw (parsedData[2]) for visualization
//      // We don't use rollAngularSpeed (parsedData[3]) and pitchAngularSpeed (parsedData[4])
//      yawAngularSpeed = parsedData[5];
//    }
//  }
//}

//float[] parseStringData(String data) {
//  if (data.length() > 0 && data.charAt(0) == '<' && data.charAt(data.length() - 1) == '>') {
//    data = data.substring(1, data.length() - 1);
//    String[] parts = data.split(",");
//    if (parts.length == 6) {
//      float[] floats = new float[6];
//      try {
//        for (int i = 0; i < parts.length; i++) {
//          floats[i] = float(parts[i]);
//        }
//        return floats;
//      } catch (NumberFormatException e) {
//        println("Error: One of the values is not a valid float.");
//        return null;
//      }
//    } else {
//      println("Error: The data does not contain exactly six float values.");
//      return null;
//    }
//  } else {
//    println("Invalid data format");
//    return null;
//  }
//}
