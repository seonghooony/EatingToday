//
//  ProfileDetailModifyViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/04/13.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import SkyFloatingLabelTextField

class ProfileDetailModifyViewController: UIViewController {
    
    var currentNickname: String?
    
    //firestore 용
    let db = Firestore.firestore()
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let successColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let failColor = UIColor.red
    
    let unableBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    let unableFontColor = UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    
    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.darkGray
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        // Start animation.
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        return activityIndicator
        
    }()
    
    let nicknameLabel = UILabel()
    let nicknameField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let nicknameDetailLabel = UILabel()
    let nicknameModifyButton = UIButton()
    
    let passwordLabel = UILabel()
    let emailLabel = UILabel()
    let emailPwdModifyButton = UIButton()
    

    
    
    var nicknameValidation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    @objc private func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func nicknameFieldDidChange(_ textField: UITextField) {
        
        let nicknamePattern = "^[가-힣A-Za-z0-9]{2,10}$"
        
        let regex = try? NSRegularExpression(pattern: nicknamePattern)
        
        
        
        if let text = textField.text, text.count > 0 {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
                    floatingLabelTextField.errorMessage = ""
                    self.nicknameDetailLabel.text = "사용하실 수 있는 닉네임 입니다."
                    self.nicknameDetailLabel.textColor = self.successColor
                    self.nicknameValidation = true
                } else {
                    floatingLabelTextField.errorMessage = " "
                    self.nicknameDetailLabel.text = "닉네임은 2~10자리 한글,영문자,숫자만 가능합니다."
                    self.nicknameDetailLabel.textColor = self.failColor
                    self.nicknameValidation = false
                }
            }
        } else if let text = textField.text, text.count == 0 {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                floatingLabelTextField.errorMessage = ""
                self.nicknameDetailLabel.text = ""
                self.nicknameDetailLabel.textColor = self.successColor
                self.nicknameValidation = false
            }
            
        }
        
        self.checkEnableModifyButton()
    }
    
    @objc func nicknameModifyClicked() {
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        self.nicknameField.resignFirstResponder()
        if let uid = Auth.auth().currentUser?.uid {
            let batch = db.batch()
            let userRef = db.collection("users").document(uid)
            batch.updateData(["nickname" : (self.nicknameField.text ?? "닉네임오류") as String], forDocument: userRef)
            
            batch.commit() { error in
                if let error = error {
                    print("ERROR Modify nickname : \(error.localizedDescription)")
                } else {
                    self.currentNickname = self.nicknameField.text
                    self.nicknameField.placeholder = self.currentNickname
                    self.nicknameField.text = ""
                    self.nicknameDetailLabel.text = ""
                    self.nicknameDetailLabel.textColor = self.successColor
                    self.nicknameValidation = false
                    self.checkEnableModifyButton()
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.showCustomPopup(title: "알림", message: "닉네임이 변경되었습니다.")
                }
            }
        }
        
    }
    
    @objc func passwordModifyClicked() {
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        let email = Auth.auth().currentUser?.email
        //비밀번호를 리셋할 수 있는 이메일을 보내줌.
        if let email = email {
            Auth.auth().languageCode = "ko"
            Auth.auth().sendPasswordReset(withEmail: email) { error in
//                debugPrint("이메일 리셋 에러 : \(error)")
                
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                if let error = error {
                    let code = (error as NSError).code
                    switch code {
                    //가입된 계정이 아닐 경우
                    case 17011:
                        self.showCustomPopup(title: "알림", message: "가입되어 있지 않은 이메일입니다.")
                        
                        
                    default:
//                        self.emailDetailLabel.text = "에러"
                        self.showCustomPopup(title: "알림", message: "알수 없는 에러.\n\(error.localizedDescription)")
                    }
                    
                } else {
                    //성공시 화면전환
                    self.showCustomPopup(title: "알림", message: "해당 이메일 주소로\n비밀번호 변경 이메일을 보내드렸습니다.\n이메일을 확인해주세요.")
                }
                
            }
        }
    }
    
    func checkEnableModifyButton() {
        if self.nicknameValidation  {
            self.nicknameModifyButton.isEnabled = true
            self.nicknameModifyButton.backgroundColor = self.enableBackColor
            self.nicknameModifyButton.setTitleColor(self.enableFontColor, for: .normal)
        } else {
            self.nicknameModifyButton.isEnabled = false
            self.nicknameModifyButton.backgroundColor = self.unableBackColor
            self.nicknameModifyButton.setTitleColor(self.unableFontColor, for: .normal)
        }
    }
    
    private func viewConfigure() {
        self.view.backgroundColor = .white
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationItem.title = "내 정보 수정"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "Helvetica Bold", size: 18)]
        let backButtonImage = UIImage(named: "logo_backarrow")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backButtonImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
        self.view.addSubview(self.activityIndicator)
        
        self.view.addSubview(self.nicknameLabel)
        self.nicknameLabel.text = "닉네임 변경"
        self.nicknameLabel.textColor = .black
        self.nicknameLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.view.addSubview(self.nicknameField)
        if let currentNickname = self.currentNickname {
            self.nicknameField.placeholder = currentNickname
        }
        self.nicknameField.title = ""
        
        
        self.nicknameField.placeholderColor = .darkGray
        
        //클리어버튼 생성
        self.nicknameField.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.nicknameField.autocorrectionType = .no
        //첫글자 자동 대문자
        self.nicknameField.autocapitalizationType = .none
        //text키보드모드
        //self.nicknameField.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.nicknameField.isSecureTextEntry = false
        //커서 색상
        self.nicknameField.tintColor = titleColor
        //안쪽 텍스트 색상
        self.nicknameField.textColor = .black
        //안쪽 텍스트 폰트
        self.nicknameField.font = UIFont(name: "Helvetica", size: 17)
        //기본 라인 색상
        self.nicknameField.lineColor = inactiveColor
        //선택 라인 색상
        self.nicknameField.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.nicknameField.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.nicknameField.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.nicknameField.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.nicknameField.selectedLineHeight = 2.0
        //에러 시 색상
        self.nicknameField.errorColor = .red
        //에러용 액션 추가
        self.nicknameField.addTarget(self, action: #selector(nicknameFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
//        self.nicknameField.delegate = self
        
        self.view.addSubview(self.nicknameDetailLabel)
        self.nicknameDetailLabel.text = ""
        self.nicknameDetailLabel.textColor = successColor
        self.nicknameDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.view.addSubview(self.nicknameModifyButton)
        self.nicknameModifyButton.setTitle("변경", for: .normal)
        self.nicknameModifyButton.backgroundColor = .red
        self.nicknameModifyButton.layer.cornerRadius = 10
        self.nicknameModifyButton.isEnabled = false
        self.nicknameModifyButton.backgroundColor = self.unableBackColor
        self.nicknameModifyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.nicknameModifyButton.setTitleColor(self.unableFontColor, for: .normal)
        self.nicknameModifyButton.addTarget(self, action: #selector(nicknameModifyClicked), for: .touchUpInside)
        
        self.view.addSubview(self.passwordLabel)
        self.passwordLabel.text = "비밀번호 변경"
        self.passwordLabel.textColor = .black
        self.passwordLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.view.addSubview(self.emailLabel)
        if let email = Auth.auth().currentUser?.email {
            self.emailLabel.text = "\(email)"
        }
        self.emailLabel.textColor = .darkGray
        self.emailLabel.font = UIFont(name: "Helvetica Bold", size: 17)
        self.view.addSubview(self.emailPwdModifyButton)
        self.emailPwdModifyButton.setTitle("변경", for: .normal)
        self.emailPwdModifyButton.backgroundColor = .red
        self.emailPwdModifyButton.layer.cornerRadius = 10
        self.emailPwdModifyButton.isEnabled = true
        self.emailPwdModifyButton.backgroundColor = self.enableBackColor
        self.emailPwdModifyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.emailPwdModifyButton.setTitleColor(self.enableFontColor, for: .normal)
        self.emailPwdModifyButton.addTarget(self, action: #selector(passwordModifyClicked), for: .touchUpInside)
    }
    
    private func constraintConfigure() {
        
        let leadingTrailingSize = 30
        let fieldHeight = 40
        let feildsMargin = 40
        
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.nicknameField.snp.makeConstraints{ make in
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalTo(self.nicknameModifyButton.snp.leading).offset(-15)
            
        }
        
        
        self.nicknameDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            
        }
        
        self.nicknameModifyButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.nicknameField.snp.bottom)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.height.equalTo(35)
            make.width.equalTo(80)
            
        }
        
        self.passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameField.snp.bottom).offset(feildsMargin)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.emailLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.passwordLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalTo(self.emailPwdModifyButton.snp.leading).offset(-15)
        }
        
        self.emailPwdModifyButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.emailLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.height.equalTo(35)
            make.width.equalTo(80)
            
        }
        
    }
    
    
}
