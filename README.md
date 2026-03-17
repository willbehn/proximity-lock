# ProximityLock
<img width="960" height="540" alt="Presentation2" src="https://github.com/user-attachments/assets/4bef1d01-b376-4151-b0cc-f85673183f1b" />

**proximityLock** is a native macOS app that automatically locks your Mac based on the distance from your selected Bluetooth device.  
It uses the device's **RSSI (Received Signal Strength Indicator)** to estimate proximity, no companion app or setup required.  
The project is currently a work in progress, but feel free to test it out!

Because RSSI can fluctuate in different environments, proximityLock uses a **Kalman filter** to smooth out noisy data.  
You can also customize the RSSI threshold to suit your environment and sensitivity preferences.

---

### Features
- Native macOS app
- Uses Bluetooth Low Energy (BLE) RSSI for proximity detection
- Adjustable RSSI threshold to fit your environment
- Kalman filtering for stable signal readings

---

### Installation

#### Requirements
- macOS 13 (Ventura) or later
- Bluetooth enabled on your Mac

#### Steps

1. Download the latest `proximityLock.zip` from the [Releases](../../releases/latest) page and unzip it.
2. Move `proximityLock.app` to your **Applications** folder.
3. **First launch** — macOS Gatekeeper may block the app because it is not notarized. To open it anyway:
   - Right-click (or Control-click) `proximityLock.app` and choose **Open**.
   - Click **Open** in the dialog that appears.
   - You only need to do this once.
4. Enable **Lock Screen on Screen Saver** in macOS:
   - Open **System Settings → Lock Screen**.
   - Set *"Require password after screen saver begins or display is turned off"* to **Immediately**.

   > **Why is this required?**  
   > Apple does not provide a public API to lock the screen directly, so proximityLock triggers the lock by starting the screen saver. The setting above ensures the lock screen appears instantly.

---

### Usage

1. After launching, a **lock icon** appears in your menu bar. Click it to open the control panel.
2. Enable the toggle to start scanning for Bluetooth devices.
3. Select the device you want to use as your proximity anchor (e.g., your phone or watch).
4. Adjust the **Lock threshold** slider:
   - Move it toward *More sensitive* (higher dBm) to lock when the device is still relatively close.
   - Move it toward *Less sensitive* (lower dBm) to only lock when the device is farther away.
5. Walk away from your Mac — it will lock automatically once the signal drops below your threshold.

---

### TODO
- [ ] Make searching for Bluetooth devices not require proximityLock to be turned on.
- [ ] Use the native OS lock instead of the screen saver, removing the need to enable the "lock on screen saver" setting.
- [ ] Test reliability further
