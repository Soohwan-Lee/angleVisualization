import netP5.*;
import oscP5.*;

OscP5 oscar;

void setup() {
  size(400, 400);  // You can set the size of your window here if needed
  oscar = new OscP5(this, 6000);
  oscar.plug(this, "yaw", "/yaw");
  oscar.plug(this, "pitch", "/pitch");
  oscar.plug(this, "roll", "/roll");
}

void draw() {
  // No drawing code needed for now
}

void yaw(float yaw) {
  println("yaw: " + yaw);
}

void pitch(float pitch) {
  println("pitch: " + pitch);
}

void roll(float roll) {
  println("roll: " + roll);
}
