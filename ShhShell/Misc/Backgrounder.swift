//
//  Backgrounder.swift
//  ShhShell
//
//  Created by neon443 on 24/08/2025.
//

import Foundation
import CoreLocation

class Backgrounder: NSObject, CLLocationManagerDelegate, ObservableObject {
	private let manager = CLLocationManager()
	
	@MainActor
	static var shared: Backgrounder = Backgrounder()
	
	override init() {
		super.init()
		manager.delegate = self
		if checkPermsStatus() {
			manager.allowsBackgroundLocationUpdates = true
		}
	}
	
	func startBgTracking() {
		manager.allowsBackgroundLocationUpdates = true
		manager.pausesLocationUpdatesAutomatically = false
		manager.startMonitoringSignificantLocationChanges()
		print("started tgracking")
	}
	
	func stopBgTracking() {
		manager.stopUpdatingLocation()
		manager.allowsBackgroundLocationUpdates = false
		print("stopped tracking")
	}
	
	func requestPerms() {
		manager.requestAlwaysAuthorization()
	}
	
	func checkPermsStatus() -> Bool {
		let status = manager.authorizationStatus
		
		switch status {
		case .authorized, .notDetermined, .restricted, .denied, .authorizedWhenInUse:
			return false
		case .authorizedAlways:
			return true
		default:
			return false
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("tracking started yay")
	}
}
