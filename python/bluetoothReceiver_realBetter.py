import asyncio
import socket
from bleak import BleakScanner, BleakClient

UDP_IP = "127.0.0.1"
UDP_PORT = 9600
SERVICE_UUID = "0000fff0-0000-1000-8000-00805f9b34fb"  # Example service UUID
CHAR_UUID = "0000fff1-0000-1000-8000-00805f9b34fb"  # Example characteristic UUID
TARGET_DEVICE_NAME = "CHIPSEN"
RECONNECT_DELAY = 1  # seconds to wait before reconnecting

async def scan_and_connect():
    while True:
        print("Scanning for devices...")
        try:
            devices = await BleakScanner.discover()
        except Exception as e:
            print(f"Failed to scan for devices: {e}")
            await asyncio.sleep(RECONNECT_DELAY)  # Wait before retrying
            continue

        target_device = None
        for device in devices:
            print(f"Device: {device.name}, Address: {device.address}")
            if device.name == TARGET_DEVICE_NAME:
                target_device = device
                break

        if target_device is None:
            print(f"{TARGET_DEVICE_NAME} device not found. Retrying in {RECONNECT_DELAY} seconds...")
            await asyncio.sleep(RECONNECT_DELAY)
        else:
            print(f"Found {TARGET_DEVICE_NAME} device: {target_device.name}, Address: {target_device.address}")
            await handle_connection(target_device.address)

async def handle_connection(address):
    while True:
        connected = await connect_and_receive(address)
        if connected:
            break
        else:
            print(f"Reconnecting in {RECONNECT_DELAY} seconds...")
            await asyncio.sleep(RECONNECT_DELAY)

async def connect_and_receive(address):
    try:
        async with BleakClient(address) as client:
            services = await client.get_services()
            print(f"Services: {services}")

            for service in services:
                print(f"[Service] {service.uuid}")
                for char in service.characteristics:
                    print(f"  [Characteristic] {char.uuid}")

            def notification_handler(sender, data):
                try:
                    data_str = data.decode('utf-8')
                    send_udp(data_str)
                    print(data_str)
                except Exception as e:
                    print(f"Failed to process received data: {e}")

            await client.start_notify(CHAR_UUID, notification_handler)
            print(f"Connected to {address}, receiving data...")

            input_task = asyncio.create_task(monitor_space_key(client, CHAR_UUID))

            try:
                # Wait indefinitely for data, allowing cancellation to stop the task
                await input_task
            except asyncio.CancelledError:
                pass
            finally:
                input_task.cancel()
                await client.stop_notify(CHAR_UUID)

            return True

    except Exception as e:
        print(f"Failed to connect to {address}: {e}")
        return False

def send_udp(message):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(message.encode('utf-8'), (UDP_IP, UDP_PORT))
        sock.close()
    except Exception as e:
        print(f"Failed to send UDP message: {e}")

async def monitor_space_key(client, char_uuid):
    print("Press the spacebar to send '+CALIB' message. Type 'exit' to quit.")
    while True:
        key = await asyncio.to_thread(input, "")
        if key == " ":
            try:
                print("Sending +CALIB")
                await client.write_gatt_char(char_uuid, b'+CALIB')
            except Exception as e:
                print(f"Failed to send +CALIB: {e}")
        elif key.lower() == "exit":
            print("Exiting...")
            break

if __name__ == "__main__":
    asyncio.run(scan_and_connect())
