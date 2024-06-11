import java.util.Vector;
import javax.bluetooth.*;
import javax.microedition.io.Connector;
import javax.microedition.io.StreamConnection;

LocalDevice localDevice;
DiscoveryAgent agent;
Vector<RemoteDevice> devices = new Vector<RemoteDevice>();

void setup() {
  size(400, 200);
  println("Initializing Bluetooth...");
  searchAndConnect();
}

void draw() {
  background(255);
  text("Searching and connecting...", 10, 20);
  for (int i = 0; i < devices.size(); i++) {
    try {
      text(devices.get(i).getFriendlyName(true), 10, 40 + i * 20);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}

void searchAndConnect() {
  try {
    localDevice = LocalDevice.getLocalDevice();
    agent = localDevice.getDiscoveryAgent();

    agent.startInquiry(DiscoveryAgent.GIAC, new DiscoveryListener() {
      public void deviceDiscovered(RemoteDevice btDevice, DeviceClass cod) {
        devices.add(btDevice);
        try {
          println("Device found: " + btDevice.getFriendlyName(true));
        } catch (Exception e) {
          e.printStackTrace();
        }
      }

      public void inquiryCompleted(int discType) {
        println("Inquiry completed.");
        if (devices.size() > 0) {
          connectToDevice(devices.get(0)); // 첫 번째 발견된 디바이스에 연결
        }
      }

      public void servicesDiscovered(int transID, ServiceRecord[] servRecord) {}

      public void serviceSearchCompleted(int transID, int respCode) {}
    });
  } catch (Exception e) {
    e.printStackTrace();
  }
}

void connectToDevice(RemoteDevice btDevice) {
  try {
    String url = "btspp://" + btDevice.getBluetoothAddress() + ":1"; // SPP 연결 URL
    StreamConnection connection = (StreamConnection) Connector.open(url);
    println("Connected to device: " + btDevice.getFriendlyName(true));
    // 데이터 전송 및 수신 처리
    connection.close();
  } catch (Exception e) {
    e.printStackTrace();
  }
}
