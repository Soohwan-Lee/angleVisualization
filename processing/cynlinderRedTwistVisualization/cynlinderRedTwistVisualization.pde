int numSides = 40; // Number of sides for the cylinder
float radius = 100; // Radius of the cylinder
float cylinderHeight = 200; // Height of the cylinder
float twistFactor; // Amount of twist based on mouse position
float sensitivity = 0.5; // Twist sensitivity (0.0 to 1.0)

void setup() {
  size(800, 600, P3D);
}

void draw() {
  background(255);
  lights();
  translate(width / 2, height);
  
  // Calculate twist factor based on mouse X position with sensitivity
  twistFactor = map(mouseX, 0, width, -PI, PI) * sensitivity;
  
  // Draw the twisted cylinder
  fill(200); // Light gray color for the cylinder
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= numSides; i++) {
    float angle = TWO_PI / numSides * i;
    float x1 = cos(angle) * radius;
    float z1 = sin(angle) * radius;
    float y1 = cylinderHeight * 1;
    float x2 = cos(angle + twistFactor) * radius;
    float z2 = sin(angle + twistFactor) * radius;
    float y2 = cylinderHeight / 2;
    
    // Top vertex
    vertex(x1, -y1, z1);
    // Bottom vertex
    vertex(x2, -y2, z2);
  }
  endShape();
  
  stroke(255, 0, 0);
  strokeWeight(3);
}

// Adjust sensitivity with mouse wheel
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  sensitivity = constrain(sensitivity - e * 0.05, 0.1, 1.0);
  println("Sensitivity: " + sensitivity);
}



//int numSides = 40; // Number of sides for the cylinder
//float radius = 100; // Radius of the cylinder
//float height = 200; // Height of the cylinder
//float twistFactor; // Amount of twist based on mouse position

//void setup() {
//  size(800, 600, P3D);
//  noStroke();
//}

//void draw() {
//  background(255);
//  lights();
//  translate(width / 2, height);

//  // Calculate twist factor based on mouse X position
//  twistFactor = map(mouseX, 0, width, -PI, PI);

//  beginShape(QUAD_STRIP);
//  for (int i = 0; i <= numSides; i++) {
//    float angle = TWO_PI / numSides * i;
//    float x1 = cos(angle) * radius;
//    float z1 = sin(angle) * radius;
//    //float y1 = -height / 2;
//    float y1 = height / 5;
//    float x2 = cos(angle + twistFactor) * radius;
//    float z2 = sin(angle + twistFactor) * radius;
//    float y2 = height * 9 / 10;

//    // Top vertex
//    vertex(x1, y1, z1);
//    // Bottom vertex
//    vertex(x2, y2, z2);
//  }
//  endShape();
//}
