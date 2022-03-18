//
//  AddEatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/23.
//

import UIKit
import SnapKit
import BSImagePicker
import Photos
import Cosmos
import Lottie
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore

protocol refreshDiaryDelegate: AnyObject {
    
    func refreshDiary()
    
}

class AddEatDiaryViewController: UIViewController {
    
    let customGray1 = UIColor(displayP3Red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    let customGray2 = UIColor(displayP3Red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
    let customGray3 = UIColor(displayP3Red: 130/255, green: 130/255, blue: 135/255, alpha: 1)
    
    let darkblue = UIColor(displayP3Red: 5/255, green: 19/255, blue: 103/255, alpha: 1)
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let successColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let failColor = UIColor.red
    
    let unableBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    let unableFontColor = UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    
    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    let calendarSelectedColor = UIColor(cgColor: CGColor(red: 216/255, green: 33/255, blue: 72/255, alpha: 1.0))

    
    weak var refreshDiaryDelegate: refreshDiaryDelegate?
    
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
    
    let db = Firestore.firestore()
    
    let customActivityIndicator = AnimationView(name: "loadingfood")
    
    let headView = UIView()
    let titleLabel = UILabel()
    let registerButton = UIButton()
    let backButton = UIButton()
    
    let scrollHeadView = UIView()
    let scrollHeadLabel = UILabel()
    
    let mainView = UIView()
    let mainScrollView = UIScrollView()
    let scrollContainerView = UIView()
    
    let storeNameView = UIView()
    let storeNameLabel = UILabel()
    //let storeNameField = UITextField()
    let storeSearchView = UIView()
    let storeNameButton = UIButton()
    let storeSearchImageView = UIImageView()
    
    let imageView = UIView()
    let imageLabel = UILabel()
    let imageUiView = UIView()
    var imageCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        
        return collectionView
    }()

    let dateView = UIView()
    let dateLabel = UILabel()
    
    let dateFieldView = UIView()
    let dateFieldButton = UIButton()
    let dateFieldImageView = UIImageView()
    let dateFormatter = DateFormatter()
    
    
    let categoryView = UIView()
    let categoryLabel = UILabel()
    let categoryFieldView = UIView()
    let categoryFieldButton = UIButton()
    let categoryFieldImageView = UIImageView()

    let scoreView = UIView()
    let scoreLabel = UILabel()
    let scoreUiView = UIView()
    let starView = CosmosView()

    let storyView = UIView()
    let storyLabel = UILabel()
    let storycontentView = UIView()
    let storyTextView = UITextView()
    let textViewPlaceHolder = "드셨던 맛집에서의 이야기를 작성해주세요."
    
    let addDiaryBtnView = UIView()
    let addDiaryButton = UIButton()
    
    var currentKeyboardFrame: CGRect?
//    var activeTextView: UITextView?
    
    var selectedPlace: SelectedSearchResultDocument?
    var imageAssets = Array<PHAsset>()
    var selectedImages = Array<UIImage>()
    var selectedAssets = Array<PHAsset>()
    var selectedOriginalImages = Array<UIImage>()
    var eatDate: Date?
    var eatDateString: String?
    var eatCategory: String?
    
    var placeValidation = false
    var imageValidation = false
    var dateValidation = false
    var cateValidation = false
    var storyValidation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
        scrollViewEndEditing()
        notificationConfigure()
    }
    
    // 스크롤뷰에서 클릭시 endEditing 기능 먹도록 함
    func scrollViewEndEditing() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.endEdit))
        singleTap.numberOfTapsRequired = 1
        singleTap.isEnabled = true
        singleTap.cancelsTouchesInView = false
        self.mainScrollView.addGestureRecognizer(singleTap)
    }
    
    private func notificationConfigure() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
            }
        
        //스크롤 가능한 위치를 키보드 높이만큼 아래를 올려줌 (첫번째는 내용을 나타내는 부분을 올려주고, 두번째는 왼쪽 스크롤바 길이를 맞춰줌)
        self.mainScrollView.contentInset.bottom = keyboardFrame.size.height
        self.mainScrollView.scrollIndicatorInsets.bottom = keyboardFrame.size.height
        self.currentKeyboardFrame = keyboardFrame
