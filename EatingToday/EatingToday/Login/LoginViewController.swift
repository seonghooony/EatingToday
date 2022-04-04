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
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    fileprivate var currentNonce: String?
    
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
    let headerView = UIView()
    let loginMainView = UIView()
    let footerView = UIView()
    private lazy var stackMainView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.headerView, self.loginMainView, self.footerView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    

    let titleImage = UIImageView()
    
    let titleLabel = UILabel()
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    let idLabel = UILabel()
    let idFeild = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let pwLabel = UILabel()
    let pwFeild = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    
    let loginButton = UIButton()
    
    let findPasswordButton = UIButton()
    
    let loginHeadlineView = UIView()
    let leftlineView = UIView()
    let rightlineView = UIView()
    let lineTextLabel = UILabel()
    
    let googleLoginButton = UIButton()
    let appleLoginButton = UIButton()
    let emailRegisterButton = UIButton()
    
    var emailValidation: Bool = false
    var passwordValidation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    @objc func loginClicked() {
        
        if !self.emailValidation  {
            self.showCustomPopup(title: "알림", message: "이메일을 다시 확인해주세요.")
            
            
            return
            
        } else if !self.passwordValidation{
            self.showCustomPopup(title: "알림", message: "비밀번호는\n8~20자리 영문자,숫자,특수문자 조합입니다.")
            
            
            return
        }
        
        //firebase 이메일/비밀번호 로그인
        let email = idFeild.text ?? ""
        let password = pwFeild.text ?? ""
        
        //로딩바 생성
        self.activityIndicator.startAnimating()
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            
            //로딩바 멈춤
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17011: // 이미 가입한 계정일 경우
                    self.showCustomPopup(title: "알림", message: "존재하지 않는 계정입니다.\n이메일을 다시 확인해주세요.")
                case 17009:
                    self.showCustomPopup(title: "알림", message: "비밀번호가 일치하지 않습니다.\n비밀번호를 다시 확인해주세요.")
                default:
                    self.showCustomPopup(title: "오류", message: error.localizedDescription)
                }
                
            } else {
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                mainVC.modalTransitionStyle = .crossDissolve
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func findPwdBtnTapped() {
        let pwdResetPopupViewController = PwdResetPopupViewController()
        pwdResetPopupViewController.modalPresentationStyle = .overFullScreen
        self.present(pwdResetPopupViewController, animated: true, completion: nil)
    }
     
    @objc func emailResisterClicked() {
        let resisterUserVC = RegisterUserViewController()
        navigationController?.pushViewController(resisterUserVC, animated: true)
    }
    @objc func googleLoginClicked() {
        //로딩바 생성
        self.activityIndicator.startAnimating()
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            return
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.showCustomPopup(title: "오류", message: error.localizedDescription)
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                //로딩바 삭제
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                
                guard let user = authResult?.user, error == nil else {
                    return
                }
                
                pushUserInfo(email: user.email, uid: user.uid, nickname: Auth.auth().currentUser?.displayName ?? "닉네임을 등록해주세요")
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                mainVC.modalTransitionStyle = .crossDissolve
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
        
        self.view.addSubview(self.stackMainView)
        
        self.headerView.backgroundColor = .clear
        self.loginMainView.backgroundColor = .clear
        self.footerView.backgroundColor = .clear
        
        
        view.backgroundColor = .white
        self.view.addSubview(self.activityIndicator)


        self.headerView.addSubview(self.titleImage)
        self.titleImage.image = UIImage(named: "logo_lamen")
        ///<a href="https://www.flaticon.com/kr/free-icons/" title="라면 아이콘">라면 아이콘  제작자: tulpahn - Flaticon</a>

        self.headerView.addSubview(self.titleLabel)
        self.titleLabel.text = "Eatingram"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Marker Felt", size: 35)
        self.titleLabel.textColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)

        self.loginMainView.addSubview(self.idLabel)
        self.idLabel.text = "이메일"
        self.idLabel.textColor = .black
        self.idLabel.font = UIFont(name: "Helvetica Bold", size: 15)

        self.loginMainView.addSubview(self.idFeild)
        self.idFeild.placeholder = "이메일을 입력해주세요."
        self.idFeild.title = ""
        //클리어버튼 생성
        self.idFeild.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.idFeild.autocorrectionType = .no
        //첫글자 자동 대문자
        self.idFeild.autocapitalizationType = .none
        //text키보드모드
        self.idFeild.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.idFeild.isSecureTextEntry = false
        //커서 색상
        self.idFeild.tintColor = titleColor
        //안쪽 텍스트 색상
        self.idFeild.textColor = .black
        //안쪽 텍스트 폰트
        self.idFeild.font = UIFont(name: "Helvetica", size: 18)
        //기본 라인 색상
        self.idFeild.lineColor = inactiveColor
        //선택 라인 색상
        self.idFeild.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.idFeild.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.idFeild.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.idFeild.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.idFeild.selectedLineHeight = 2.0
        //에러 시 색상
        self.idFeild.errorColor = .red
        //에러용 액션 추가
        self.idFeild.addTarget(self, action: #selector(emailFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
        self.idFeild.delegate = self


        self.loginMainView.addSubview(self.pwLabel)
        self.pwLabel.text = "비밀번호"
        self.pwLabel.textColor = .black
        self.pwLabel.font = UIFont(name: "Helvetica Bold", size: 15)

        self.loginMainView.addSubview(self.pwFeild)
        self.pwFeild.placeholder = "비밀번호를 입력해주세요."
        self.pwFeild.title = ""
        //클리어버튼 생성
        self.pwFeild.clearButtonMode = .whileEditing
        //첫글자 자동 대문자
        self.pwFeild.autocapitalizationType = .none
        //text키보드모드
        //self.idFeild.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.pwFeild.isSecureTextEntry = true
        //커서 색상
        self.pwFeild.tintColor = titleColor
        //안쪽 텍스트 색상
        self.pwFeild.textColor = .black
        //안쪽 텍스트 폰트
        self.pwFeild.font = UIFont(name: "Helvetica", size: 18)
        //기본 라인 색상
        self.pwFeild.lineColor = inactiveColor
        //선택 라인 색상
        self.pwFeild.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.pwFeild.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.pwFeild.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.pwFeild.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.pwFeild.selectedLineHeight = 2.0
        //에러 시 색상
        self.pwFeild.errorColor = .red
        //에러용 액션 추가
        self.pwFeild.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭 시 반응 하도록 위임
        self.pwFeild.delegate = self


        self.loginMainView.addSubview(self.loginButton)
        self.loginButton.backgroundColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
        self.loginButton.setTitle("로그인", for: .normal)
        self.loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.loginButton.layer.cornerRadius = 10
        self.loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)

        self.loginMainView.addSubview(self.findPasswordButton)
        self.findPasswordButton.setTitle("비밀번호를 잊으셨나요?", for: .normal)
        self.findPasswordButton.setTitleColor(UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1), for: .normal)
        self.findPasswordButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)!
        self.findPasswordButton.addTarget(self, action: #selector(findPwdBtnTapped), for: .touchUpInside)

        self.footerView.addSubview(self.loginHeadlineView)
        self.loginHeadlineView.addSubview(leftlineView)
        self.leftlineView.backgroundColor = .lightGray

        self.loginHeadlineView.addSubview(lineTextLabel)
        self.lineTextLabel.textColor = .lightGray
        self.lineTextLabel.text = "간편 로그인"
        self.lineTextLabel.font = UIFont(name: "Helvetica", size: 15)

        self.loginHeadlineView.addSubview(rightlineView)
        self.rightlineView.backgroundColor = .lightGray

        self.footerView.addSubview(self.googleLoginButton)
        self.googleLoginButton.setImage(UIImage(named: "logo_google"), for: .normal)
        self.googleLoginButton.setTitle("구글로 로그인", for: .normal)
        self.googleLoginButton.setTitleColor(.black, for: .normal)
        self.googleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.googleLoginButton.backgroundColor = UIColor(displayP3Red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        self.googleLoginButton.layer.cornerRadius = 20
        self.googleLoginButton.addTarget(self, action: #selector(googleLoginClicked), for: .touchUpInside)

        self.footerView.addSubview(self.appleLoginButton)
        self.appleLoginButton.setImage(UIImage(named: "logo_apple"), for: .normal)
        self.appleLoginButton.setTitle("애플로 로그인", for: .normal)
        self.appleLoginButton.setTitleColor(.white, for: .normal)
        self.appleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.appleLoginButton.backgroundColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.appleLoginButton.layer.cornerRadius = 20
        self.appleLoginButton.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)

        self.footerView.addSubview(self.emailRegisterButton)
        self.emailRegisterButton.setTitle("아직 계정이 없어요.", for: .normal)
        self.emailRegisterButton.setTitleColor(.black, for: .normal)
        self.emailRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.emailRegisterButton.addTarget(self, action: #selector(emailResisterClicked), for: .touchUpInside)
    }
    
    func constraintConfigure() {
        let leadingTrailingSize = 30
        
        self.stackMainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            
        }
        self.loginMainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
        }
        
        self.footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        self.titleImage.snp.makeConstraints{ make in
//            make.top.equalToSuperview().offset(90)
//            make.width.height.equalTo(150).priority(752)
//            make.centerX.equalToSuperview()
            
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(150)

        }
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.titleImage.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }

        self.idLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.titleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            
            make.top.equalToSuperview().offset(20)
        }

        self.idFeild.snp.makeConstraints{ make in
            make.top.equalTo(self.idLabel.snp.bottom).offset(0)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        self.pwLabel.snp.makeConstraints { make in
            make.top.equalTo(self.idFeild.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }

        self.pwFeild.snp.makeConstraints{ make in
            make.top.equalTo(self.pwLabel.snp.bottom).offset(0)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        self.loginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.pwFeild.snp.bottom).offset(10)
            make.height.equalTo(60)

            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        self.findPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(self.loginButton.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize + 10)
        }

        self.loginHeadlineView.snp.makeConstraints { make in
//            make.top.equalTo(self.loginButton.snp.bottom).offset(32)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            
            make.top.equalToSuperview().offset(5)
        }

        self.leftlineView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.lineTextLabel.snp.leading).offset(-15)
            make.height.equalTo(1)
        }
        self.lineTextLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.rightlineView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.lineTextLabel.snp.trailing).offset(15)
            make.height.equalTo(1)
        }

        self.googleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.loginHeadlineView.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        self.appleLoginButton.snp.makeConstraints{ make in
            make.top.equalTo(self.googleLoginButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        self.emailRegisterButton.snp.makeConstraints{ make in
            make.top.equalTo(self.appleLoginButton.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
//            make.bottom.equalTo(self.view.snp.bottom)
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
                
                self.pushUserInfo(email: user.email, uid: user.uid, nickname: "닉네임을 등록해주세요")
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                mainVC.modalTransitionStyle = .crossDissolve
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
    
    func checkEnableLoginButton() {
        if self.emailValidation && self.passwordValidation {
            self.showCustomPopup(title: "알림", message: "올바른 이메일 주소가 아닙니다.\n이메일을 다시 확인해주세요.")

            
        } else {
            self.showCustomPopup(title: "알림", message: "비밀번호는 6자리 이상이여야 합니다.")
//            self.showCustomPopup(title: "알림", message: "비밀번호는 8~20자리 영문자,숫자,특수문자 조합입니다.")
            
        }
    }
    
    @objc func emailFieldDidChange(_ textField: UITextField) {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let regex = try? NSRegularExpression(pattern: emailPattern)
        
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
                    floatingLabelTextField.errorMessage = ""
                    
                    self.emailValidation = true
                } else {
                    floatingLabelTextField.errorMessage = ""
                    //floatingLabelTextField.errorMessage = " "
                    
                    self.emailValidation = false
                }
            }
        }
    }

    @objc func passwordFieldDidChange(_ textField: UITextField) {
//      비밀번호 정규식
        //영문+숫자+특수문자
//        let passwordPattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"

//        let regex = try? NSRegularExpression(pattern: passwordPattern)
//
//        if let text = textField.text {
//            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
//                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
//                    floatingLabelTextField.errorMessage = ""
//                    self.passwordValidation = true
//                } else {
//                    floatingLabelTextField.errorMessage = ""
//                    //floatingLabelTextField.errorMessage = " "
//
//                    self.passwordValidation = false
//                }
//            }
//        }
        
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if text.count >= 6 {
                    floatingLabelTextField.errorMessage = ""
                    self.passwordValidation = true
                } else {
                    floatingLabelTextField.errorMessage = ""
                    self.passwordValidation = false
                }
            }
        }
    }
}

