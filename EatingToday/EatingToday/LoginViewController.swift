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
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    fileprivate var currentNonce: String?
    
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
    @objc func appleLoginClicked() {
        self.startSignInWithAppleFlow()
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
        self.titleLabel.text = "Eatingram"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Marker Felt", size: 35)
        self.titleLabel.textColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        self.view.addSubview(self.idFeild)
        self.idFeild.delegate = self
        self.idFeild.keyboardType = .emailAddress
        self.idFeild.backgroundColor = UIColor(displayP3Red: 248/255, green: 237/255, blue: 227/255, alpha: 1)
        self.idFeild.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.idFeild.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        self.idFeild.autocapitalizationType = .none
        self.idFeild.layer.cornerRadius = 10
        self.idFeild.withImage(direction: .Left, image: UIImage(systemName: "person")!, colorSeparator: .clear, colorBorder: .clear)
        
        
        self.view.addSubview(self.pwFeild)
        self.pwFeild.delegate = self
        self.pwFeild.backgroundColor = UIColor(displayP3Red: 248/255, green: 237/255, blue: 227/255, alpha: 1)
        self.pwFeild.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.pwFeild.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        self.pwFeild.isSecureTextEntry = true
        self.pwFeild.autocapitalizationType = .none
        self.pwFeild.layer.cornerRadius = 10
        self.pwFeild.withImage(direction: .Left, image: UIImage(systemName: "key")!, colorSeparator: .clear, colorBorder: .clear)
        
        
        self.view.addSubview(self.loginButton)
        self.loginButton.backgroundColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
        self.loginButton.setTitle("로그인", for: .normal)
        self.loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.loginButton.layer.cornerRadius = 10
        self.loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
        
        self.view.addSubview(self.googleLoginButton)
        self.googleLoginButton.setImage(UIImage(named: "logo_google"), for: .normal)
        self.googleLoginButton.setTitle("구글로 로그인", for: .normal)
        self.googleLoginButton.setTitleColor(.black, for: .normal)
        self.googleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.googleLoginButton.backgroundColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.googleLoginButton.layer.cornerRadius = 20
        self.googleLoginButton.addTarget(self, action: #selector(googleLoginClicked), for: .touchUpInside)
        
        self.view.addSubview(self.appleLoginButton)
        self.appleLoginButton.setImage(UIImage(named: "logo_apple"), for: .normal)
        self.appleLoginButton.setTitle("애플로 로그인", for: .normal)
        self.appleLoginButton.setTitleColor(.white, for: .normal)
        self.appleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.appleLoginButton.backgroundColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.appleLoginButton.layer.cornerRadius = 20
        self.appleLoginButton.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)
        
        self.view.addSubview(self.emailRegisterButton)
        self.emailRegisterButton.setTitle("아직 계정이 없어요.", for: .normal)
        self.emailRegisterButton.setTitleColor(.white, for: .normal)
        self.emailRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
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
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.pwFeild.snp.makeConstraints{ make in
            make.top.equalTo(self.idFeild.snp.bottom).offset(5)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.loginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.pwFeild.snp.bottom).offset(6)
            make.height.equalTo(60)

            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        self.googleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.loginButton.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        self.appleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.googleLoginButton.snp.bottom).offset(10)
            make.height.equalTo(50)
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


extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                ///Main 화면으로 보내기
                
                guard let user = authResult?.user, error == nil else {
                    return
                }
                
                self.pushUserInfo(email: user.email, uid: user.uid, nickname: "닉네임을 등록해주세요.")
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
}

//Apple Sign in
extension LoginViewController {
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension UITextField {
    enum Direction {
        case Left
        case Right
    }

    // add image to textfield
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.borderWidth = CGFloat(0.5)
        view.layer.borderColor = colorBorder.cgColor
        view.tintColor = .gray
        mainView.addSubview(view)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
        view.addSubview(imageView)

        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)

        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }

        self.layer.borderColor = colorBorder.cgColor
        self.layer.borderWidth = CGFloat(0.5)
    }
}

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idFeild {
            pwFeild.becomeFirstResponder()
        } else if textField == pwFeild {
            pwFeild.resignFirstResponder()
            self.loginClicked()
        }
        
        return true
    }
}