//        debugPrint(currentKeyboardFrame)
//        debugPrint(self.mainScrollView.contentInset.bottom)

        
    }
    
    @objc private func keyboardWillHide() {
        
        //원래 상태로 다시 되돌려 놓음. 기존 인셋이 0,0,0,0 이여서 제로로 해도 무방
        let contentInset = UIEdgeInsets.zero
        self.mainScrollView.contentInset = contentInset
        self.mainScrollView.scrollIndicatorInsets = contentInset
        
        self.currentKeyboardFrame = nil
    }
    
    @objc func endEdit() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //빈 화면을 눌러줄때 마다 하단 키보드나 데이트피커가 사라짐
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func datepickerDoneTapped() {
        self.view.endEditing(true)
    }
    
    @objc func moveSearchViewController() {
        print("클릭")
        let searchKakaoVC = SearchKakaoViewController()
        searchKakaoVC.modalPresentationStyle = .overFullScreen
        searchKakaoVC.resultDelegate = self
        self.present(searchKakaoVC, animated: true, completion: nil)
    }
    
    @objc func calendarButtonTapped() {
        let popDateCalendarViewController = PopDateCalendarViewController()
        popDateCalendarViewController.modalPresentationStyle = .overFullScreen
        popDateCalendarViewController.setPickedDateDelegate = self
        if let eatDate = self.eatDate {
            popDateCalendarViewController.previousPickDate = eatDate
        }
        self.present(popDateCalendarViewController, animated: false, completion: nil)
    }

    @objc func categoryButtonTapped() {
        let popCategoryViewController = PopCategoryViewController()
        popCategoryViewController.modalPresentationStyle = .overFullScreen
        popCategoryViewController.setSelectedCategoryDelegate = self
        self.present(popCategoryViewController, animated: false, completion: nil)
        
    }
    
