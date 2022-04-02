//
//  DiaryMapViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit

import CoreLocation
import NMapsMap

import MaterialComponents

import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore

struct locationXY: Hashable {
    let lat: String
    let lng: String
}

class DiaryMapViewController: UIViewController {
    
    let db = Firestore.firestore()

    var locationManager = CLLocationManager()
    let naverMapView = NMFNaverMapView(frame: UIScreen.main.bounds)
    
    
    var userDiaries = Array<String>()
    var diaryInfos = Array<DiaryInfo>()
    var locationMarker = Array<NMFMarker>()
    var locationLatLng: Set<locationXY> = []
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.getUserDiaryList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.deleteMapviewInfo()
    }
    
    private func deleteMapviewInfo() {
        
        for i in 0..<locationMarker.count {
            locationMarker[i].mapView = nil
        }
        locationMarker.removeAll()
        locationLatLng.removeAll()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.mapConfigure()
        self.updateCurrentLocation()
//        self.getUserDiaryList()
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

    
    
    
    
    
    func getUserDiaryList() {
        
        if let uid = Auth.auth().currentUser?.uid {
            let userDiariesList = db.collection("users").document(uid)
            
            userDiariesList.getDocument { document, error in
                if let error = error {
                    print("Error get Diary List : \(error.localizedDescription)")
                    return
                }
                
//                print("\(result?.documentID) : \(result?.data())")
                
                if let documentData = document?.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                        let userDiaryInfo = try JSONDecoder().decode(UserDiaryInfo.self, from: jsonData)
                        if let diaryList = userDiaryInfo.diary {
                            if diaryList.count > 0 {
                                self.userDiaries = diaryList
                                //print(self.userDiaries)
                               
                                self.getDiaryInfo(list: self.userDiaries) {diaryInfos in
                                    
                                    if let diaryInfos = diaryInfos {
                                        //지도에 뿌려주는 역할 해야함
                                        self.setMapMarkers(diaryList: diaryInfos) { markers in
                                            
                                        }
                                    }
                                    
                                    
                                    
                                }
                            } else {
                                print("유저 내 다이어리 개수 0개임")
//                                self.boardTableView.reloadData()
//                                self.activityIndicator.stopAnimating()
//                                self.mainView.isUserInteractionEnabled = true
                            }
                            
                        } else {
                            print("유저 내 다이어리 없음")
//                            self.boardTableView.reloadData()
//                            self.activityIndicator.stopAnimating()
//                            self.mainView.isUserInteractionEnabled = true
                            
                        }
                        
                        
                    } catch let error {
                        print("ERROR JSON Parsing \(error)")
                        
                    }
                } else {
                    print("유저 정보 없음")
//                    self.boardTableView.reloadData()
//                    self.activityIndicator.stopAnimating()
//                    self.mainView.isUserInteractionEnabled = true
                }

            }
        }
        
        
    }
    
    func getDiaryInfo(list: [String], completion: @escaping (Array<DiaryInfo>?) -> Void) {
        
        if self.userDiaries.count > 0 {
            
            let startIndex = 0
            let endIndex = self.userDiaries.count
            
            //print("뺀값 : \(endIndex - startIndex)")
            
            for _ in startIndex..<endIndex {
                self.diaryInfos.append(DiaryInfo(place_info: nil, date: nil, category: nil, score: nil, story: nil, images: nil, diaryId: nil, writeDate: nil, writerId: nil))
            }
            
            var completeCount = 0
            
            for i in startIndex..<endIndex {
                let diaryInfoDoc = self.db.collection("diaries").document(self.userDiaries[i])
                
                diaryInfoDoc.getDocument { document, error in
                    if let error = error {
                        print("Error get Diary Info : \(error.localizedDescription)")
                        return
                    }
                    //print("document?.data() : \(document?.data())")
                    
                    if let documentData = document?.data() {
                        
                        do {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                            if let diaryInfo = try? JSONDecoder().decode(DiaryInfo.self, from: jsonData) {
                                
                                self.diaryInfos[i] = diaryInfo
                                completeCount += 1
//                                print("0: \(self.diaryInfos)")
//                                print("\(i)넣음")
//                                print("\(endIndex - startIndex)개 중 \(completeCount)개 완료")
                                
                            }
                            
                        } catch let error {
                            print("ERROR JSON Parsing \(error)")

                        }
//                        print("(endIndex - startIndex) == completeCount : \(endIndex - startIndex) == \(completeCount) ")
                        
                        if (endIndex - startIndex) == completeCount {
                            completion(self.diaryInfos)
//                            DispatchQueue.main.async {
//                                self.boardTableView.reloadData()
//                            }
                            
                        }
                        
                        //print("다시만듬")
                        
                    }
                }
            }
            
            
        }
        
    }
    
    func setMapMarkers(diaryList: [DiaryInfo], completion: @escaping (Array<NMFMarker>?) -> Void) {
        
        DispatchQueue.global(qos: .default).async {
            for i in 0..<diaryList.count {
                
                
                guard let diaryLat = diaryList[i].place_info?.y else { continue }
                guard let diaryLng = diaryList[i].place_info?.x else { continue }
                
//                guard let diaryLocaName = diaryList[i].place_info?.place_name else { continue }
//                guard let diaryCateName = diaryList[i].category else { continue }
                
                let locationStruct = locationXY(lat: diaryLat, lng: diaryLng)
                
                if self.locationLatLng.contains(locationStruct) {
//                    print(" \( diaryLocaName) 는 이미 존재함")
                    continue
                    
                } else {
//                    print(" \( diaryLocaName) 는 새로 넣음")
                    self.locationLatLng.insert(locationStruct)
                }
                
//                print("새로 넣음 후 이 글이 떠야함 이미존재함 뜬후 이글 뜨면 오류")
                guard let diaryLocaName = diaryList[i].place_info?.place_name else { continue }
                guard let diaryCateName = diaryList[i].category else { continue }
                
                let categoryColor = self.setColorFromCategory(category: diaryCateName) as UIColor
                let categoryImage = self.setImageFromCategory(category: diaryCateName) as NMFOverlayImage
                
                print(categoryColor)
                let mapMarker = NMFMarker()
                mapMarker.position = NMGLatLng(lat: Double(diaryLat) ?? 0, lng: Double(diaryLng) ?? 0)
    //            mapMarker.iconImage = NMF_MARKER_IMAGE_BLACK
                mapMarker.iconImage = categoryImage
                mapMarker.iconTintColor = categoryColor
                mapMarker.width = 22
                mapMarker.height = 22
                
                mapMarker.captionText = diaryLocaName
                mapMarker.captionTextSize = 13
                mapMarker.captionColor = UIColor.black
                mapMarker.captionHaloColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
                
                mapMarker.subCaptionText = diaryCateName
                mapMarker.subCaptionTextSize = 11
                mapMarker.subCaptionColor = categoryColor
                mapMarker.subCaptionHaloColor = UIColor(red: 255/255, green: 251/255, blue: 233/255, alpha: 1.0)
                mapMarker.userInfo = ["diaryIndex" : i]
                mapMarker.userInfo = ["selectedDiaryInfos" : self.findSelectedDiaryList(lat: diaryLat, lng: diaryLng)]
                mapMarker.touchHandler = { (overlay) -> Bool in
//                    print("해당 인덱스 : \(i)")
//                    print("마커 diaryIndex : \(overlay.userInfo["diaryIndex"])")
//                    print("마커 selectedDiaryInfos: \(overlay.userInfo["selectedDiaryInfos"])")
//                    print("식당명 : \(diaryLocaName)")
//
                    self.popDetailPlaceInfo(selectedDiaryInfos: overlay.userInfo["selectedDiaryInfos"] as! [DiaryInfo])
                    
                    return true
                }
                
                self.locationMarker.append(mapMarker)
//                print("append 됨 \(i)")
            }
            
            
            DispatchQueue.main.async { [weak self] in
                
                for i in 0..<(self?.locationMarker.count)! {
                    self?.locationMarker[i].mapView = self?.naverMapView.mapView
                    
//                    print("setting 됨 \(i)")
                }
            }
            
        }

    }
    
    func popDetailPlaceInfo(selectedDiaryInfos: [DiaryInfo]) {
        let bottomSheetVC = BottomSheetSelectedPlaceDetailViewController()
        bottomSheetVC.selectedDiaryInfos = selectedDiaryInfos
        
        bottomSheetVC.selectedPlaceName = selectedDiaryInfos[0].place_info?.place_name
        bottomSheetVC.selectedPlaceAddress = selectedDiaryInfos[0].place_info?.address_name
        bottomSheetVC.selectedPlaceCategory = selectedDiaryInfos[0].category
        
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: bottomSheetVC)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = self.view.bounds.height * 0.4
        
        self.present(bottomSheet, animated: true)
        

    }
    
    func findSelectedDiaryList(lat: String, lng: String) -> [DiaryInfo] {
        
        var selectedDiaryInfos = Array<DiaryInfo>()
        
        for diary in diaryInfos {
            if diary.place_info?.x == lng && diary.place_info?.y == lat {
                selectedDiaryInfos.append(diary)
            }
        }
        
        return selectedDiaryInfos
        
    }
    
    func setImageFromCategory(category: String) -> NMFOverlayImage {
        switch category {
        case "한식":
            return NMFOverlayImage(image: UIImage(named: "tableware")!)
        case "중식":
            return NMFOverlayImage(image: UIImage(named: "lantern")!)
        case "일식":
            return NMFOverlayImage(image: UIImage(named: "squid")!)
        case "양식":
            return NMFOverlayImage(image: UIImage(named: "burger")!)
        case "분식":
            return NMFOverlayImage(image: UIImage(named: "fish-cake")!)
        case "구이":
            return NMFOverlayImage(image: UIImage(named: "meat")!)
        case "아시안":
            return NMFOverlayImage(image: UIImage(named: "asian-hat")!)
        case "디저트":
            return NMFOverlayImage(image: UIImage(named: "ice-cream-cup")!)
        case "그외":
            return NMFOverlayImage(image: UIImage(named: "star")!)
        default:
            return NMFOverlayImage(image: UIImage(named: "button")!)
        }
    }
    
    func setColorFromCategory(category: String) -> UIColor {
//        print(category)
        switch category {
        case "한식":
            //파랑
            return UIColor(red: 51/255, green: 47/255, blue: 208/255, alpha: 1.0)
        case "중식":
            //빨강
            return UIColor(red: 255/255, green: 24/255, blue: 24/255, alpha: 1.0)
        case "일식":
            //옅은 하얀색
            return UIColor(red: 173/255, green: 139/255, blue: 115/255, alpha: 1.0)
        case "양식":
            //노랑
            return UIColor(red: 240/255, green: 165/255, blue: 0/255, alpha: 1.0)
        case "분식":
            //주황
            return UIColor(red: 234/255, green: 92/255, blue: 43/255, alpha: 1.0)
        case "구이":
            //갈색
            return UIColor(red: 134/255, green: 84/255, blue: 57/255, alpha: 1.0)
        case "아시안":
            //짖은 초록
            return UIColor(red: 70/255, green: 78/255, blue: 46/255, alpha: 1.0)
        case "디저트":
            //보라색
            return UIColor(red: 156/255, green: 25/255, blue: 224/255, alpha: 1.0)
        case "그외":
            //보라
            return UIColor(red: 255/255, green: 195/255, blue: 0/255, alpha: 1.0)
        default:
            //검정
            return UIColor(red: 199/255, green: 207/255, blue: 183/255, alpha: 1.0)
            
            
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
