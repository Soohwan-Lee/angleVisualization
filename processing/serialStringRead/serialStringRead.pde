// Example by Tom Igoe

import processing.serial.*;

Serial myPort;  // The serial port

void setup() {
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 9600);
}

void draw() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();
    if (inBuffer != null) {
      println(inBuffer);
      float[] result = parseStringData(inBuffer);  // Data parsing
      println("Parsed floats: ");
      for (float f : result) {
        println(f);
      }
      println("======================");
    }
  }
}

// Data parsing
float[] parseStringData(String data) {
  // Trim leading and trailing spaces
  data = trim(data);

  // Check for '<' at the beginning and '>' at the end
  if (data.charAt(0) == '<' && data.charAt(data.length() - 1) == '>') {
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
