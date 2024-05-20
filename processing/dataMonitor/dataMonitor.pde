import processing.serial.*;
long now,pre;
Serial port;
 
int sensor1_val;
int[] sensor1_vals;
int sensor2_val;
int[] sensor2_vals;
int sensor3_val;
int[] sensor3_vals;
int sensor4_val;
int[] sensor4_vals;
 
void setup() 
{
  size(640, 480);
  port = new Serial(this, "COM8", 9600);     
  sensor1_vals = new int[width];
  sensor2_vals = new int[width];
  sensor3_vals = new int[width];
  sensor4_vals = new int[width];
  smooth();
}
void draw()
{
  //find first bit
  while(port.available() > 1)
  {
    if (port.read() == 's')
      break;
  }
 
  while (port.available() >= 13) { 
    if (port.read() == 'a') { 
      sensor1_val=((port.read())+(port.read()<<8)); 
    }
    if (port.read() == 'b') { 
      sensor2_val=((port.read())+(port.read()<<8)); 
    }
    if (port.read() == 'c') { 
      sensor3_val=((port.read())+(port.read()<<8)); 
    }
    if (port.read() == 'd') { 
      sensor4_val=((port.read())+(port.read()<<8)); 
    }
port.read();
  }
  
  
  now=millis();
  if((now-pre)>1){  
    pre=now;
    background(0);
    fill(255, 0, 0);
    text(sensor1_val,100,50);  
    fill(0, 255, 0);
    text(sensor2_val,200,50); 
    fill(153, 000, 204);
    text(sensor3_val,100,100); 
    fill(255, 204, 0);
    text(sensor4_val,200,100);
    
    //sensor1
    for (int i=0; i<width-1; i++) 
      sensor1_vals[i] = sensor1_vals[i+1];
    sensor1_vals[width-1] = sensor1_val;
    stroke(255, 0, 0);
    for (int x=1; x<width; x++) {
      line(width-x,   height-1-getY(sensor1_vals[x-1]), width-1-x, height-1-getY(sensor1_vals[x]));
    }
    
    //sensor2
    for (int i=0; i<width-1; i++) 
      sensor2_vals[i] = sensor2_vals[i+1];
    sensor2_vals[width-1] = sensor2_val;
    stroke(0, 255, 0);
    for (int x=1; x<width; x++) {
      line(width-x,   height-1-getY(sensor2_vals[x-1]), width-1-x, height-1-getY(sensor2_vals[x]));
    }
    
    //sensor3
    for (int i=0; i<width-1; i++) 
      sensor3_vals[i] = sensor3_vals[i+1];
    sensor3_vals[width-1] = sensor3_val;
    stroke(153, 000, 204);
    for (int x=1; x<width; x++) {
      line(width-x,   height-1-getY(sensor3_vals[x-1]), width-1-x, height-1-getY(sensor3_vals[x]));
    }
    
    //sensor4
    for (int i=0; i<width-1; i++) 
      sensor4_vals[i] = sensor4_vals[i+1];
    sensor4_vals[width-1] = sensor4_val;
    stroke(255, 204, 0);
    for (int x=1; x<width; x++) {
      line(width-x,   height-1-getY(sensor4_vals[x-1]), width-1-x, height-1-getY(sensor4_vals[x]));
    }
  }
}
 
int getY(int val) {
  return (int)(val / 1023.0f * height) - 1;
}
