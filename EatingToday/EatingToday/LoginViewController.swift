//
//  LoginViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/16.
//

import UIKit
import SnapKit
import Firebase
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let titleImage = UIImageView()
    
    let titleLabel = UILabel()
    let idFeild = UITextField()
    let pwFeild = UITextField()
    let loginButton = UIButton()
    
    let googleLoginButton = UIButton()
    let appleLoginButton = UIButton()
    let emailRegisterButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    @objc func loginClicked() {
        //firebase 이메일/비밀번호 로그인
        let email = idFeild.text ?? ""
        let password = pwFeild.text ?? ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(errorMsg: error.localizedDescription)
            } else {
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
     
    @objc func emailResisterClicked() {
        let resisterUserVC = ResisterUserViewController()
        navigationController?.pushViewController(resisterUserVC, animated: true)
    }
    @objc func googleLoginClicked() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                self.showErrorAlert(errorMsg: error.localizedDescription)
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                guard let user = authResult?.user, error == nil else {
                    return
                }
                
                pushUserInfo(email: user.email, uid: user.uid, nickname: "닉네임을 등록해주세요.")
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self?.present(mainVC, animated: true, completion: nil)
                
            }
        }
        
    }
    
    private func pushUserInfo(email: String?, uid: String, nickname: String) {
        let usersDocument = db.collection("users").document(uid)
        usersDocument.getDocument{ (document, err) in
            if let document = document, document.exists {
                print("already exist document")
            } else {
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
        view.backgroundColor = UIColor(displayP3Red: 200/255, green: 92/255, blue: 92/255, alpha: 1)
        
        self.view.addSubview(self.titleImage)
        self.titleImage.image = UIImage(systemName: "pencil")
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.text = "EatingToday"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Chalkduster", size: 25)
        self.titleLabel.textColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        self.view.addSubview(self.idFeild)
        self.idFeild.backgroundColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.idFeild.placeholder = "Email"
        self.idFeild.autocapitalizationType = .none
        self.idFeild.layer.cornerRadius = 3
        
        self.view.addSubview(self.pwFeild)
        self.pwFeild.backgroundColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.pwFeild.placeholder = "Password"
        self.pwFeild.isSecureTextEntry = true
        self.pwFeild.autocapitalizationType = .none
        self.pwFeild.layer.cornerRadius = 3
        
        self.view.addSubview(self.loginButton)
        self.loginButton.backgroundColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
        self.loginButton.setTitle("로그인", for: .normal)
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
        
        self.view.addSubview(self.googleLoginButton)
        self.googleLoginButton.setImage(UIImage(named: "logo_google"), for: .normal)
        self.googleLoginButton.setTitle("구글로 로그인", for: .normal)
        self.googleLoginButton.setTitleColor(.black, for: .normal)
        self.googleLoginButton.backgroundColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.googleLoginButton.layer.cornerRadius = 15
        self.googleLoginButton.addTarget(self, action: #selector(googleLoginClicked), for: .touchUpInside)
        
        self.view.addSubview(self.appleLoginButton)
        self.appleLoginButton.setImage(UIImage(named: "logo_apple"), for: .normal)
        self.appleLoginButton.setTitle("애플로 로그인", for: .normal)
        self.appleLoginButton.setTitleColor(.white, for: .normal)
        self.appleLoginButton.backgroundColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.appleLoginButton.layer.cornerRadius = 15
        
        self.view.addSubview(self.emailRegisterButton)
        self.emailRegisterButton.setTitle("아직 계정이 없어요.", for: .normal)
        self.emailRegisterButton.setTitleColor(.white, for: .normal)
        self.emailRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.emailRegisterButton.addTarget(self, action: #selector(emailResisterClicked), for: .touchUpInside)
    }
    
    func constraintConfigure() {
        self.titleImage.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(150)
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.titleImage.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }

        self.idFeild.snp.makeConstraints{ make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(60)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.pwFeild.snp.makeConstraints{ make in
            make.top.equalTo(self.idFeild.snp.bottom).offset(5)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.loginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.pwFeild.snp.bottom).offset(8)
            make.height.equalTo(40)

            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        self.googleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.loginButton.snp.bottom).offset(50)
            make.height.equalTo(35)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.appleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.googleLoginButton.snp.bottom).offset(8)
            make.height.equalTo(35)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        self.emailRegisterButton.snp.makeConstraints{ make in
            make.top.equalTo(self.appleLoginButton.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
}
