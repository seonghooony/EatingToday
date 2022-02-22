//
//  ResisterUserViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/17.
//

import UIKit
import Firebase
import FirebaseAuth
//import FirebaseDatabase
import FirebaseFirestoreSwift

class ResisterUserViewController: UIViewController {
    
    //var ref = Database.database().reference()
    //firestore 용
    let db = Firestore.firestore()
    
    let titleLabel = UILabel()

    let emailField = UITextField()
    let passwordField = UITextField()
    let nicknameField = UITextField()
    
    let resisterButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    @objc func resisterClicked() {
        
        //firebase 이메일/비밀번호 인증
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let nickname = nicknameField.text ?? ""
        
        //신규 사용자 생성
        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: // 이미 가입한 계정일 경우
                    self.showErrorAlert(errorMsg: "이미 존재하는 계정입니다.")
                default:
                    self.showErrorAlert(errorMsg: error.localizedDescription)
                }
            } else {
                guard let user = authResult?.user, error == nil else {
                    self.showErrorAlert(errorMsg: error!.localizedDescription)
                    return
                }
                
                self.pushUserInfo(email: user.email, uid: user.uid, nickname: nickname)
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    private func pushUserInfo(email: String?, uid: String, nickname: String) {
        
        db.collection("users").getDocuments{ snapshot, _ in
            let batch = self.db.batch()
            let userInfo = self.db.collection("users").document(uid)
            let userData = UserInfo(email: email, nickname: nickname, profileImageURL: "")
            do {
                try batch.setData(from: userData, forDocument: userInfo)
            }catch let error {
                print("ERROR writing userInfo to Firestore \(error.localizedDescription)")
            }
            batch.commit()
            
        }
    }
    
    func showErrorAlert(errorMsg: String) {
        let alert = UIAlertController(
            title: "오류",
            message: """
            \(errorMsg)
            """,
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewConfigure() {
        view.backgroundColor = UIColor(displayP3Red: 248/255, green: 237/255, blue: 227/255, alpha: 1)
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.text = "Eatingram"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Marker Felt", size: 25)
        self.titleLabel.textColor = UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1)

        self.view.addSubview(self.emailField)
        self.emailField.delegate = self
        self.emailField.keyboardType = .emailAddress
        self.emailField.backgroundColor = UIColor(displayP3Red: 251/255, green: 248/255, blue: 241/255, alpha: 1)
        self.emailField.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        self.emailField.autocapitalizationType = .none
        self.emailField.layer.cornerRadius = 7
        self.emailField.addLeftPadding()
        
        self.view.addSubview(self.passwordField)
        self.passwordField.delegate = self
        self.passwordField.backgroundColor = UIColor(displayP3Red: 251/255, green: 248/255, blue: 241/255, alpha: 1)
        self.passwordField.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        self.passwordField.isSecureTextEntry = true
        self.passwordField.autocapitalizationType = .none
        self.passwordField.layer.cornerRadius = 7
        self.passwordField.addLeftPadding()
        
        self.view.addSubview(self.nicknameField)
        self.nicknameField.delegate = self
        self.nicknameField.backgroundColor = UIColor(displayP3Red: 251/255, green: 248/255, blue: 241/255, alpha: 1)
        self.nicknameField.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.nicknameField.attributedPlaceholder = NSAttributedString(string: "Nickname", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        self.nicknameField.autocapitalizationType = .none
        self.nicknameField.layer.cornerRadius = 7
        self.nicknameField.addLeftPadding()
        
        self.view.addSubview(self.resisterButton)
        self.resisterButton.backgroundColor = UIColor(displayP3Red: 33/255, green: 159/255, blue: 148/255, alpha: 1)
        self.resisterButton.setTitle("회원가입", for: .normal)
        self.resisterButton.layer.cornerRadius = 10
        self.resisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.resisterButton.addTarget(self, action: #selector(resisterClicked), for: .touchUpInside)
        
    }
    func constraintConfigure() {
    
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }
        
        self.emailField.snp.makeConstraints{ make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(60)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        self.passwordField.snp.makeConstraints{ make in
            make.top.equalTo(self.emailField.snp.bottom).offset(10)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        self.nicknameField.snp.makeConstraints{ make in
            make.top.equalTo(self.passwordField.snp.bottom).offset(10)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        self.resisterButton.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
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

extension ResisterUserViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            nicknameField.becomeFirstResponder()
        } else if textField == nicknameField {
            nicknameField.resignFirstResponder()
        }
        
        return true
    }
}
