int numSides = 40; // Number of sides for the cylinder
float radius = 100; // Radius of the cylinder
float height = 200; // Height of the cylinder
int stepSize = 10; // Step size along the height for each layer
float twistSensitivity = 5.0; // Sensitivity of the twist effect
float roll, pitch; // Roll and pitch of the cylinder
float prevMouseX, prevMouseY; // Previous mouse positions
float twistSpeed; // Speed of the mouse for twisting

void setup() {
  size(800, 600, P3D);
  noStroke();
  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

void draw() {
  background(255);
  lights();

  // Calculate roll and pitch based on mouse position
  roll = map(mouseX, 0, width, -PI / 4, PI / 4);
  pitch = map(mouseY, 0, height, -PI / 4, PI / 4);

  // Calculate mouse speed for twist factor
  float dx = mouseX - prevMouseX;
  float dy = mouseY - prevMouseY;
  float mouseSpeed = sqrt(dx * dx + dy * dy);
  twistSpeed = map(mouseSpeed, 0, 50, 0, PI) * twistSensitivity;

  // Update previous mouse positions
  prevMouseX = mouseX;
  prevMouseY = mouseY;

  // Translate to the center horizontally and further down vertically
  translate(width / 2, height / 2 + 100);
  rotateX(pitch);
  rotateZ(roll);

  for (int y = -int(height / 2); y < int(height / 2); y += stepSize) {
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= numSides; i++) {
      float angle = TWO_PI / numSides * i;
      float twist = twistSpeed * y / height;
      float x1 = cos(angle) * radius;
      float z1 = sin(angle) * radius;
      float x2 = cos(angle + twist) * radius;
      float z2 = sin(angle + twist) * radius;

      // Set color based on the angle to visualize twist direction
      if (i % 2 == 0) {
        fill(0, 0, 255); // Blue lines
      } else {
        fill(0, 255, 0); // Green lines
      }

      // Top vertex
      vertex(x1, y, z1);
      // Bottom vertex
      vertex(x2, y + stepSize, z2);
    }
    endShape();
  }
}