//    @objc func registerClicked1() {
//
//        self.activityIndicator.startAnimating()
//
//        //터치 이벤트 막기
//        self.view.isUserInteractionEnabled = false
//
//        if let uid = Auth.auth().currentUser?.uid {
//
//            let df = DateFormatter()
//            df.locale = Locale(identifier: "ko_KR")
//            df.timeZone = TimeZone(abbreviation: "KST")
//            df.dateFormat = "yyyyMMddHHmmssSSS"
//
//            let diaryUid = uid + "Diary" + df.string(from: Date())
//            print(diaryUid)
//
//            let updateUserProfile = db.collection("users").document(uid)
//
//            updateUserProfile.updateData([
//                "diary": FieldValue.arrayUnion([diaryUid])
//            ]) { error in
//                if let error = error {
//                    print("user 쪽 diary 추가 오류 : \(error.localizedDescription)")
//                } else {
//
//                    let batch = self.db.batch()
//                    let insertDiary = self.db.collection("diaries").document(diaryUid)
//                    let diaryInfo = RegisterDiaryInfo(
//                        place_info: self.selectedPlace,
//                        date: self.eatDateString,
//                        category: self.eatCategory,
//                        score: self.starView.rating,
//                        story: self.storyTextView.text,
//                        images: nil)
//
//                    do {
//                        try batch.setData(from: diaryInfo, forDocument: insertDiary)
//                    }catch let error {
//                        print("ERROR writing userInfo to Firestore \(error.localizedDescription)")
//                    }
//                    batch.commit() { error in
//                        if let error = error {
//                            print("diary 쪽 document 추가 오류 : \(error.localizedDescription)")
//                        } else {
//                            // 이미지 넣기
//                            let imageUid = uid + "Image" + df.string(from: Date())
//
//                            var completeCount = 0
//                            for i in 0..<self.selectedOriginalImages.count {
//                                let storageRef = Storage.storage().reference(withPath: "\(uid)/\(imageUid)_\(i)")
//
//                                guard let imageData = self.selectedOriginalImages[i].jpegData(compressionQuality: 0.5) else { return }
//
//                                storageRef.putData(imageData, metadata: nil) { data, error in
//                                    if let error = error {
//                                        print("Error put image: \(error.localizedDescription)")
//                                        return
//                                    }
//
//                                    storageRef.downloadURL { url, _ in
//                                        guard let imageURL = url?.absoluteString else { return }
//                                        let insertDiary = self.db.collection("diaries").document(diaryUid)
//                                        insertDiary.updateData([
//                                            "imageUrl": FieldValue.arrayUnion([imageURL])
//                                        ]) { error in
//                                            if let error = error {
//                                                print("put imageurl error : \(error.localizedDescription)")
//                                                return
//                                            }
//
//                                            completeCount += 1
//
//                                            if completeCount == self.selectedOriginalImages.count {
//                                                self.activityIndicator.stopAnimating()
//
//                                                self.dismiss(animated: true)
//                                            }
//                                        }
//                                    }
//
//                                }
//
//                            }
//
//                        }
//                    }
//
//
//                }
//            }
//
//
//
//
//        } else {
//            print("로그아웃 됨 다시로그인 해야함.")
//        }
//
//
//
//    }
    
    @objc func registerClicked() {
        
        self.activityIndicator.startAnimating()
    
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false
        
        if let uid = Auth.auth().currentUser?.uid {
            
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.timeZone = TimeZone(abbreviation: "KST")
            df.dateFormat = "yyyyMMddHHmmssSSS"
            
            let diaryUid = uid + "Diary" + df.string(from: Date())
            let imageUid = uid + "Image" + df.string(from: Date())
            print(diaryUid)
            
            let updateUserProfile = db.collection("users").document(uid)
            let insertDiary = self.db.collection("diaries").document(diaryUid)

            // 배치 세팅
            let batch = self.db.batch()
            
            
            
            
            //이미지가 있는 경우
        
            if self.selectedOriginalImages.count != 0 {
                var completeCount = 0
                var imageUrlArray = Array<String>()
                for i in 0..<self.selectedOriginalImages.count {
                    //저장소 폴더 이름 만들기
                    let storageRef = Storage.storage().reference(withPath: "\(uid)/\(diaryUid)/\(imageUid)_\(i)")
                    guard let imageData = self.selectedOriginalImages[i].jpegData(compressionQuality: 0.25) else { return }
                    
                    //저장소에 넣기
                    storageRef.putData(imageData, metadata: nil) { data, error in
                        if let error = error {
                            print("Error put image: \(error.localizedDescription)")
                            return
                        }
                        //저장소에 저장된 이미지 url 추출
                        storageRef.downloadURL { url, _ in
                            guard let imageURL = url?.absoluteString else { return }
                            imageUrlArray.append(imageURL)
                                
                            completeCount += 1
                            
                            if self.selectedOriginalImages.count == completeCount {
                                
                                let diaryInfo = RegisterDiaryInfo(
                                    place_info: self.selectedPlace,
                                    date: self.eatDateString,
                                    category: self.eatCategory,
                                    score: self.starView.rating,
                                    story: self.storyTextView.text,
                                    images: imageUrlArray)
                                
                                do {
                                    batch.updateData([ "diary": FieldValue.arrayUnion([diaryUid]) ], forDocument: updateUserProfile)
                                    try batch.setData(from: diaryInfo, forDocument: insertDiary)
                                }catch let error {
                                    print(error.localizedDescription)
                                }
                                batch.commit() { error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        return
                                    }
                                    
                                    self.activityIndicator.stopAnimating()
                                    
                                    self.refreshDiaryDelegate?.refreshDiary()
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                }
                            }

                        }
                        
                    }
                    
                }
            } else {
                let diaryInfo = RegisterDiaryInfo(
                    place_info: self.selectedPlace,
                    date: self.eatDateString,
                    category: self.eatCategory,
                    score: self.starView.rating,
                    story: self.storyTextView.text,
                    images: nil)
                
                do {
                    batch.updateData([ "diary": FieldValue.arrayUnion([diaryUid]) ], forDocument: updateUserProfile)
                    try batch.setData(from: diaryInfo, forDocument: insertDiary)
                }catch let error {
                    print(error.localizedDescription)
                }
                batch.commit() { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.refreshDiaryDelegate?.refreshDiary()
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
            
        } else {
            print("로그아웃 됨 다시로그인 해야함.")
        }
        

        
    }
    
    func tappedImageAddButton() {
        
        let imagePicker = ImagePickerController()
        
        imagePicker.settings.selection.max = 10 - selectedImages.count
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        presentImagePicker(
            imagePicker,
            select: { (assets) in
                
            },
            deselect: { (assets) in
                
            },
            cancel: { (assets) in
                
            },
            finish: { (assets) in
                self.imageAssets.removeAll()
                for i in 0..<assets.count {
                    self.imageAssets.append(assets[i])
                }
                print("선택 에셋이미지 개수 : \(self.imageAssets.count)")
                self.convertAssetToImages()
                //self.delegate
                print("선택 이미지 개수 : \(self.selectedImages.count)")
                self.imageCollectionView.reloadData()
                
                self.getOriginalImages()
                
                
            }
        )
        
    }
    
    func convertAssetToImages() {
        if self.imageAssets.count != 0 {
            for i in 0..<self.imageAssets.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                var thumbnail = UIImage()
                
                imageManager.requestImage(
                    for: self.imageAssets[i],
                       targetSize: CGSize(width: 100, height: 100),
                    contentMode: .aspectFill,
                    options: option
                ) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                
                self.selectedImages.append(newImage! as UIImage)
                self.selectedAssets.append(imageAssets[i])
                
            }

            
        }
    }
    
    func getOriginalImages() {
        
        self.selectedOriginalImages.removeAll()
        self.imageValidation = false
        self.checkValidation()
        
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .highQualityFormat
        
        option.progressHandler = { (progress, error, stop, info) in
            print("progress: \(progress)")
            if progress >= 1.0 {
                
            }
        }
        option.isNetworkAccessAllowed = true
        //option.version = .original
        var thumbnail = UIImage()
        
        for i in 0..<self.selectedAssets.count {
            self.selectedOriginalImages.append(UIImage())
        }
        
        //로딩바 생성
//        self.activityIndicator.startAnimating()
        self.customActivityIndicator.isHidden = false
        self.customActivityIndicator.play()
        //터치 이벤트 막기
        self.imageView.isUserInteractionEnabled = false
        
        var completeCount = 0
        
        
        for i in 0..<self.selectedAssets.count {
            imageManager.requestImage(
                for: self.selectedAssets[i],
                   targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: option
            ) { (result, info) in
                print("이미지 생성중")
                
                if let result = result {
                    print("이미지 생성완료")
                    
                    
                    thumbnail = result
                    let data = thumbnail.jpegData(compressionQuality: 1)
                    let newImage = UIImage(data: data!)
                    
                    self.selectedOriginalImages[i] = newImage! as UIImage
                    
                    completeCount += 1
                    print("\(i)개 완성 \(completeCount)")
                    if self.selectedAssets.count == completeCount {
//                        self.activityIndicator.stopAnimating()
                        self.customActivityIndicator.isHidden = true
                        self.customActivityIndicator.stop()
                        self.imageView.isUserInteractionEnabled = true
                        
                        self.imageValidation = true
                        self.checkValidation()
                    }
                }
                
            }
            
            
        }
        
        
        
        
    }
    
    private func checkValidation() {
        
        if self.placeValidation == false
//        || self.imageValidation == false
        || self.dateValidation == false
        || self.cateValidation == false
        || self.storyValidation == false
        {
            
            self.addDiaryButton.isEnabled = false
            self.addDiaryButton.backgroundColor = self.unableBackColor
            self.addDiaryButton.setTitleColor(self.unableFontColor, for: .normal)
            
            self.registerButton.isEnabled = false
            self.registerButton.setTitleColor(.lightGray, for: .normal)
            
        } else {
            
            self.addDiaryButton.isEnabled = true
            self.addDiaryButton.backgroundColor = self.enableBackColor
            self.addDiaryButton.setTitleColor(self.enableFontColor, for: .normal)
            
            self.registerButton.isEnabled = true
            self.registerButton.setTitleColor(.black, for: .normal)
            
        }
        
    }
    
    func viewConfigure() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.headView)
        self.headView.addSubview(self.backButton)
        self.backButton.setImage(UIImage(named: "logo_backarrow"), for: .normal)
        self.backButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        self.headView.addSubview(self.titleLabel)
        self.titleLabel.text = "새 게시물"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        self.titleLabel.textColor = UIColor.black
        
        self.headView.addSubview(self.registerButton)
        self.registerButton.setTitle("등록", for: .normal)
        self.registerButton.setTitleColor(.lightGray, for: .normal)
        self.registerButton.titleLabel?.font = UIFont(name: "Helvetica Bold", size: 17)
        self.registerButton.addTarget(self, action: #selector(registerClicked), for: .touchUpInside)
        self.registerButton.isEnabled = false
        
        
        self.view.addSubview(self.mainView)
        self.mainView.addSubview(mainScrollView)
        //self.mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isScrollEnabled = true
        
        self.mainScrollView.addSubview(scrollContainerView)
        self.scrollContainerView.backgroundColor = UIColor(displayP3Red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        
        
        self.scrollContainerView.addSubview(self.scrollHeadView)
        self.scrollHeadView.backgroundColor = .white
        self.scrollHeadView.addSubview(self.scrollHeadLabel)
        self.scrollHeadLabel.numberOfLines = 2
        self.scrollHeadLabel.textAlignment = .left
        let scrollHeadFont = UIFont(name: "Helvetica Bold", size: 21)
        let scrollHeadParagraphStyle = NSMutableParagraphStyle()
        scrollHeadParagraphStyle.lineSpacing = 10

        let scrollHeadAtrributes1: [NSAttributedString.Key: Any] = [
            .font: scrollHeadFont,
            .foregroundColor: UIColor.black,
            .paragraphStyle: scrollHeadParagraphStyle
        ]
        let scrollHeadAtrributes2: [NSAttributedString.Key: Any] = [
            .font: scrollHeadFont,
            .foregroundColor: enableFontColor,
            .paragraphStyle: scrollHeadParagraphStyle
        ]
        let headLabelStr = "맛있게 드신 맛집을\n이팅그램의 기억 속에 남겨주세요."
        let attributedStr = NSMutableAttributedString(string: headLabelStr, attributes: scrollHeadAtrributes1)
        attributedStr.addAttributes(scrollHeadAtrributes2, range: (headLabelStr as NSString).range(of: "이팅그램"))
        self.scrollHeadLabel.attributedText = attributedStr
        
        
        self.scrollContainerView.addSubview(self.storeNameView)
        self.storeNameView.backgroundColor = .white
        
        self.storeNameView.addSubview(self.storeNameLabel)
        self.storeNameLabel.text = "가게 이름"
        self.storeNameLabel.textAlignment = .center
        self.storeNameLabel.textColor = .black
        self.storeNameLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.storeNameView.addSubview(self.storeSearchView)
        self.storeSearchView.layer.cornerRadius = 7
        self.storeSearchView.layer.borderWidth = 1.5
        self.storeSearchView.layer.borderColor = customGray2.cgColor
        
        self.storeSearchView.addSubview(self.storeNameButton)
        self.storeNameButton.backgroundColor = .clear
        self.storeNameButton.setTitle("방문하신 가게를 검색해주세요.", for: .normal)
        self.storeNameButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        self.storeNameButton.titleLabel?.textAlignment = .left
        self.storeNameButton.setTitleColor(customGray2, for: .normal)

        self.storeNameButton.addTarget(self, action: #selector(moveSearchViewController), for: .touchUpInside)
        
        self.storeSearchView.addSubview(self.storeSearchImageView)
        self.storeSearchImageView.image = UIImage(systemName: "magnifyingglass")
        self.storeSearchImageView.tintColor = customGray2
        
        
        
        
        
        self.scrollContainerView.addSubview(self.imageView)
        self.imageView.backgroundColor = .white
        
        self.imageView.addSubview(self.imageLabel)
        self.imageLabel.text = "사진 등록"
        self.imageLabel.textAlignment = .center
        self.imageLabel.textColor = .black
        self.imageLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.imageView.addSubview(self.imageUiView)
        self.imageUiView.backgroundColor = .clear
        
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        imageCollectionView.register(AddImageCollectionViewCell.self, forCellWithReuseIdentifier: "AddImageCollectionViewCell")
        self.imageUiView.addSubview(self.imageCollectionView)
        

        self.imageUiView.addSubview(self.customActivityIndicator)
        self.customActivityIndicator.isHidden = true
        self.customActivityIndicator.stop()
        self.customActivityIndicator.loopMode = .loop
        self.customActivityIndicator.alpha = 0.9

        
        
        self.scrollContainerView.addSubview(self.dateView)
        self.dateView.backgroundColor = .white
        
        
        self.dateView.addSubview(self.dateLabel)
        self.dateLabel.text = "식사 날짜"
        self.dateLabel.textAlignment = .center
        self.dateLabel.textColor = .black
        self.dateLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        
        self.dateView.addSubview(self.dateFieldView)
        self.dateFieldView.layer.cornerRadius = 7
        self.dateFieldView.layer.borderWidth = 1.5
        self.dateFieldView.layer.borderColor = customGray2.cgColor
        
        self.dateFieldView.addSubview(self.dateFieldButton)
        self.dateFieldButton.backgroundColor = .clear
        self.dateFieldButton.setTitle("방문하신 날짜를 선택해주세요.", for: .normal)
        self.dateFieldButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        self.dateFieldButton.titleLabel?.textAlignment = .left
        self.dateFieldButton.setTitleColor(customGray2, for: .normal)
        self.dateFieldButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        self.dateFieldView.addSubview(self.dateFieldImageView)
        self.dateFieldImageView.image = UIImage(systemName: "calendar")
        self.dateFieldImageView.tintColor = customGray2
        
        self.dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        
        self.scrollContainerView.addSubview(self.categoryView)
        self.categoryView.backgroundColor = .white
        
        self.categoryView.addSubview(self.categoryLabel)
        self.categoryLabel.text = "카테고리"
        self.categoryLabel.textAlignment = .center
        self.categoryLabel.textColor = .black
        self.categoryLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.categoryView.addSubview(self.categoryFieldView)
        self.categoryFieldView.layer.cornerRadius = 7
        self.categoryFieldView.layer.borderWidth = 1.5
        self.categoryFieldView.layer.borderColor = customGray2.cgColor
        
        self.categoryFieldView.addSubview(self.categoryFieldButton)
        self.categoryFieldButton.backgroundColor = .clear
        self.categoryFieldButton.setTitle("카테고리를 선택해주세요.", for: .normal)
        self.categoryFieldButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        self.categoryFieldButton.titleLabel?.textAlignment = .left
        self.categoryFieldButton.setTitleColor(customGray2, for: .normal)
        self.categoryFieldButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        
        self.categoryFieldView.addSubview(self.categoryFieldImageView)
        self.categoryFieldImageView.image = UIImage(named: "logo_category")?.withRenderingMode(.alwaysTemplate)
        self.categoryFieldImageView.tintColor = customGray2
    
        
        self.scrollContainerView.addSubview(self.scoreView)
        self.scoreView.backgroundColor = .white
        
        self.scoreView.addSubview(self.scoreLabel)
        self.scoreLabel.text = "맛 평가"
        self.scoreLabel.textAlignment = .center
        self.scoreLabel.textColor = .black
        self.scoreLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.scoreView.addSubview(self.scoreUiView)
        
        self.scoreUiView.addSubview(self.starView)
        self.starView.rating = 3.5
        self.starView.text = "\(self.starView.rating)점"
        self.starView.settings.fillMode = .half
        self.starView.settings.starSize = 45
        self.starView.settings.starMargin = 15
        self.starView.settings.filledColor = enableFontColor
        self.starView.settings.emptyColor = .white
        self.starView.settings.filledBorderColor = enableFontColor
        self.starView.settings.filledBorderWidth = 2
        self.starView.settings.emptyBorderColor = enableFontColor
        self.starView.settings.emptyBorderWidth = 2
        self.starView.didTouchCosmos = { rating in
            self.starView.text = "\(rating)점"
        }
        
        
        self.scrollContainerView.addSubview(self.storyView)
        self.storyView.backgroundColor = .white
        
        self.storyView.addSubview(self.storyLabel)
        self.storyLabel.text = "나의 이야기"
        self.storyLabel.textAlignment = .center
        self.storyLabel.textColor = .black
        self.storyLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.storyView.addSubview(self.storycontentView)
        self.storycontentView.layer.cornerRadius = 7
        self.storycontentView.layer.borderWidth = 1.5
        self.storycontentView.layer.borderColor = customGray2.cgColor
        
        self.storycontentView.addSubview(self.storyTextView)
        self.storyTextView.keyboardType = .default
        self.storyTextView.text = textViewPlaceHolder
        self.storyTextView.textColor = customGray2
        self.storyTextView.font = UIFont(name: "Helvetica", size: 16)
        self.storyTextView.delegate = self
        
        self.scrollContainerView.addSubview(self.addDiaryBtnView)
        self.addDiaryBtnView.backgroundColor = .white
        
        self.addDiaryBtnView.addSubview(self.addDiaryButton)
        self.addDiaryButton.isEnabled = false
        self.addDiaryButton.backgroundColor = self.unableBackColor
        self.addDiaryButton.setTitle("나의 이야기 등록", for: .normal)
        self.addDiaryButton.layer.cornerRadius = 10
        self.addDiaryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.addDiaryButton.setTitleColor(self.unableFontColor, for: .normal)
        self.addDiaryButton.addTarget(self, action: #selector(registerClicked), for: .touchUpInside)
        
        self.scrollContainerView.addSubview(self.activityIndicator)
    }
    
    func constraintConfigure() {
        let leadingtrailingSize = 20
        let fieldHeight = 50
        
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(leadingtrailingSize + 5)
            make.top.equalToSuperview().offset(60)
//            make.height.width.equalTo(30)
            
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        self.registerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-leadingtrailingSize - 5)
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            
        }
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalToSuperview().offset(0)
        }
        
        self.mainScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.scrollContainerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.mainScrollView.contentLayoutGuide)
            make.width.equalTo(self.mainScrollView.frameLayoutGuide)
