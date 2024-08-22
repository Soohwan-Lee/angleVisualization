import asyncio
import socket
from bleak import BleakScanner, BleakClient

UDP_IP = "127.0.0.1"
UDP_PORT = 9600
TARGET_DEVICE_NAME = "CHIPSEN"
RECONNECT_DELAY = 1  # seconds to wait before reconnecting
MAX_RETRIES = 5

async def scan_and_connect():
    while True:
        print("Scanning for devices...")
        try:
            devices = await BleakScanner.discover()
        except Exception as e:
            print(f"Failed to scan for devices: {e}")
            await asyncio.sleep(RECONNECT_DELAY)
            continue

        target_device = next((device for device in devices if device.name == TARGET_DEVICE_NAME), None)

        if target_device is None:
            print(f"{TARGET_DEVICE_NAME} device not found. Retrying in {RECONNECT_DELAY} seconds...")
            await asyncio.sleep(RECONNECT_DELAY)
        else:
            print(f"Found {TARGET_DEVICE_NAME} device: {target_device.name}, Address: {target_device.address}")
            service_uuid, char_uuid = await discover_uuids_with_retry(target_device.address)
            if service_uuid and char_uuid:
                await handle_connection(target_device.address, service_uuid, char_uuid)
            else:
                print(f"Failed to discover required UUIDs. Retrying scan in {RECONNECT_DELAY} seconds...")
                await asyncio.sleep(RECONNECT_DELAY)

async def discover_uuids_with_retry(address):
    for attempt in range(MAX_RETRIES):
        try:
            return await discover_uuids(address)
        except Exception as e:
            print(f"Attempt {attempt + 1}/{MAX_RETRIES} failed: {e}")
            if attempt < MAX_RETRIES - 1:
                print(f"Retrying in {RECONNECT_DELAY} seconds...")
                await asyncio.sleep(RECONNECT_DELAY)
            else:
                print("Max retries reached. Moving back to scanning.")
    return None, None

async def discover_uuids(address):
    async with BleakClient(address) as client:
        services = await client.get_services()
        target_service = None
        target_char = None

        for service in services:
            print(f"[Service] {service.uuid}")
            for char in service.characteristics:
                print(f"  [Characteristic] {char.uuid}")
                if "fff1" in char.uuid.lower():
                    target_service = service.uuid
                    target_char = char.uuid
                    break
            if target_service:
                break

        if target_service and target_char:
            print(f"Found target Service UUID: {target_service}")
            print(f"Found target Characteristic UUID: {target_char}")
            return target_service, target_char
        else:
            print("Target UUIDs not found")
            return None, None

async def handle_connection(address, service_uuid, char_uuid):
    while True:
        connected = await connect_and_receive(address, service_uuid, char_uuid)
        if connected:
            break
        else:
            print(f"Reconnecting in {RECONNECT_DELAY} seconds...")
            await asyncio.sleep(RECONNECT_DELAY)

async def connect_and_receive(address, service_uuid, char_uuid):
    try:
        async with BleakClient(address) as client:
            def notification_handler(sender, data):
                try:
                    data_str = data.decode('utf-8')
                    send_udp(data_str)
                    print(data_str)
                except Exception as e:
                    print(f"Failed to process received data: {e}")

            await client.start_notify(char_uuid, notification_handler)
            print(f"Connected to {address}, receiving data...")

            input_task = asyncio.create_task(monitor_space_key(client, char_uuid))

            try:
                await input_task
            except asyncio.CancelledError:
                pass
            finally:
                input_task.cancel()
                await client.stop_notify(char_uuid)

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