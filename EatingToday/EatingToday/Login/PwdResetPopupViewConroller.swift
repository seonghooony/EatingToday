//
//  PwdResetPopupViewConrolloer.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/09.
//

import UIKit
import SnapKit
import SkyFloatingLabelTextField
import FirebaseAuth

class PwdResetPopupViewController: UIViewController {
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let successColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let failColor = UIColor.red
    
    let unableBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    let unableFontColor = UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    
    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    let popupView = UIView()
    
    let closeButton = UIButton()
    
    let sendEmailView = UIView()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let emailLabel = UILabel()
    let emailField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    let emailDetailLabel = UILabel()
    
    let sendEmailButton = UIButton()

    let successView = UIView()
    let successImageView = UIImageView()
    let successEmailLabel = UILabel()
    let successContentLabel = UILabel()
    let successButton = UIButton()
    
    let failView = UIView()
    let failImageView = UIImageView()
    let failHeadLabel = UILabel()
    let failContentLabel = UILabel()
    let failButton = UIButton()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.popupView.center
        activityIndicator.color = UIColor.darkGray
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        // Start animation.
        activityIndicator.stopAnimating()
        
        return activityIndicator
        
    }()
    
    
    var emailValidation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func sendEmailTapped() {
        
        view.endEditing(true)
        
        self.activityIndicator.startAnimating()
        
        let email = emailField.text
        //비밀번호를 리셋할 수 있는 이메일을 보내줌.
        if let email = email {
            Auth.auth().languageCode = "ko"
            Auth.auth().sendPasswordReset(withEmail: email) { error in
//                debugPrint("이메일 리셋 에러 : \(error)")
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    let code = (error as NSError).code
                    self.emailDetailLabel.textColor = self.failColor
                    self.emailValidation = false
                    self.checkEnableSendButton()
                    switch code {
                    //가입된 계정이 아닐 경우
                    case 17011:
                        self.emailDetailLabel.text = "가입되어 있지 않은 이메일입니다."
                        
                    default:
//                        self.emailDetailLabel.text = "에러"
                        self.sendEmailView.isHidden = true
                        self.failView.isHidden = false
                    }
                    
                } else {
                    //성공시 화면전환
                    self.successEmailLabel.text = email
                    self.sendEmailView.isHidden = true
                    self.successView.isHidden = false
//                    self.showMainViewController()
                }
                
            }
        }
        
    }
    
    private func viewConfigure() {
        
        self.popupView.addSubview(self.activityIndicator)
        
        self.view.addSubview(self.popupView)
        let shadowSize: CGFloat = 5.0
        self.popupView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.8 + shadowSize, height: 300 + shadowSize)).cgPath
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOffset = .zero
        self.popupView.layer.shadowRadius = 8
        self.popupView.layer.shadowOpacity = 0.5
        self.popupView.layer.masksToBounds = false
        self.popupView.layer.shouldRasterize = true
        self.popupView.layer.rasterizationScale = UIScreen.main.scale
        
        
        self.popupView.layer.cornerRadius = 15
        self.popupView.backgroundColor = .white
        
        self.popupView.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.closeButton.tintColor = .darkGray
        self.closeButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.popupView.addSubview(self.sendEmailView)
        self.sendEmailView.addSubview(self.titleLabel)
        self.titleLabel.textColor = .black
        self.titleLabel.text = "비밀번호 재설정"
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 20)
        
        self.sendEmailView.addSubview(self.contentLabel)
        self.contentLabel.numberOfLines = 3
        self.contentLabel.textAlignment = .left
        let contentFont = UIFont(name: "Helvetica", size: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1

        let atrributes: [NSAttributedString.Key: Any] = [
            .font: contentFont,
            .foregroundColor: UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
        self.contentLabel.attributedText = NSAttributedString(
            string: """
                    가입하신 이메일을 통해
                    비밀번호를 변경하실 수 있습니다.
                    """,
            attributes: atrributes
        )
        
        self.sendEmailView.addSubview(self.emailLabel)
        self.emailLabel.text = "이메일"
        self.emailLabel.textColor = .black
        self.emailLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.sendEmailView.addSubview(self.emailField)
        self.emailField.placeholder = "이메일을 입력해주세요."
        self.emailField.title = ""
        //클리어버튼 생성
        self.emailField.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.emailField.autocorrectionType = .no
        //첫글자 자동 대문자
        self.emailField.autocapitalizationType = .none
        //text키보드모드
        self.emailField.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.emailField.isSecureTextEntry = false
        //커서 색상
        self.emailField.tintColor = titleColor
        //안쪽 텍스트 색상
        self.emailField.textColor = .black
        //안쪽 텍스트 폰트
        self.emailField.font = UIFont(name: "Helvetica", size: 16)
        //기본 라인 색상
        self.emailField.lineColor = inactiveColor
        //선택 라인 색상
        self.emailField.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.emailField.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.emailField.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.emailField.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.emailField.selectedLineHeight = 2.0
        //에러 시 색상
        self.emailField.errorColor = .red
        //에러용 액션 추가
        self.emailField.addTarget(self, action: #selector(emailFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
        self.emailField.delegate = self
        
        self.sendEmailView.addSubview(self.emailDetailLabel)
        self.emailDetailLabel.text = ""
        self.emailDetailLabel.textColor = successColor
        self.emailDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.sendEmailView.addSubview(self.sendEmailButton)
        self.sendEmailButton.isEnabled = false
        self.sendEmailButton.backgroundColor = self.unableBackColor
        self.sendEmailButton.setTitle("비밀번호 재설정하기", for: .normal)
        self.sendEmailButton.layer.cornerRadius = 10
        self.sendEmailButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.sendEmailButton.setTitleColor(self.unableFontColor, for: .normal)
        self.sendEmailButton.addTarget(self, action: #selector(sendEmailTapped), for: .touchUpInside)
        
        self.sendEmailView.isHidden = false
        self.successView.isHidden = true
        self.popupView.addSubview(self.successView)
        
        self.successView.addSubview(self.successImageView)
        self.successImageView.image = UIImage(named: "logo_check")
        ///https://www.flaticon.com/premium-icon/cross_3416079?term=x&page=1&position=16&page=1&position=16&related_id=3416079&origin=search#
        
        self.successView.addSubview(self.successEmailLabel)
        self.successEmailLabel.textColor = .black
        self.successEmailLabel.textAlignment = .center
        self.successEmailLabel.text = "Default email address place"
        self.successEmailLabel.font = UIFont(name: "Helvetica Bold", size: 20)
        
        self.successView.addSubview(self.successContentLabel)
        self.successContentLabel.numberOfLines = 3
        self.successContentLabel.textAlignment = .left
        let successContentFont = UIFont(name: "Helvetica", size: 13)
        let successParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let successAtrributes: [NSAttributedString.Key: Any] = [
            .font: successContentFont,
            .foregroundColor: UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
            .paragraphStyle: successParagraphStyle
        ]
        self.successContentLabel.attributedText = NSAttributedString(
            string: """
                    해당 이메일로 비밀번호 재설정 링크를 보내드렸습니다.
                    이메일을 확인해주세요.
                    """,
            attributes: successAtrributes
        )
        
        self.successView.addSubview(self.successButton)
        self.successButton.backgroundColor = self.enableBackColor
        self.successButton.setTitle("확인", for: .normal)
        self.successButton.layer.cornerRadius = 10
        self.successButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.successButton.setTitleColor(self.enableFontColor, for: .normal)
        self.successButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.failView.isHidden = true
        self.popupView.addSubview(self.failView)
        
        self.failView.addSubview(self.failImageView)
        self.failImageView.image = UIImage(named: "logo_cross")
        
        self.failView.addSubview(self.failHeadLabel)
        self.failHeadLabel.textColor = .black
        self.failHeadLabel.textAlignment = .center
        self.failHeadLabel.text = "오류"
        self.failHeadLabel.font = UIFont(name: "Helvetica Bold", size: 20)
        
        self.failView.addSubview(self.failContentLabel)
        self.failContentLabel.numberOfLines = 3
        self.failContentLabel.textAlignment = .left
        let failContentFont = UIFont(name: "Helvetica", size: 13)
        let failParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let failAtrributes: [NSAttributedString.Key: Any] = [
            .font: failContentFont,
            .foregroundColor: UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
            .paragraphStyle: failParagraphStyle
        ]
        self.failContentLabel.attributedText = NSAttributedString(
            string: """
                    알 수 없는 오류가 발생했습니다.
                    문제가 지속되는 경우 문의 부탁드립니다.
                    """,
            attributes: failAtrributes
        )
        
        self.failView.addSubview(self.failButton)
        self.failButton.backgroundColor = self.enableBackColor
        self.failButton.setTitle("확인", for: .normal)
        self.failButton.layer.cornerRadius = 10
        self.failButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.failButton.setTitleColor(self.enableFontColor, for: .normal)
        self.failButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
    }
    
    private func constraintConfigure() {
        let leadingTrailingSize = 20
        
        self.popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
//            make.height.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(300)
        }
        
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize - 2)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.width.height.equalTo(15)
        }
        
        self.sendEmailView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize + 20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        self.contentLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        self.emailLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        self.emailField.snp.makeConstraints{ make in
            make.top.equalTo(self.emailLabel.snp.bottom).offset(7)
            
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.emailDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailField.snp.bottom).offset(5)
            
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            
        }
        
        self.sendEmailButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.successView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize + 20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.successImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        self.successEmailLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.successImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        
        self.successContentLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.successEmailLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.successButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.failView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize + 20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.failImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        self.failHeadLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.successImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        
        self.failContentLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.successEmailLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.failButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
    }
    
}

extension PwdResetPopupViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func checkEnableSendButton() {
        if self.emailValidation {
            self.sendEmailButton.isEnabled = true
            self.sendEmailButton.backgroundColor = self.enableBackColor
            self.sendEmailButton.setTitleColor(self.enableFontColor, for: .normal)
        } else {
            self.sendEmailButton.isEnabled = false
            self.sendEmailButton.backgroundColor = self.unableBackColor
            self.sendEmailButton.setTitleColor(self.unableFontColor, for: .normal)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            emailField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func emailFieldDidChange(_ textField: UITextField) {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
                    floatingLabelTextField.errorMessage = ""
                    self.emailDetailLabel.text = "해당 이메일로 전송하실 수 있습니다."
                    self.emailDetailLabel.textColor = self.successColor
                    self.emailValidation = true
                } else {
                    floatingLabelTextField.errorMessage = " "
                    self.emailDetailLabel.text = "이메일을 다시 확인해주세요."
                    self.emailDetailLabel.textColor = self.failColor
                    self.emailValidation = false
                }
            }
        }
        
        self.checkEnableSendButton()
    }

}