//            make.height.equalTo(5000) //마지막 부분에 bottom 제약조건 안걸고 싶으면 고정 높이를 정해줘야함
            
        }
        
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
        
        self.customActivityIndicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(50)
        }
        
        self.scrollHeadView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            //equalSuperview로 할경우 수평으로 스크롤 되는 현상 발생, 스크롤뷰이므로 가로세로가 무한이기때문에 정해줘야함
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        self.scrollHeadLabel.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            
        }
        
        self.storeNameView.snp.makeConstraints{ make in
            make.top.equalTo(self.scrollHeadView.snp.bottom).offset(0)
            //equalSuperview로 할경우 수평으로 스크롤 되는 현상 발생, 스크롤뷰이므로 가로세로가 무한이기때문에 정해줘야함
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(110)
        }

        self.storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.storeSearchView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(fieldHeight)
        }
        
        self.storeNameButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        
        self.storeNameButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
        }
        
        
        self.storeSearchImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.width.height.equalTo(25)
        }
        
        
        
        
        self.imageView.snp.makeConstraints{ make in
            make.top.equalTo(self.storeNameView.snp.bottom).offset(0.5)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(150)
            //make.bottom.equalToSuperview()//스크롤바가 고정높이가 아니라면 스크롤바의 마지막에 꼭 넣어줘야함.
        }
        
        self.imageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.imageUiView.snp.makeConstraints { make in
            make.top.equalTo(self.imageLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(100)
        }
        
        self.imageCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.dateView.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(0.5)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(110)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.dateFieldView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(fieldHeight)
        }
        
        self.dateFieldButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        
        self.dateFieldButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
        }
        
        
        self.dateFieldImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.width.height.equalTo(25)
        }
        
        
        self.categoryView.snp.makeConstraints { make in
            make.top.equalTo(self.dateView.snp.bottom).offset(0.5)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(110)
            
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.categoryFieldView.snp.makeConstraints { make in
            make.top.equalTo(self.categoryLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(fieldHeight)
        }
        
        self.categoryFieldButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        
        self.categoryFieldButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
        }
        
        
        self.categoryFieldImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.width.height.equalTo(25)
        }
        
        
        self.scoreView.snp.makeConstraints { make in
            make.top.equalTo(self.categoryView.snp.bottom).offset(0.5)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(110)
            
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.scoreUiView.snp.makeConstraints { make in
            make.top.equalTo(self.scoreLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(fieldHeight)
        }
        
        self.starView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        self.storyView.snp.makeConstraints { make in
            make.top.equalTo(self.scoreView.snp.bottom).offset(0.5)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(300)
            
        }
        
        self.storyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.storycontentView.snp.makeConstraints { make in
            make.top.equalTo(self.storyLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(200)
        }
        
        self.storyTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        
        self.addDiaryBtnView.snp.makeConstraints { make in
            make.top.equalTo(self.storyView.snp.bottom).offset(0)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(70)
            make.bottom.equalToSuperview()//스크롤바가 고정높이가 아니라면 스크롤바의 마지막에 꼭 넣어줘야함.
        }
        
        self.addDiaryButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            
        }
        
        
    }
}


