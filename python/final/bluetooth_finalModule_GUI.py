
import asyncio
import sys
from bleak import BleakScanner, BleakClient
from PyQt5.QtWidgets import QApplication, QMainWindow, QTextEdit, QPushButton, QVBoxLayout, QWidget, QHBoxLayout, QLineEdit, QLabel
from PyQt5.QtCore import QObject, QThread, pyqtSignal, pyqtSlot, Qt
from PyQt5.QtGui import QFont

UDP_IP = "127.0.0.1"
UDP_PORT = 9600
RECONNECT_DELAY = 1
MAX_RETRIES = 5
DEFAULT_DEVICE_NAME = "CHIPSEN"

UNIST_DESIGN_ASCII = [
    "██╗   ██╗███╗   ██╗██╗███████╗████████╗    ██████╗ ███████╗███████╗██╗ ██████╗ ███╗   ██╗",
    "██║   ██║████╗  ██║██║██╔════╝╚══██╔══╝    ██╔══██╗██╔════╝██╔════╝██║██╔════╝ ████╗  ██║",
    "██║   ██║██╔██╗ ██║██║███████╗   ██║       ██║  ██║█████╗  ███████╗██║██║  ███╗██╔██╗ ██║",
    "██║   ██║██║╚██╗██║██║╚════██║   ██║       ██║  ██║██╔══╝  ╚════██║██║██║   ██║██║╚██╗██║",
    "╚██████╔╝██║ ╚████║██║███████║   ██║       ██████╔╝███████╗███████║██║╚██████╔╝██║ ╚████║",
    " ╚═════╝ ╚═╝  ╚═══╝╚═╝╚══════╝   ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
]

UNIST_ASCII = [
    "██╗   ██╗███╗   ██╗██╗███████╗████████╗",
    "██║   ██║████╗  ██║██║██╔════╝╚══██╔══╝",
    "██║   ██║██╔██╗ ██║██║███████╗   ██║   ",
    "██║   ██║██║╚██╗██║██║╚════██║   ██║   ",
    "╚██████╔╝██║ ╚████║██║███████║   ██║   ",
    " ╚═════╝ ╚═╝  ╚═══╝╚═╝╚══════╝   ╚═╝   "
]

DESIGN_ASCII = [
    "██████╗ ███████╗███████╗██╗ ██████╗ ███╗   ██╗",
    "██╔══██╗██╔════╝██╔════╝██║██╔════╝ ████╗  ██║",
    "██║  ██║█████╗  ███████╗██║██║  ███╗██╔██╗ ██║",
    "██║  ██║██╔══╝  ╚════██║██║██║   ██║██║╚██╗██║",
    "██████╔╝███████╗███████║██║╚██████╔╝██║ ╚████║",
    "╚═════╝ ╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
]

class WorkerSignals(QObject):
    output = pyqtSignal(str)
    finished = pyqtSignal()
    calibrate = pyqtSignal()

