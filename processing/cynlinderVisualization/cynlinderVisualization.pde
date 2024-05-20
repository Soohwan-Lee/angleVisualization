float tiltX = 0; // Tilt around the X-axis (forward and backward)
float tiltY = 0; // Tilt around the Y-axis (side to side)

void setup() {
  size(640, 360, P3D); // Set up the 3D rendering context
  noStroke(); // No outlines for shapes
}

void draw() {
  background(255); // Set background to white
  
  // Adjust the camera to better view the cylinder
  translate(width / 2, height * 3 / 4, 0);
  // Optional: Adjust the scene for better visualization
  // This initial rotation is removed to simplify understanding of tilt directions
  
  // Update tilt based on mouse position for demonstration
  // In a real scenario, replace these with data from your sensors
  // TiltX is now based on mouseY for forward/backward tilt
  // TiltY is now based on mouseX for side to side tilt
  tiltX = map(mouseY, 0, height, -PI / 2, PI / 2); // Allows full vertical movement range
  tiltY = map(mouseX, 0, width, -PI / 2, PI / 2); // Allows full horizontal movement range
  
  // Apply the tilt to the cylinder
  // First apply tiltY for side to side movement
  rotateY(tiltY);
  // Then apply tiltX for forward/backward movement
  rotateX(tiltX);
  
  // Draw the cylinder
  fill(100, 100, 250); // Set cylinder color
  stroke(0,0,0,50); // Set cylinder stroke color
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
  
  for(int i = 0; i < x.length; i++) {
    angle = radians(i);
    x[i] = r * cos(angle);
    y[i] = r * sin(angle);
  }
  
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, -h / 2);
  for(int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], -h / 2);
  }
  endShape();
  
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, h / 2);
  for(int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], h / 2);
  }
  endShape();
  
  beginShape(QUAD_STRIP);
  for(int i = 0; i < x.length; i++) {
    vertex(x[i], y[i], -h / 2);
    vertex(x[i], y[i], h / 2);
  }
  endShape();
}