extension AddEatDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImages.count + 1
    }
    
    //셀 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionViewCell", for: indexPath) as? AddImageCollectionViewCell else { return UICollectionViewCell() }
        print("생성 셀 인덱스 : \(indexPath.row)")
        
        cell.cellIndex = indexPath.row
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "logo_addimage")
            ///<a href="https://www.flaticon.com/kr/free-icons/" title="사진 아이콘">사진 아이콘  제작자: Pixel perfect - Flaticon</a>
            cell.deleteButton.isHidden = true
        }else if indexPath.row > 0 {
            
            cell.imageView.image = selectedImages[indexPath.row - 1]
            cell.deleteButton.isHidden = false
            
        }
        
        //삭제버튼 위임
        cell.deleteIndexImageDelegate = self
        cell.imageView.layer.cornerRadius = 5
        cell.imageView.clipsToBounds = true
        
        return cell
    }
    
    
    
    //셀 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if selectedImages.count >= 10 {
                self.showCustomPopup(title: "알림", message: "이미지는 10개 이하로 선택 가능합니다.")
            } else {
                self.tappedImageAddButton()
            }
        } else if indexPath.row > 0 {
            
            //이미지 상세보기 팝업
            let popDetailImageViewController = PopDetailImageViewController()
            print("클릭 인덱스 : \(indexPath.row)")
            popDetailImageViewController.detailImageView.image = nil
            popDetailImageViewController.modalPresentationStyle = .overFullScreen

//            let imageManager = PHImageManager.default()
//            let option = PHImageRequestOptions()
//            option.isSynchronous = false
//            option.deliveryMode = .highQualityFormat
//
//            option.progressHandler = { (progress, error, stop, info) in
//                print("progress: \(progress)")
//                if progress >= 1.0 {
//
//                }
//            }
//            option.isNetworkAccessAllowed = true
//            //option.version = .original
//            var thumbnail = UIImage()
//
//            imageManager.requestImage(
//                for: self.selectedAssets[indexPath.row - 1],
//                   targetSize: PHImageManagerMaximumSize,
//                contentMode: .aspectFit,
//                options: option
//            ) { (result, info) in
//                print("이미지 생성중")
//
//                if let result = result {
//                    print("이미지 생성완료")
//                    popDetailImageViewController.animationView.stop()
//                    popDetailImageViewController.animationView.isHidden = true
//
//                    thumbnail = result
//                    let data = thumbnail.jpegData(compressionQuality: 1)
//                    let newImage = UIImage(data: data!)
//                    popDetailImageViewController.detailImageView.contentMode = .scaleAspectFit
//                    popDetailImageViewController.detailImageView.image = newImage
//
//
//                }
//
//            }
            popDetailImageViewController.animationView.stop()
            popDetailImageViewController.animationView.isHidden = true
            popDetailImageViewController.detailImageView.contentMode = .scaleAspectFit
            popDetailImageViewController.detailImageView.image = self.selectedOriginalImages[indexPath.row - 1]
            
            self.present(popDetailImageViewController, animated: true, completion: nil)
        }
        
    }
    
    //셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    //셀간 최소간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}