class BLEWorker(QThread):
    def __init__(self):
        super().__init__()
        self.signals = WorkerSignals()
        self.target_device_name = ""
        self.current_address = None
        self.current_char_uuid = None
        self.stop_flag = False
        self.signals.calibrate.connect(self.send_calib)

    def run(self):
        asyncio.run(self.scan_and_connect())

    def stop(self):
        self.stop_flag = True

    async def scan_and_connect(self):
        while not self.stop_flag:
            self.signals.output.emit("Scanning for devices...")
            try:
                devices = await BleakScanner.discover()
            except Exception as e:
                self.signals.output.emit(f"Failed to scan for devices: {e}")
                await asyncio.sleep(RECONNECT_DELAY)
                continue

            target_device = next((device for device in devices if device.name == self.target_device_name), None)

            if target_device is None:
                self.signals.output.emit(f"{self.target_device_name} device not found. Retrying in {RECONNECT_DELAY} seconds...")
                await asyncio.sleep(RECONNECT_DELAY)
            else:
                self.signals.output.emit(f"Found {self.target_device_name} device: {target_device.name}, Address: {target_device.address}")
                self.current_address = target_device.address
                service_uuid, char_uuid = await self.discover_uuids_with_retry(target_device.address)
                if service_uuid and char_uuid:
                    self.current_char_uuid = char_uuid
                    await self.handle_connection(target_device.address, service_uuid, char_uuid)
                else:
                    self.signals.output.emit(f"Failed to discover required UUIDs. Retrying scan in {RECONNECT_DELAY} seconds...")
                    await asyncio.sleep(RECONNECT_DELAY)

    async def discover_uuids_with_retry(self, address):
        for attempt in range(MAX_RETRIES):
            try:
                return await self.discover_uuids(address)
            except Exception as e:
                self.signals.output.emit(f"Attempt {attempt + 1}/{MAX_RETRIES} failed: {e}")
                if attempt < MAX_RETRIES - 1:
                    self.signals.output.emit(f"Retrying in {RECONNECT_DELAY} seconds...")
                    await asyncio.sleep(RECONNECT_DELAY)
                else:
                    self.signals.output.emit("Max retries reached. Moving back to scanning.")
        return None, None

    async def discover_uuids(self, address):
        async with BleakClient(address) as client:
            services = await client.get_services()
            target_service = None
            target_char = None

            for service in services:
                self.signals.output.emit(f"[Service] {service.uuid}")
                for char in service.characteristics:
                    self.signals.output.emit(f"  [Characteristic] {char.uuid}")
                    if "fff1" in char.uuid.lower():
                        target_service = service.uuid
                        target_char = char.uuid
                        break
                if target_service:
                    break

            if target_service and target_char:
                self.signals.output.emit(f"Found target Service UUID: {target_service}")
                self.signals.output.emit(f"Found target Characteristic UUID: {target_char}")
                return target_service, target_char
            else:
                self.signals.output.emit("Target UUIDs not found")
                return None, None

    async def handle_connection(self, address, service_uuid, char_uuid):
        while not self.stop_flag:
            connected = await self.connect_and_receive(address, service_uuid, char_uuid)
            if connected:
                break
            else:
                self.signals.output.emit(f"Reconnecting in {RECONNECT_DELAY} seconds...")
                await asyncio.sleep(RECONNECT_DELAY)

    async def connect_and_receive(self, address, service_uuid, char_uuid):
        try:
            async with BleakClient(address) as client:
                def notification_handler(sender, data):
                    try:
                        data_str = data.decode('utf-8')
                        self.signals.output.emit(f"Received: {data_str}")
                    except Exception as e:
                        self.signals.output.emit(f"Failed to process received data: {e}")

                await client.start_notify(char_uuid, notification_handler)
                self.signals.output.emit(f"Connected to {address}, receiving data...")

                while not self.stop_flag:
                    await asyncio.sleep(1)  # Keep the connection alive

        except Exception as e:
            self.signals.output.emit(f"Failed to connect to {address}: {e}")
            return False

    @pyqtSlot()
    def send_calib(self):
        if self.current_address and self.current_char_uuid:
            self.signals.output.emit("Sending +CALIB...")
            asyncio.run_coroutine_threadsafe(self._send_calib(), asyncio.get_event_loop())
        else:
            self.signals.output.emit("Not connected to a device")

    async def _send_calib(self):
        try:
            async with BleakClient(self.current_address) as client:
                await client.write_gatt_char(self.current_char_uuid, b'+CALIB')
                self.signals.output.emit("Sent +CALIB")
        except Exception as e:
            self.signals.output.emit(f"Failed to send +CALIB: {e}")

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('BLE Scanner and Receiver')
        self.setGeometry(100, 100, 600, 400)

        layout = QVBoxLayout()

        # Device name input
        device_layout = QHBoxLayout()
        self.device_name_input = QLineEdit(DEFAULT_DEVICE_NAME)
        device_layout.addWidget(QLabel("Device Name:"))
        device_layout.addWidget(self.device_name_input)
        self.connect_button = QPushButton('Connect')
        self.connect_button.clicked.connect(self.start_connection)
        device_layout.addWidget(self.connect_button)
        layout.addLayout(device_layout)

        self.textEdit = QTextEdit()
        self.textEdit.setReadOnly(True)
        layout.addWidget(self.textEdit)

        # Set monospaced font for QTextEdit
        font = QFont("Courier")
        font.setStyleHint(QFont.Monospace)
        font.setFixedPitch(True)
        font.setPointSize(10)
        self.textEdit.setFont(font)

        # Set Calibration button
        # self.calibButton = QPushButton('Calibration')
        # self.calibButton.clicked.connect(self.send_calib)
        # layout.addWidget(self.calibButton)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        self.ble_worker = None

    def start_connection(self):
        if self.ble_worker:
            self.ble_worker.stop()
            self.ble_worker.wait()

        device_name = self.device_name_input.text()
        if device_name:
            self.textEdit.clear()  # Clear previous content
            self.display_ascii_art()  # Display ASCII art before starting the worker
            self.ble_worker = BLEWorker()
            self.ble_worker.target_device_name = device_name
            self.ble_worker.signals.output.connect(self.update_log)
            self.ble_worker.start()
            self.connect_button.setEnabled(False)
            self.device_name_input.setEnabled(False)
        else:
            self.textEdit.append("Please enter a device name")

    def display_ascii_art(self):
        ascii_art_html = "<pre style='margin: 0; line-height: 1;'>"
        # for line in UNIST_ASCII + [''] + DESIGN_ASCII:  # Add an empty line between UNIST and DESIGN
        #     ascii_art_html += f"{line}<br>"
        for line in UNIST_DESIGN_ASCII:  # Add an empty line between UNIST and DESIGN
            ascii_art_html += f"{line}<br>"
        ascii_art_html += "</pre>"
        self.textEdit.setHtml(ascii_art_html)

    @pyqtSlot(str)
    def update_log(self, message):
        self.textEdit.append(message)

    def send_calib(self):
        if self.ble_worker:
            self.ble_worker.signals.calibrate.emit()
        else:
            self.textEdit.append("Not connected to a device")

    def closeEvent(self, event):
        if self.ble_worker:
            self.ble_worker.stop()
            self.ble_worker.wait()
        event.accept()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec_())