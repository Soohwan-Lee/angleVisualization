import asyncio
import socket
from bleak import BleakScanner, BleakClient

UDP_IP = "127.0.0.1"
UDP_PORT = 9600

async def scan_and_connect():
    while True:
        print("Scanning for devices...")
        try:
            devices = await BleakScanner.discover()
        except Exception as e:
            print(f"Failed to scan for devices: {e}")
            await asyncio.sleep(5)  # 재시도 전 잠시 대기
            continue
        
        target_device = None
        for device in devices:
            print(f"Device: {device.name}, Address: {device.address}")
            if device.name == "CHIPSEN":
                target_device = device
                break

        if target_device is None:
            print("CHIPSEN device not found. Retrying in 5 seconds...")
            await asyncio.sleep(5)  # 5초 후에 다시 검색
        else:
            print(f"Found CHIPSEN device: {target_device.name}, Address: {target_device.address}")
            connected = await connect_and_receive(target_device.address)
            if connected:
                break

async def connect_and_receive(address):
    try:
        async with BleakClient(address) as client:
            # 장치와 연결된 후 사용할 수 있는 서비스 및 특성 UUID를 지정합니다.
            services = await client.get_services()
            print(f"Services: {services}")

            for service in services:
                print(f"[Service] {service.uuid}")
                for char in service.characteristics:
                    print(f"  [Characteristic] {char.uuid}")

            service_uuid = "0000fff0-0000-1000-8000-00805f9b34fb"  # 예제 서비스 UUID
            char_uuid = "0000fff1-0000-1000-8000-00805f9b34fb"  # 예제 특성 UUID

            def notification_handler(sender, data):
                # bytearray를 string으로 변환
                try:
                    data_str = data.decode('utf-8')
                    # print(f"Received data: {data_str} (Type: {type(data_str)})")
                    send_udp(data_str)
                except Exception as e:
                    print(f"Failed to process received data: {e}")

            await client.start_notify(char_uuid, notification_handler)

            print(f"Connected to {address}, receiving data...")

            # 스페이스바 입력 감지 및 메시지 전송 태스크 시작
            input_task = asyncio.create_task(monitor_space_key(client, char_uuid))

            await asyncio.sleep(30)  # 30초 동안 데이터 수신을 기다립니다.

            input_task.cancel()  # 입력 감지 태스크 취소
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