extension AddEatDiaryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.activeTextView = textView
        //키보드가 있을경우
        if let keyboardHeight = currentKeyboardFrame?.size.height {
            //포커싱된 텍스트뷰가 이야기 텍스트뷰일경우
            if textView == self.storyTextView {

                //해당 텍스트 뷰 위치를 찾아 스크롤 포커싱 해줌
                self.mainScrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContainerView.bounds.size.height - self.storyView.frame.origin.y + keyboardHeight - self.addDiaryBtnView.bounds.size.height), animated: true)
                
                
                //해당 텍스트 뷰의 placeholder를 임의로 만듬
                if textView.text == self.textViewPlaceHolder && textView.textColor == customGray2 {
                    textView.text = nil
                    textView.textColor = .black
                    textView.font = UIFont(name: "Helvetica", size: 16)
                    
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.storyValidation = false
        } else {
            self.storyValidation = true
        }
        self.checkValidation()
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        self.activeTextView = nil
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = customGray2
            textView.font = UIFont(name: "Helvetica", size: 16)
            
        }
    }
}

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}


extension AddEatDiaryViewController: selectedStorePlaceDelegate {
    func showSelectedStorePlace(document: SelectedSearchResultDocument) {
        self.selectedPlace = document
        debugPrint(document)
        self.storeNameButton.setTitle(self.selectedPlace?.place_name, for: .normal)
        self.storeNameButton.setTitleColor(.black, for: .normal)
        self.storeNameButton.backgroundColor = .white
        self.storeSearchImageView.tintColor = enableFontColor
        self.placeValidation = true
        self.checkValidation()
        
    }
}

