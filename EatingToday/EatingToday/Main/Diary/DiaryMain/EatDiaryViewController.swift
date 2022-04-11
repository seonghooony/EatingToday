//
//  EatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore
import CryptoKit
import Alamofire
//import PanModal
import MaterialComponents




class EatDiaryViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.black
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        // Start animation.
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true

        return activityIndicator

    }()
    
    let headView = UIView()
    let titleButton = UIButton()
    let diaryAddButton = UIButton()
    let mainView = UIView()
    private lazy var boardTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .white
//        tableView.separatorStyle = .none
//        tableView.separatorColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        //paging
//        tableView.prefetchDataSource = self
        tableView.register(EatTableViewCell.self, forCellReuseIdentifier: "EatTableViewCell")
        
        return tableView
    }()
    let refreshControl = UIRefreshControl()
    
    var isFirstSetting = true
    
    var currentPage: Int = 1
    let pagingSize = 5
    var userDiaries = Array<String>()
    var diaryInfos = Array<DiaryInfo>()
    var diaryImageArrays = Array<Array<UIImage>>()
    
    var dataSource: [AnyObject] = []
    lazy var cache: NSCache<AnyObject, AnyObject> = NSCache()
    
    var previousTabBarIndex = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if isFirstSetting {
            self.getUserDiaryList()
            self.isFirstSetting = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewConfigure()
        self.constraintConfigure()
        self.notificationCenterConfigure()
    }
    
    
    
    @objc func addDairyButtonTapped() {
        print("클릭")
        let addDairyVC = AddEatDiaryViewController()
//        addDairyVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        self.present(addDairyVC, animated: true, completion: nil)
        addDairyVC.refreshDiaryDelegate = self

        
        navigationController?.pushViewController(addDairyVC, animated: true)
    }
    
    
    
    func getUserDiaryList() {
        self.activityIndicator.startAnimating()
        //터치 이벤트 막기
        self.mainView.isUserInteractionEnabled = false
        
        
        if let uid = Auth.auth().currentUser?.uid {
            let userDiariesList = db.collection("users").document(uid)
            
            userDiariesList.getDocument { [weak self] document, error in
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
                                self?.userDiaries = diaryList.sorted(by: >)
                                //print(self.userDiaries)
                               
                                self?.getDiaryInfo(list: self!.userDiaries, currentPage: self!.currentPage) { [weak self] startIndex, endIndex, diaryInfos in
                                    self?.activityIndicator.stopAnimating()
                                    //터치 이벤트 막기
                                    self?.mainView.isUserInteractionEnabled = true
                                    DispatchQueue.main.async {
                                        self?.boardTableView.reloadData()
                                        print("첫 화면 리로드 완료")
                                    }
                                    
//                                    self?.downloadImages(startIndex: startIndex, endIndex: endIndex) { [weak self] result in
//                                        if result == "success" {
//                                            //print("이미지데이터 로드 완료")
//                                            self?.activityIndicator.stopAnimating()
//                                            //터치 이벤트 막기
//                                            self?.mainView.isUserInteractionEnabled = true
//
//                                            DispatchQueue.main.async {
//                                                self?.boardTableView.reloadData()
//                                                print("첫 화면 리로드 완료")
//                                            }
//                                        }
//                                    }
                                }
                            } else {
                                print("유저 내 다이어리 개수 0개임")
                                self?.boardTableView.reloadData()
                                self?.activityIndicator.stopAnimating()
                                self?.mainView.isUserInteractionEnabled = true
                            }
                            
                        } else {
                            print("유저 내 다이어리 없음")
                            self?.boardTableView.reloadData()
                            self?.activityIndicator.stopAnimating()
                            self?.mainView.isUserInteractionEnabled = true
                            
                        }
                        
                        
                    } catch let error {
                        print("ERROR JSON Parsing \(error)")
                        
                    }
                } else {
                    print("유저 정보 없음")
                    self?.boardTableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                    self?.mainView.isUserInteractionEnabled = true
                }

            }
        }
        
        
    }
    
    func getDiaryInfo(list: [String], currentPage: Int, completion: @escaping (Int, Int, Array<DiaryInfo>?) -> Void) {
        
        if self.userDiaries.count > 0 {
            
            let startIndex = (self.currentPage - 1) * self.pagingSize
            let endIndex = self.currentPage * self.pagingSize > self.userDiaries.count ? self.userDiaries.count : self.currentPage * self.pagingSize
            
            //print("뺀값 : \(endIndex - startIndex)")
            
            for _ in startIndex..<endIndex {
                self.diaryInfos.append(DiaryInfo(place_info: nil, date: nil, category: nil, score: nil, story: nil, images: nil, diaryId: nil, writeDate: nil, writerId: nil))
            }
            
            var completeCount = 0
            
            for i in startIndex..<endIndex {
                let diaryInfoDoc = self.db.collection("diaries").document(self.userDiaries[i])
                
                diaryInfoDoc.getDocument { [weak self] document, error in
                    if let error = error {
                        print("Error get Diary Info : \(error.localizedDescription)")
                        return
                    }
                    //print("document?.data() : \(document?.data())")
                    
                    if let documentData = document?.data() {
                        
                        do {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                            if let diaryInfo = try? JSONDecoder().decode(DiaryInfo.self, from: jsonData) {
                                
                                self?.diaryInfos[i] = diaryInfo
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
                            completion(startIndex, endIndex, self?.diaryInfos)
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
    
    func downloadImages(startIndex: Int, endIndex: Int, completion: @escaping (String) -> Void) {
        for i in startIndex..<endIndex {
            self.diaryImageArrays.append(Array<UIImage>())
            if let urls = self.diaryInfos[i].images {
                var imageDataList = Array<UIImage>()
                
                for _ in 0..<urls.count {
                    imageDataList.append(UIImage())
                }
                self.diaryImageArrays[i] = imageDataList
            }
        }
        
        for i in startIndex..<endIndex {
            if let urls = self.diaryInfos[i].images {
                //print("\(i)번째 url들 :\(urls)")

                var completeDownCount = 0
                for j in 0..<urls.count {
                    self.downloadImage(urlString: urls[j]) { [weak self] image in
                        if let image = image {
//                            imageDataList[j] = image
                            self?.diaryImageArrays[i][j] = image
                            completeDownCount += 1
                            
                            if completeDownCount == urls.count {
                                completion("success")
                            }
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    private func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(4 * 1024 * 1024)
        
        storageReference.getData(maxSize: megaByte) { data, error in
            if let error = error {
                print("Image Download Error : \(error.localizedDescription)")
            }
            
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    
    func getTimeInterval(date: Date?) -> String {
        let calendar = Calendar.current
        
        let offsetComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!, to: Date())
        var intervalStr = "시간없음"
        
        if case let (year?, month?, day?, hour?, minute?, second?) = (offsetComps.year, offsetComps.month, offsetComps.day, offsetComps.hour, offsetComps.minute, offsetComps.second) {
            print( "\(year)  \(month)  \(day)  \(hour)  \(minute)  \(second)")
            if year > 0 {
                intervalStr = "\(year)년 전"
                
            } else if month > 0 {
                intervalStr = "\(month)개월 전"
                
            } else if day > 0 {
                intervalStr = "\(day)일 전"
                
            } else if hour > 0 {
                intervalStr = "\(hour)시간 전"
                
            } else if minute > 0 {
                intervalStr = "\(minute)분 전"
                
            } else if second > 0 {
                intervalStr = "\(second)초 전"
            }
        }
        
        return intervalStr
    }
    
    func notificationCenterConfigure() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDiaryNotification(_:)),
            name: NSNotification.Name("refreshDiary"),
            object: nil
        )
    }
    @objc func refreshDiaryNotification(_ notification: Notification) {
        
        self.currentPage = 1
        self.userDiaries.removeAll()
        self.diaryInfos.removeAll()
        self.diaryImageArrays.removeAll()
        self.boardTableView.reloadData()
        self.getUserDiaryList()
        
    }
    @objc func refreshDiaryControl(refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        self.currentPage = 1
        self.userDiaries.removeAll()
        self.diaryInfos.removeAll()
        self.diaryImageArrays.removeAll()
        self.boardTableView.reloadData()
        self.getUserDiaryList()
        
    }
    
    @objc func moveUpperScroll() {
        DispatchQueue.main.async {
            self.boardTableView.setContentOffset(.zero, animated: true)
        }
        
    }  
    
    func viewConfigure() {
        
        self.tabBarController?.delegate = self
        
        self.view.addSubview(self.headView)
        self.headView.backgroundColor = .white
    
        self.headView.addSubview(titleButton)
        self.titleButton.setTitle("Eatingram", for: .normal)
        self.titleButton.setTitleColor(.black, for: .normal)
        self.titleButton.titleLabel?.textAlignment = .center
        self.titleButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 25)
        self.titleButton.addTarget(self, action: #selector(moveUpperScroll), for: .touchUpInside)
        
        self.headView.addSubview(diaryAddButton)
        self.diaryAddButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        self.diaryAddButton.imageView?.tintColor = .black
        self.diaryAddButton.addTarget(self, action: #selector(addDairyButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .white
        self.mainView.addSubview(self.boardTableView)
        self.boardTableView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshDiaryControl(refreshControl:)), for: .valueChanged)
        
        self.mainView.addSubview(self.activityIndicator)
        self.activityIndicator.stopAnimating()
    

        
    }
    
    func constraintConfigure() {
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.titleButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
            //make.trailing.equalToSuperview().offset(0)
        }
        
        self.diaryAddButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(64)
            make.width.height.equalTo(24)
            //make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.diaryAddButton.imageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mainView.snp.makeConstraints{ make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.boardTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            
        }
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
    }
        

}

extension EatDiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("셀 개수 : \(self.diaryInfos.count)")
        return self.diaryInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Rows: \(indexPath.row)")
        print("sections: \(indexPath.section)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "EatTableViewCell", for: indexPath) as? EatTableViewCell
        cell?.selectionStyle = .none
        
        let cellDiaryInfo = self.diaryInfos[indexPath.row]
        
        cell?.cellDiaryInfo = cellDiaryInfo
        cell?.titleLabel.text = cellDiaryInfo.place_info?.place_name
        cell?.scoreLabel.rating = Double(cellDiaryInfo.score ?? 0.0)
        cell?.scoreLabel.text = "\(cellDiaryInfo.score ?? 0.0)점"
        cell?.locationLabel.text = cellDiaryInfo.place_info?.address_name
//        cell?.categoryLabel.text = cellDiaryInfo.category
        if let cellDate = cellDiaryInfo.date {
            cell?.dateLabel.text = "\(cellDate) 방문"
        }
        
        if let writeDateString = cellDiaryInfo.writeDate {
            let writeDate = cell?.dateFormatter.date(from: writeDateString)
            let intervalStr = self.getTimeInterval(date: writeDate)
            print(intervalStr)
            cell?.writeDateLabel.text = intervalStr
        }

        cell?.storyLabel.text = cellDiaryInfo.story
        
        if let imagecount = cellDiaryInfo.images?.count {
            cell?.imagecount = imagecount
            cell?.pageControl.numberOfPages = imagecount
            
        }
        
        cell?.diaryId = cellDiaryInfo.diaryId
        
        cell?.popSetBottomSheetDelegate = self
        
        cell?.imageCollectionView.reloadData()
        
        
//        cell?.infoContentView.sizeToFit()
        
        
        
        
        //print("\(indexPath.row)번째 셀 이미지들")
        //print(self.diaryImageArrays[indexPath.row])
        
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("사라질 셀 : \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("보여질 셀: \(indexPath.row)")
        
        if (indexPath.row + 1)/pagingSize == currentPage {
            self.currentPage += 1
            print("self.currentPage : \(self.currentPage)")
            self.getDiaryInfo(list: self.userDiaries, currentPage: self.currentPage) { [weak self] startIndex, endIndex, diaryInfos in
                    
//                var insertIndexPaths = [IndexPath]()
//                print("만들어질 인덱스 : \(startIndex)~\(endIndex)")
//                print("diaryInfos개수 \(diaryInfos?.count)")
//                for index in startIndex..<endIndex {
//
//                    let indexPath = IndexPath(row: index, section: Int(0))
//                    insertIndexPaths.append(indexPath)
//                }

                DispatchQueue.global().sync {

                    self?.boardTableView.reloadData()
                }
                
                self?.activityIndicator.stopAnimating()
                //터치 이벤트 막기
                self?.mainView.isUserInteractionEnabled = true
                
                self?.boardTableView.reloadData()
                
//                self?.downloadImages(startIndex: startIndex, endIndex: endIndex) { [weak self] result in
//                    if result == "success" {
//                        print("이미지데이터 로드 완료")
//                        self?.activityIndicator.stopAnimating()
//                        //터치 이벤트 막기
//                        self?.mainView.isUserInteractionEnabled = true
//
////                        var reloadIndexPaths = [IndexPath]()
////                        for index in startIndex..<endIndex {
////                            let indexPath = IndexPath(row: index, section: Int(0))
////                            reloadIndexPaths.append(indexPath)
////                        }
//                        DispatchQueue.global().sync {
//
//                            self?.boardTableView.reloadData()
//                        }
////                        DispatchQueue.main.async {
////                            self.boardTableView.reloadData()
////                        }
//                    }
//                }
            }

        }
    }
    
    

}

extension EatDiaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
//        return 500
    }
    
}


extension EatDiaryViewController: refreshDiaryDelegate {
    func refreshDiary() {
        self.currentPage = 1
        self.userDiaries.removeAll()
        self.diaryInfos.removeAll()
        self.diaryImageArrays.removeAll()
        self.boardTableView.reloadData()
        self.getUserDiaryList()

    }
}


extension EatDiaryViewController: popSetBottomSheetDelegate {
    func popSetBottomSheet(diaryid: String?) {
        
        print("다이어리 아이디 : \(diaryid)")
        
        let bottomSheetVC = BottomSheetCellSettingViewController()
        bottomSheetVC.diaryId = diaryid
        
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: bottomSheetVC)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 121
        
        self.present(bottomSheet, animated: true)
        

    }
}


extension EatDiaryViewController: UITabBarControllerDelegate {
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController)!
        
        if selectedIndex == 0 {
            if selectedIndex == self.previousTabBarIndex {
                //스크롤링
                print("스크롤 위로 실행")
                self.moveUpperScroll()
            } else {
                self.previousTabBarIndex = selectedIndex!
                print("그냥 아무것도안함")
            }
            
        } else {
            self.previousTabBarIndex = selectedIndex!
            print("그냥 아무것도안함")
        }
    }
}
