//
//  PopDeleteConfirmViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/23.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore

class PopDeleteConfirmViewController: UIViewController {
    
    var diaryId: String?
    
    let db = Firestore.firestore()
    
    let unableBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    let unableFontColor = UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    
    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
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
    
    private lazy var popupView: UIView = {
        let popView = UIView()
        let shadowSize: CGFloat = 5.0
        popView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.8 + shadowSize, height: 220 + shadowSize)).cgPath
        popView.backgroundColor = .white
        popView.layer.cornerRadius = 10
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        popView.layer.shadowOffset = CGSize(width: 1, height: 4)
        popView.layer.shadowRadius = 15
        popView.layer.shadowOpacity = 1
        
        popView.layer.masksToBounds = false
        popView.layer.shouldRasterize = true
        popView.layer.rasterizationScale = UIScreen.main.scale
        
        popView.layer.cornerRadius = 15
        popView.backgroundColor = .white
        

        return popView
    }()
    
    let contentView = UIView()
    let titleLabel = UILabel()
    let subLabel = UILabel()
    
    let footerView = UIView()
    let cancelButton = UIButton()
    let deleteButton = UIButton()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.cancelButton, self.deleteButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func deleteDiaryButtonTapped() {
        
        if let uid = Auth.auth().currentUser?.uid {
            if let diaryId = diaryId {
                
                self.activityIndicator.startAnimating()
                //터치 이벤트 막기
                self.view.isUserInteractionEnabled = false
                
                
                let updateUserProfile = db.collection("users").document(uid)
                let deleteDiary = self.db.collection("diaries").document(diaryId)
//                let storageRef = Storage.storage().reference().child("\(uid)/\(diaryId)/")
                // 배치 세팅
                let batch = self.db.batch()
                
                batch.updateData([ "diary": FieldValue.arrayRemove([diaryId]) ], forDocument: updateUserProfile)
                batch.deleteDocument(deleteDiary)
                batch.commit() { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.activityIndicator.stopAnimating()
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name("refreshDiary"),
                        object: nil,
                        userInfo: nil
                    )
                    self.dismiss(animated: false)
                    
                    //기능 안돌아감 폴더 삭제안됨 파일구조로만 삭제가능
//                storageRef.delete() { storageError in
//                    if let storageError = storageError {
//                        print(storageError.localizedDescription)
//                        return
//                    }
//                }
  
                }
                
            }
            
            
        } else {
            print("로그인 에러")
        }
        
        
        
        
        
        
        
    }
    
    private func viewConfigure() {
        
        print("삭제할 아이디:\(self.diaryId)")
        
        self.view.addSubview(self.popupView)
        let shadowSize: CGFloat = 5.0
        self.popupView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.9 + shadowSize, height: 200 + shadowSize)).cgPath
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOffset = .zero
        self.popupView.layer.shadowRadius = 8
        self.popupView.layer.shadowOpacity = 0.5
        self.popupView.layer.masksToBounds = false
        
        self.popupView.layer.cornerRadius = 15
        self.popupView.backgroundColor = .white
        
        self.popupView.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.textColor = .black
        self.titleLabel.text = "해당 게시물 삭제"
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        
        self.contentView.addSubview(self.subLabel)
        self.subLabel.textColor = .darkGray
        self.subLabel.text = "정말 해당 게시물을 삭제하시겠어요?"
        self.subLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.popupView.addSubview(self.footerView)
        self.footerView.addSubview(self.stackView)
        self.cancelButton.setContentHuggingPriority(UILayoutPriority(251), for: NSLayoutConstraint.Axis.horizontal)
        self.deleteButton.setContentHuggingPriority(UILayoutPriority(251), for: NSLayoutConstraint.Axis.horizontal)
        
        
        self.cancelButton.setTitle("취소", for: .normal)
        self.cancelButton.backgroundColor = self.unableBackColor
        self.cancelButton.layer.cornerRadius = 10
        self.cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.cancelButton.setTitleColor(self.unableFontColor, for: .normal)
        self.cancelButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.deleteButton.setTitle("삭제", for: .normal)
        self.deleteButton.backgroundColor = self.enableBackColor
        self.deleteButton.layer.cornerRadius = 10
        self.deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.deleteButton.setTitleColor(.red, for: .normal)
        self.deleteButton.addTarget(self, action: #selector(deleteDiaryButtonTapped), for: .touchUpInside)
        
//        self.footerView.addSubview(self.cancelButton)
//        self.footerView.addSubview(self.deleteButton)

    }
    
    private func constraintConfigure() {
        
        let edgeSize = 20
        
        
        self.popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(200)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(edgeSize + 10)
            make.centerX.equalToSuperview()
        }
        
        self.subLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(edgeSize)
            make.centerX.equalToSuperview()
        }
        
        self.footerView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
        self.stackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(edgeSize)
            make.trailing.bottom.equalToSuperview().offset(-edgeSize)
//            make.top.bottom.equalToSuperview()
        }
    }
}
