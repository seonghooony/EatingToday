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



class AddEatDiaryViewController: UIViewController {
    
    let customGray1 = UIColor(displayP3Red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    let customGray2 = UIColor(displayP3Red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
    let customGray3 = UIColor(displayP3Red: 130/255, green: 130/255, blue: 135/255, alpha: 1)
    
    let darkblue = UIColor(displayP3Red: 5/255, green: 19/255, blue: 103/255, alpha: 1)
    
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    var selectedPlace: SelectedSearchResultDocument?
    
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
    let storeSearchImageView = UIImageView()
    let storeNameButton = UIButton()
    
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

    var imageAssets = Array<PHAsset>()
    var selectedImages = Array<UIImage>()
    var selectedAssets = Array<PHAsset>()
    var imagesUrl = [String()]
    
    let dateView = UIView()
    let dateLabel = UILabel()
    let dateField = UITextField()
    let datepicker = UIDatePicker()
    var eatDate = Date()
    
    let locationView = UIView()
    let locationLabel = UILabel()
    let locationField = UITextField()
    let location = String()

    let scoreView = UIView()
    let scoreLabel = UILabel()
    let scoreUiView = UIView()
    let score = String()

    let categoryView = UIView()
    let categoryLabel = UILabel()
    let categoryField = UITextField()
    let category = String()

    let storyView = UIView()
    let storyLabel = UILabel()
    let storyField = UITextField()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
        scrollViewEndEditing()
    }
    
    // 스크롤뷰에서 클릭시 endEditing 기능 먹도록 함
    func scrollViewEndEditing() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.endEdit))
        singleTap.numberOfTapsRequired = 1
        singleTap.isEnabled = true
        singleTap.cancelsTouchesInView = false
        self.mainScrollView.addGestureRecognizer(singleTap)
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
//        addDairyVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
//        navigationController?.pushViewController(searchKakaoVC, animated: true)
        searchKakaoVC.resultDelegate = self
        self.present(searchKakaoVC, animated: true, completion: nil)
    }
    
    private func configureDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(datepickerDoneTapped))
        //toolbar.setItems(leftButton, doneButton], animated: true)
        toolbar.items = [leftButton, doneButton]
        
        self.datepicker.datePickerMode = .date
        self.datepicker.locale = Locale(identifier: "ko_KR")
        self.datepicker.preferredDatePickerStyle = .wheels
        self.datepicker.addTarget(self, action: #selector(datePickerValueDidChanged(_:)), for: .valueChanged)
        self.dateField.inputAccessoryView = toolbar
        self.dateField.inputView = self.datepicker
    }
    @objc private func datePickerValueDidChanged(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 년 MM 월 dd 일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        
        self.eatDate = datePicker.date
        self.dateField.text = formatter.string(from: datePicker.date)
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
    
    func showAlert(msg: String) {
        let alert = UIAlertController(
            title: "알림",
            message: """
            \(msg)
            """,
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewConfigure() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.headView)
        self.headView.addSubview(self.backButton)
        self.backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.backButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        self.headView.addSubview(self.titleLabel)
        self.titleLabel.text = "새 게시물"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        self.titleLabel.textColor = UIColor.black
        
        self.headView.addSubview(self.registerButton)
        self.registerButton.setTitle("등록", for: .normal)
        self.registerButton.setTitleColor(UIColor.black, for: .normal)
        self.registerButton.titleLabel?.font = UIFont(name: "Helvetica Bold", size: 17)
        
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
        //self.storeNameView.layer.addBorder([.top, .bottom], color: UIColor.lightGray, width: 1.0)
        
        
        
        self.storeNameView.addSubview(self.storeNameLabel)
        self.storeNameLabel.text = "가게 이름"
        self.storeNameLabel.textAlignment = .center
        self.storeNameLabel.textColor = .black
        self.storeNameLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.storeNameView.addSubview(self.storeSearchView)
        self.storeSearchView.layer.cornerRadius = 3
        self.storeSearchView.layer.borderWidth = 1.5
        self.storeSearchView.layer.borderColor = customGray2.cgColor
        
        self.storeSearchView.addSubview(self.storeNameButton)
        self.storeNameButton.backgroundColor = .clear
        self.storeNameButton.setTitle("방문하신 가게 명을 입력해주세요.", for: .normal)
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
        self.imageUiView.addSubview(imageCollectionView)
        
        self.mainScrollView.addSubview(self.dateView)
        self.dateView.backgroundColor = .white
        
        self.dateView.addSubview(self.dateLabel)
        self.dateLabel.text = "먹은 날짜"
        self.dateLabel.textAlignment = .center
        self.dateLabel.textColor = .black
        self.dateLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.dateView.addSubview(self.dateField)
        self.dateField.backgroundColor = .clear
        self.dateField.layer.cornerRadius = 22.5
        self.dateField.layer.borderWidth = 1.5
        self.dateField.layer.borderColor = UIColor.black.cgColor
        //self.dateField.placeholder = "식사하신 날짜를 선택해주세요."
        self.dateField.attributedPlaceholder = NSAttributedString(string: "식사하신 날짜를 선택해주세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.dateField.addLeftPadding()
        //self.dateField.
        self.configureDatePicker()
        
//        
//        self.mainView.addSubview(self.locationView)
//        self.locationView.addSubview(self.locationLabel)
//        self.locationView.addSubview(self.locationField)
//        
//        self.mainScrollView.addSubview(self.scoreView)
//        self.scoreView.addSubview(self.scoreLabel)
//        self.scoreView.addSubview(self.scoreUiView)
//        
//        self.mainView.addSubview(self.categoryView)
//        self.categoryView.addSubview(self.categoryLabel)
//        self.categoryView.addSubview(self.categoryField)
//        
//        self.mainScrollView.addSubview(self.storyView)
//        self.storyView.addSubview(self.storyLabel)
//        self.storyView.addSubview(self.storyField)
        
        
        
    }
    
    func constraintConfigure() {
        let leadingtrailingSize = 20
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(leadingtrailingSize + 5)
            make.top.equalToSuperview().offset(60)
            make.height.width.equalTo(30)
            
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
            //make.height.equalTo(5000) //마지막 부분에 bottom 제약조건 안걸고 싶으면 고정 높이를 정해줘야함
            
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
            make.height.equalTo(100)
        }

        self.storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.storeSearchView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(45)
        }
        
        self.storeNameButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        self.storeSearchImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-leadingtrailingSize + 10)
            make.width.height.equalTo(25)
        }
        
        
        self.storeNameButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
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
            make.height.equalTo(100)
            make.bottom.equalToSuperview()//스크롤바가 고정높이가 아니라면 스크롤바의 마지막에 꼭 넣어줘야함.
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.dateField.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
            make.height.equalTo(45)
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
        cell.imageView.layer.cornerRadius = 10
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
            
            imageManager.requestImage(
                for: self.selectedAssets[indexPath.row - 1],
                   targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: option
            ) { (result, info) in
                print("이미지 생성중")
                
                if let result = result {
                    print("이미지 생성완료")
                    popDetailImageViewController.animationView.stop()
                    popDetailImageViewController.animationView.isHidden = true
                    
                    thumbnail = result
                    let data = thumbnail.jpegData(compressionQuality: 1)
                    let newImage = UIImage(data: data!)
                    popDetailImageViewController.detailImageView.contentMode = .scaleAspectFit
                    popDetailImageViewController.detailImageView.image = newImage
                    
                    
                }
                
            }
            
            
            
            self.present(popDetailImageViewController, animated: false, completion: nil)
        }
        
    }
    
    //셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    //셀간 최소간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}



extension AddEatDiaryViewController: selectedStorePlaceDelegate {
    func showSelectedStorePlace(document: SelectedSearchResultDocument) {
        self.selectedPlace = document
        debugPrint(document)
        self.storeNameButton.setTitle(self.selectedPlace?.place_name, for: .normal)
        self.storeNameButton.setTitleColor(darkblue, for: .normal)
        self.storeNameButton.backgroundColor = .white
        
    }
}

extension AddEatDiaryViewController: deleteIndexImageDelegate {
    func deleteIndexImage(index: Int) {
        self.selectedAssets.remove(at: index)
        self.selectedImages.remove(at: index)
        self.imageCollectionView.reloadData()
    }
}


extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}

