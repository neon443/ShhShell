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
	var tracking: Bool = false
	
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
		guard !tracking else { return }
		guard checkPermsStatus() else { return }
		manager.allowsBackgroundLocationUpdates = true
		manager.pausesLocationUpdatesAutomatically = false
		manager.startMonitoringSignificantLocationChanges()
		tracking = true
	}
	
	func stopBgTracking() {
		guard tracking else { return }
		manager.stopUpdatingLocation()
		manager.allowsBackgroundLocationUpdates = false
		tracking = false
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
		print("tracking started fr")
	}
}
