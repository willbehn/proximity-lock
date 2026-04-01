# ProximityLock
![Platform](https://img.shields.io/badge/platform-macOS-blue)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![Status](https://img.shields.io/badge/status-Work%20in%20Progress-yellow)

**ProximityLock** is a native macOS app that automatically locks your Mac based on the distance to a selected Bluetooth device.  
It uses the device’s **RSSI (Received Signal Strength Indicator)** to estimate proximity, no companion app or additional setup required!

> This project is currently a work in progress, but feel free to try it out, all feedback is welcomed!

Because RSSI can fluctuate depending on the environment, ProximityLock uses a [**Kalman filter**](https://en.wikipedia.org/wiki/Kalman_filter) to smooth noisy signal data.  
You can also adjust the lock threshold to control when your Mac locks, allowing you to fine-tune behavior for your specific setup/envrionment.

---

### Important

ProximityLock requires the macOS setting that locks your Mac when the screen saver starts.

Go to:  
`Settings → Lock Screen → "Require password after screen saver begins or display is turned off" and set to “Immediately”`

This is necessary because Apple does not provide a public API to directly lock the Mac without using private or third-party tools.

---

### Features

- Native macOS app  
- Uses Bluetooth Low Energy (BLE) RSSI for proximity detection  
- Adjustable lock sensitivity (RSSI threshold)  
- Kalman filtering for more stable signal readings  
- Remembers selected devices and settings  
- Supports both light and dark mode  


