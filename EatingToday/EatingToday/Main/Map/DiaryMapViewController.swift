//
//  DiaryMapViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
//import CoreLocation

class DiaryMapViewController: UIViewController {
    
    let DEFAULT_POSITION = MTMapPointGeo(latitude: 37.576568, longitude: 127.029148)
    var mapView: MTMapView!
//    var locationManager: CLLocationManager!
    
//    var la: Double!
//    var lo: Double!
    
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
    }
    

    
    func createPin(itemName: String, mapPoint: MTMapPoint, markerType: MTMapPOIItemMarkerType) -> MTMapPOIItem {
        let poiItem = MTMapPOIItem()
        poiItem.itemName = "\(itemName)"
        poiItem.mapPoint = mapPoint
        poiItem.markerType = markerType
        self.mapView.addPOIItems([poiItem])
        return poiItem
    }
    

    
    
    private func mapConfigure() {
        
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
        
//        self.la = locationManager.location?.coordinate.latitude
//        self.lo = locationManager.location?.coordinate.longitude
//
//        let currentLocation = MTMapPOIItem()
//
//        currentLocation.itemName = "현재위치"
//        currentLocation.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: self.la, longitude: self.lo))
//        currentLocation.markerType = .bluePin
//
//        self.mapView.addPOIItems([currentLocation])
        
        self.mapView = MTMapView(frame: self.view.frame)
        self.mapView?.delegate = self
        self.mapView?.baseMapType = .standard
        //지도 중심점
        self.mapView.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 4, animated: true)
        //현재 위치 트래킹
        self.mapView.showCurrentLocationMarker = true
        self.mapView.currentLocationTrackingMode = .onWithoutHeading
        
        
        
        self.view.addSubview(self.mapView)
    }
    

}

extension DiaryMapViewController: MTMapViewDelegate {
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        let currentLoaction = location?.mapPointGeo()
//        print("현재위치2: \(currentLoaction)")
        if let latitute = currentLoaction?.latitude, let longitude = currentLoaction?.longitude {
//            print("현재 위치: \(latitute), \(longitude)")
        }
    }
    
    func mapView(_ mapView: MTMapView!, updateDeviceHeading headingAngle: MTMapRotationAngle) {
        print("updateDeviceHeading \(headingAngle)")
    }
    
}
//
//extension DiaryMapViewController: CLLocationManagerDelegate {
//
//    func getLocationUsagePermission() {
//        self.locationManager.requestWhenInUseAuthorization()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedAlways, .authorizedWhenInUse:
//            print("GPS 권한 설정됨")
//        case .restricted, .notDetermined:
//            print("GPS 권한 설정되지 않음")
//        case .denied:
//            print("GPS 권한 요청 거부됨")
//        default:
//            print("GPS:Default")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location: CLLocation = locations[locations.count - 1]
//        let longtitude: CLLocationDegrees = location.coordinate.longitude
//        let letitude: CLLocationDegrees = location.coordinate.latitude
//
//        print("내 위치 : \(longtitude) , \(letitude)")
//    }
//
//
//}
