//
//  CustomPopAlertViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/10.
//

import UIKit
import SnapKit

class CustomPopAlertViewController: UIViewController {

    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    private var titleText: String?
    private var messageText: String?
    
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
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        
        titleLabel.textColor = .black
        titleLabel.text = self.titleText
        titleLabel.font = UIFont(name: "Helvetica Bold", size: 20)
        
        return titleLabel
    }()
    
    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel()
        
        contentLabel.numberOfLines = 3
        contentLabel.textAlignment = .center
        
        
        let contentFont = UIFont(name: "Helvetica", size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1

        let atrributes: [NSAttributedString.Key: Any] = [
            .font: contentFont,
            .foregroundColor: UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
        contentLabel.attributedText = NSAttributedString(
            string: self.messageText ?? "",
            attributes: atrributes
        )
        
        return contentLabel
    }()
    
    private lazy var confirmButton: UIButton = {
        let confirmButton = UIButton()
        confirmButton.backgroundColor = self.enableBackColor
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.layer.cornerRadius = 10
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        confirmButton.setTitleColor(self.enableFontColor, for: .normal)
        confirmButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        return confirmButton
    }()
    
    convenience init(title: String? = "", message: String? = "") {
        self.init()
        
        self.titleText = title
        self.messageText = message
        modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }

    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func viewConfigure() {
        self.view.addSubview(self.popupView)
        self.popupView.addSubview(self.titleLabel)
        self.popupView.addSubview(self.contentLabel)
        self.contentLabel.textAlignment = .center
        self.popupView.addSubview(self.confirmButton)
    }
    
    private func constraintConfigure() {
        
        self.popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
//            make.height.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(220)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            
        }
        
        self.contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.height.equalTo(60)
            
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    
    }
    
}

extension UIViewController {
    func showCustomPopup(title: String? = "", message: String? = "") {
        let customPopAlertViewController = CustomPopAlertViewController(title: title, message: message)
        present(customPopAlertViewController, animated: false, completion: nil)
    }
}
