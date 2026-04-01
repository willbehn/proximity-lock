![Build Status](https://github.com/willbehn/proximity-lock/actions/workflows/swift.yml/badge.svg)
![License](https://img.shields.io/github/license/willbehn/proximity-lock)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![Status](https://img.shields.io/badge/status-Work%20in%20Progress-yellow)

<br />
<div align="center">
  <a href="https://github.com/willbehn/proximity-lock">
    <img src="proximityLock/proximityLock/icons/icon_512x512.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">ProximityLock</h3>

  <p align="center">
    
  </p>

</div>

## About The Project
**ProximityLock** is a native macOS app that automatically locks your Mac based on the distance to a selected Bluetooth device.  
It uses the device’s **RSSI (Received Signal Strength Indicator)** to estimate proximity, no companion app or additional setup required!

> This project is currently a work in progress, but feel free to try it out, all feedback is welcomed!

Because RSSI can fluctuate depending on the environment, ProximityLock uses a [**Kalman filter**](https://en.wikipedia.org/wiki/Kalman_filter) to smooth noisy signal data.  
You can also adjust the lock threshold to control when your Mac locks, allowing you to fine-tune behavior for your specific setup/envrionment.

![](images/example.jpg)

## Features

- Native macOS app  
- Uses Bluetooth Low Energy (BLE) RSSI for proximity detection  
- Adjustable lock sensitivity (RSSI threshold)  
- Kalman filtering for more stable signal readings  
- Remembers selected devices and settings  
- Automatically adapts to system apperance

## Security Notice

ProximityLock requires the macOS setting that locks your Mac when the screen saver starts.

Go to:  
`Settings → Lock Screen → "Require password after screen saver begins or display is turned off" and set to “Immediately”`

This is necessary because Apple does not provide a public API to directly lock the Mac without using private or third-party tools.



## Usage

Getting started with ProximityLock is simple:

1. Select a Bluetooth device: Choose a bluetooth device that will be used to estimate your distance from your Mac.

2. Enable Proximity Lock: Turn on Proximity Lock using the toggle at the top of the app.

3. Adjust the lock sensitivity: Use the threshold slider to control when your Mac locks: 
    - Lower values → device must be farther away before locking
    - Higher values → locks sooner

4. Wait for signal calibration: Wait a few moments for the app to collect enough signal samples for accurate tracking.

5. Test ProximityLock by moving the selected bluetooth device away from the mac.
    - Does it lock automatically? Great!
    - Does it not lock? Try tweak the threshold