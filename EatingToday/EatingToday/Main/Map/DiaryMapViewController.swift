//
//  DiaryMapViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
import CoreLocation
import NMapsMap

class DiaryMapViewController: UIViewController {
    

    var locationManager = CLLocationManager()
    
    var la: Double!
    var lo: Double!
    
    let naverMapView = NMFNaverMapView(frame: UIScreen.main.bounds)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.mapConfigure()
        self.updateCurrentLocation()
    }
    

    
    
    private func mapConfigure() {
        self.naverMapView.showLocationButton = true
        self.naverMapView.mapView.positionMode = .direction
        self.naverMapView.mapView.isIndoorMapEnabled = true
        self.naverMapView.mapView.zoomLevel = 15
        self.view.addSubview(self.naverMapView)
        
    }
    
    private func updateCurrentLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("현재 위치 서비스 On")
            locationManager.startUpdatingLocation()
            print(locationManager.location?.coordinate)
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager.location?.coordinate.latitude ?? 0, lng: locationManager.location?.coordinate.longitude ?? 0))
            cameraUpdate.animation = .easeIn
            self.naverMapView.mapView.moveCamera(cameraUpdate)
        } else {
            print("현재 위치 서비스 Off")
        }
    }

}


extension DiaryMapViewController: CLLocationManagerDelegate {


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
        case .denied:
            print("GPS 권한 요청 거부됨")
        default:
            print("GPS:Default")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let longtitude: CLLocationDegrees = location.coordinate.longitude
        let letitude: CLLocationDegrees = location.coordinate.latitude

        
        print("내 위치 : \(longtitude) , \(letitude)")
    }


}
