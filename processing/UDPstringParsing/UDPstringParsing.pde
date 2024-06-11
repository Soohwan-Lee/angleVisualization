import hypermedia.net.*;

UDP udp;  // define the UDP object
int port = 9600;

void setup() {
  size(400, 200);
  // create a new datagram connection on port 9600
  udp = new UDP(this, port);
  //udp.log(true);  // <-- printout the connection activity
  udp.listen(true);
  println("UDP Client initialized at port " + port);
}

void draw() {
  // Nothing to do here
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 */
void receive(byte[] data, String ip, int port) {
  String inputData = new String(data);
  
  if (inputData != null) {
    inputData = trim(inputData);  // Remove leading and trailing spaces
    println("Initial Data: " + inputData);  // print initial string
    
    float[] parsedData = parseStringData(inputData);
    if (parsedData != null) {
      println("Parsed floats: ");
      for (float f : parsedData) {
        println(f);
      }
      println("=======================");
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
