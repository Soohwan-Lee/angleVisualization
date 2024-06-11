import asyncio
from bleak import BleakScanner, BleakClient

async def scan_and_list_services():
    print("Scanning for devices...")
    devices = await BleakScanner.discover()
    
    target_device = None
    for device in devices:
        print(f"Device: {device.name}, Address: {device.address}")
        if device.name == "CHIPSEN":
            target_device = device
            break

    if target_device is None:
        print("CHIPSEN device not found.")
        return

    print(f"Found CHIPSEN device: {target_device.name}, Address: {target_device.address}")
    await list_services(target_device.address)

async def list_services(address):
    try:
        async with BleakClient(address) as client:
            services = await client.get_services()
            print(f"Services for device {address}:")

            for service in services:
                print(f"[Service] {service.uuid}")
                for char in service.characteristics:
                    print(f"  [Characteristic] {char.uuid}")

    except Exception as e:
        print(f"Failed to connect to {address}: {e}")

if __name__ == "__main__":
    asyncio.run(scan_and_list_services())
