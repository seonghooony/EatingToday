//
//  BottomSheetCellSettingViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/22.
//

import UIKit
import PanModal

class BottomSheetCellSettingViewController: UIViewController {
    
    var diaryId: String?
    
    let mainView = UIView()
    
//    let contentLabel = UILabel()
    
    let deleteView = UIView()
    let deleteImageView = UIImageView()
    let deleteButton = UIButton()
    
    let lineView = UIView()
    
    let backView = UIView()
    let backImageView = UIImageView()
    let backButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func popDeleteConfirm() {
        
        guard let pvc = self.presentingViewController else { return }
        
        let popDeleteVC = PopDeleteConfirmViewController()
        popDeleteVC.modalPresentationStyle = .overFullScreen
        popDeleteVC.diaryId = self.diaryId
        self.dismiss(animated: true) {
            pvc.present(popDeleteVC, animated: false, completion: nil)
        }
        
        
    }
    
    func viewConfigure() {
        
        self.view.addSubview(self.mainView)
        self.view.backgroundColor = .darkGray
        self.mainView.backgroundColor = .darkGray
        
        self.mainView.addSubview(self.deleteView)
        self.deleteView.backgroundColor = .darkGray
        
        self.deleteView.addSubview(self.deleteImageView)
        self.deleteImageView.image = UIImage(systemName: "trash")
        self.deleteImageView.tintColor = .white
        
        self.deleteView.addSubview(self.deleteButton)
        self.deleteButton.backgroundColor = .clear
        self.deleteButton.setTitle("게시물 삭제", for: .normal)
        self.deleteButton.setTitleColor(.white, for: .normal)
        self.deleteButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        self.deleteButton.addTarget(self, action: #selector(popDeleteConfirm), for: .touchUpInside)
        
        self.mainView.addSubview(self.lineView)
        self.lineView.backgroundColor = .lightGray
        
        
        self.mainView.addSubview(self.backView)
        self.backView.backgroundColor = .darkGray
        
        self.backView.addSubview(self.backImageView)
        self.backImageView.image = UIImage(systemName: "xmark")
        self.backImageView.tintColor = .white
        
        self.backView.addSubview(self.backButton)
        self.backButton.backgroundColor = .clear
        self.backButton.setTitle("취소", for: .normal)
        self.backButton.setTitleColor(.white, for: .normal)
        self.backButton.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
        self.backButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    func constraintConfigure() {
        let leadingtrailingSize = 30
        self.mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.deleteView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        self.deleteImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.width.height.equalTo(24)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.deleteButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalTo(self.deleteImageView.snp.trailing).offset(leadingtrailingSize)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.top.equalTo(self.deleteView.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }
        
        self.backView.snp.makeConstraints { make in
            make.top.equalTo(self.lineView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        self.backImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingtrailingSize)
            make.width.height.equalTo(24)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.backButton.titleLabel?.snp.makeConstraints { make in
            make.leading.equalTo(self.backImageView.snp.trailing).offset(leadingtrailingSize)
        }
        
    }
}

extension BottomSheetCellSettingViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    
    
    
    
}