extension AddEatDiaryViewController: deleteIndexImageDelegate {
    func deleteIndexImage(index: Int) {
        self.selectedAssets.remove(at: index)
        self.selectedImages.remove(at: index)
        self.selectedOriginalImages.remove(at: index)
        
        print("\(self.selectedAssets.count)개 \(self.selectedImages.count)개 \(self.selectedOriginalImages.count)개")
        self.imageCollectionView.reloadData()
        
        if self.selectedAssets.count == 0 {
            self.imageValidation = false
            self.checkValidation()
        }
        
    }
}

extension AddEatDiaryViewController: setPickedDateDelegate {
    func setPickedDate(date: Date) {
        self.eatDate = date
        
        let calendarDF = DateFormatter()
        calendarDF.dateFormat = "yyyy-MM-dd"
        self.eatDateString = calendarDF.string(from: date)
        
        self.dateFieldButton.setTitle(dateFormatter.string(from: date), for: .normal)
        self.dateFieldButton.setTitleColor(.black, for: .normal)
        self.dateFieldImageView.tintColor = calendarSelectedColor
        self.dateValidation = true
        self.checkValidation()
    }
}

extension AddEatDiaryViewController: setSelectedCategoryDelegate {
    func setSelectedCategory(categoryName: String) {
        self.categoryFieldButton.setTitle(categoryName, for: .normal)
        self.categoryFieldButton.setTitleColor(.black, for: .normal)
        self.categoryFieldImageView.image = UIImage(named: "logo_category")?.withRenderingMode(.alwaysOriginal)
        self.eatCategory = categoryName
        self.cateValidation = true
        self.checkValidation()
    }
}
