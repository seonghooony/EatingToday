//
//  RegisterUserViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/17.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth
//import FirebaseDatabase
import FirebaseFirestoreSwift
import SkyFloatingLabelTextField

class RegisterUserViewController: UIViewController {
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let successColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let failColor = UIColor.red
    
    let unableBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    let unableFontColor = UIColor(displayP3Red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    
    let enableBackColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
    let enableFontColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
    
    //var ref = Database.database().reference()
    //firestore 용
    let db = Firestore.firestore()
    
    let mainView = UIView()
    let mainScrollView = UIScrollView()
    let scrollContainerView = UIView()
    
    
    
    let titleLabel = UILabel()

    let emailLabel = UILabel()
    let emailField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let emailDetailLabel = UILabel()
    
    let passwordLabel = UILabel()
    let passwordField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let pwdDetailLabel = UILabel()
    
    let pwdConfirmLabel = UILabel()
    let pwdConfirmField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let pwdConfirmDetailLabel = UILabel()
    
    let nicknameLabel = UILabel()
    let nicknameField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 40))
    let nicknameDetailLabel = UILabel()
    
    let registerButton = UIButton()
    
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
    
    var currentKeyboardFrame: CGRect?

    
    var emailValidation: Bool = false
    var passwordValidation: Bool = false
    var pwdConfirmValidation: Bool = false
    var nicknameValidation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
        self.scrollViewEndEditing()
        self.notificationConfigure()
    }
    
    func notificationConfigure() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
            }
        
        //스크롤 가능한 위치를 키보드 높이만큼 아래를 올려줌 (첫번째는 내용을 나타내는 부분을 올려주고, 두번째는 왼쪽 스크롤바 길이를 맞춰줌)
        self.mainScrollView.contentInset.bottom = keyboardFrame.size.height
        self.mainScrollView.scrollIndicatorInsets.bottom = keyboardFrame.size.height
        self.currentKeyboardFrame = keyboardFrame
//        debugPrint(currentKeyboardFrame)
//        debugPrint(self.mainScrollView.contentInset.bottom)

        
    }
    
    @objc private func keyboardWillHide() {
        
        //원래 상태로 다시 되돌려 놓음. 기존 인셋이 0,0,0,0 이여서 제로로 해도 무방
        let contentInset = UIEdgeInsets.zero
        self.mainScrollView.contentInset = contentInset
        self.mainScrollView.scrollIndicatorInsets = contentInset
        
        self.currentKeyboardFrame = nil
    }
    
    
    @objc private func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func registerClicked() {
        
        self.activityIndicator.startAnimating()
        //터치 이벤트 막기
        self.view.isUserInteractionEnabled = false
        
        //firebase 이메일/비밀번호 인증
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let nickname = nicknameField.text ?? ""
        
        //신규 사용자 생성
        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: // 이미 가입한 계정일 경우
                    self.showCustomPopup(title: "알림", message: "이미 존재하는 계정입니다.\n이메일을 다시 확인해주세요.")

                default:
                    self.showCustomPopup(title: "오류", message: error.localizedDescription)
                }
            } else {
                guard let user = authResult?.user, error == nil else {
                    self.showCustomPopup(title: "오류", message: error!.localizedDescription)
                    return
                }
                
                self.pushUserInfo(email: user.email, uid: user.uid, nickname: nickname)
                
                let mainVC = MainViewController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func endEdit() {
        self.view.endEditing(true)
    }
    
    // 스크롤뷰에서 클릭시 endEditing 기능 먹도록 함
    func scrollViewEndEditing() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.endEdit))
        singleTap.numberOfTapsRequired = 1
        singleTap.isEnabled = true
        //멀티터치가 가능한지여부 뷰와 버튼 중복될경우 버튼만 눌리게 하기위해 true
        singleTap.cancelsTouchesInView = true
        self.mainScrollView.addGestureRecognizer(singleTap)
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
//        view.backgroundColor = UIColor(displayP3Red: 248/255, green: 237/255, blue: 227/255, alpha: 1)
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.scrollContainerView.addSubview(self.activityIndicator)
        
        self.navigationItem.title = "회원가입"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "Helvetica Bold", size: 18)]
        let backButtonImage = UIImage(named: "logo_backarrow")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backButtonImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        

        self.view.addSubview(mainScrollView)
        self.mainScrollView.isScrollEnabled = true
        
        
        self.mainScrollView.addSubview(scrollContainerView)
        
       
        self.scrollContainerView.addSubview(self.titleLabel)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.textAlignment = .left

        let titleFont = UIFont(name: "Helvetica Bold", size: 21)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10

        let titleAtrributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]

        self.titleLabel.attributedText = NSAttributedString(
            string: """
                    이팅그램과 함께
                    나만의 먹방 일기를 시작해보세요.
                    """,
            attributes: titleAtrributes
        )
        
        self.scrollContainerView.addSubview(self.emailLabel)
        self.emailLabel.text = "이메일"
        self.emailLabel.textColor = .black
        self.emailLabel.font = UIFont(name: "Helvetica Bold", size: 15)

        self.scrollContainerView.addSubview(self.emailField)
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
        self.emailField.font = UIFont(name: "Helvetica", size: 17)
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
        
        self.scrollContainerView.addSubview(self.emailDetailLabel)
        self.emailDetailLabel.text = ""
        self.emailDetailLabel.textColor = successColor
        self.emailDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.scrollContainerView.addSubview(self.passwordLabel)
        self.passwordLabel.text = "비밀번호"
        self.passwordLabel.textColor = .black
        self.passwordLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.scrollContainerView.addSubview(self.passwordField)
//        self.passwordField.placeholder = "8~20자리 영문자,숫자,특수문자 조합"
        self.passwordField.placeholder = "6자리 이상의 비밀번호"
        self.passwordField.title = ""
        //클리어버튼 생성
        self.passwordField.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.passwordField.autocorrectionType = .no
        //첫글자 자동 대문자
        self.passwordField.autocapitalizationType = .none
        //text키보드모드
        //self.passwordField.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.passwordField.isSecureTextEntry = true
        //커서 색상
        self.passwordField.tintColor = titleColor
        //안쪽 텍스트 색상
        self.passwordField.textColor = .black
        //안쪽 텍스트 폰트
        self.passwordField.font = UIFont(name: "Helvetica", size: 17)
        //기본 라인 색상
        self.passwordField.lineColor = inactiveColor
        //선택 라인 색상
        self.passwordField.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.passwordField.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.passwordField.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.passwordField.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.passwordField.selectedLineHeight = 2.0
        //에러 시 색상
        self.passwordField.errorColor = .red
        //에러용 액션 추가
        self.passwordField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
        self.passwordField.delegate = self
        
        self.scrollContainerView.addSubview(self.pwdDetailLabel)
        self.pwdDetailLabel.text = ""
        self.pwdDetailLabel.textColor = successColor
        self.pwdDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.scrollContainerView.addSubview(self.pwdConfirmLabel)
        self.pwdConfirmLabel.text = "비밀번호 확인"
        self.pwdConfirmLabel.textColor = .black
        self.pwdConfirmLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.scrollContainerView.addSubview(self.pwdConfirmField)
//        self.pwdConfirmField.placeholder = "8~20자리 영문자,숫자,특수문자 조합"
        self.passwordField.placeholder = "6자리 이상의 비밀번호"
        self.pwdConfirmField.title = ""
        //클리어버튼 생성
        self.pwdConfirmField.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.pwdConfirmField.autocorrectionType = .no
        //첫글자 자동 대문자
        self.pwdConfirmField.autocapitalizationType = .none
        //text키보드모드
        //self.pwdConfirmField.keyboardType = .emailAddress
        //text 비밀번호 가림
        self.pwdConfirmField.isSecureTextEntry = true
        //커서 색상
        self.pwdConfirmField.tintColor = titleColor
        //안쪽 텍스트 색상
        self.pwdConfirmField.textColor = .black
        //안쪽 텍스트 폰트
        self.pwdConfirmField.font = UIFont(name: "Helvetica", size: 17)
        //기본 라인 색상
        self.pwdConfirmField.lineColor = inactiveColor
        //선택 라인 색상
        self.pwdConfirmField.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.pwdConfirmField.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.pwdConfirmField.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.pwdConfirmField.lineHeight = 1.0
        //선택 시 아래 선 굵기
        self.pwdConfirmField.selectedLineHeight = 2.0
        //에러 시 색상
        self.pwdConfirmField.errorColor = .red
        //에러용 액션 추가
        self.pwdConfirmField.addTarget(self, action: #selector(pwdConfirmFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
        self.pwdConfirmField.delegate = self
        
        self.scrollContainerView.addSubview(self.pwdConfirmDetailLabel)
        self.pwdConfirmDetailLabel.text = ""
        self.pwdConfirmDetailLabel.textColor = successColor
        self.pwdConfirmDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.scrollContainerView.addSubview(self.nicknameLabel)
        self.nicknameLabel.text = "닉네임"
        self.nicknameLabel.textColor = .black
        self.nicknameLabel.font = UIFont(name: "Helvetica Bold", size: 15)
        
        self.scrollContainerView.addSubview(self.nicknameField)
        self.nicknameField.placeholder = "닉네임을 입력해주세요."
        self.nicknameField.title = ""
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
        self.nicknameField.delegate = self
        
        self.scrollContainerView.addSubview(self.nicknameDetailLabel)
        self.nicknameDetailLabel.text = ""
        self.nicknameDetailLabel.textColor = successColor
        self.nicknameDetailLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.scrollContainerView.addSubview(self.registerButton)
        self.registerButton.isEnabled = false
        self.registerButton.backgroundColor = self.unableBackColor
        self.registerButton.setTitle("회원가입", for: .normal)
        self.registerButton.layer.cornerRadius = 10
        self.registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.registerButton.setTitleColor(self.unableFontColor, for: .normal)
        self.registerButton.addTarget(self, action: #selector(registerClicked), for: .touchUpInside)
        
    }
    func constraintConfigure() {
        let leadingTrailingSize = 30
        let fieldHeight = 40
        let feildsMargin = 40
        
        self.activityIndicator.snp.makeConstraints{ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
        
        self.mainScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            
        }
        
        self.scrollContainerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.mainScrollView.contentLayoutGuide)
            make.width.equalTo(self.mainScrollView.frameLayoutGuide)
//            make.height.equalTo(self.view.snp.height) //마지막 부분에 bottom 제약조건 안걸고 싶으면 고정 높이를 정해줘야함
            
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.height.equalTo(120)
        }
        
        self.emailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.emailField.snp.makeConstraints{ make in
            make.top.equalTo(self.emailLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.emailDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailField.snp.bottom).offset(feildsMargin)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.passwordField.snp.makeConstraints{ make in
            make.top.equalTo(self.passwordLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.pwdDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.pwdConfirmLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordField.snp.bottom).offset(feildsMargin)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.pwdConfirmField.snp.makeConstraints{ make in
            make.top.equalTo(self.pwdConfirmLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.pwdConfirmDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.pwdConfirmField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.pwdConfirmField.snp.bottom).offset(feildsMargin)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.nicknameField.snp.makeConstraints{ make in
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(0)
            make.height.equalTo(fieldHeight)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.nicknameDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            
        }
        
        self.registerButton.snp.makeConstraints{ make in
            make.bottom.equalTo(self.nicknameDetailLabel.snp.top).offset(250)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.bottom.equalToSuperview()
        }
    }
}


extension RegisterUserViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func checkEnableRegisterButton() {
        if self.emailValidation && self.passwordValidation && self.pwdConfirmValidation && self.nicknameValidation  {
            self.registerButton.isEnabled = true
            self.registerButton.backgroundColor = self.enableBackColor
            self.registerButton.setTitleColor(self.enableFontColor, for: .normal)
        } else {
            self.registerButton.isEnabled = false
            self.registerButton.backgroundColor = self.unableBackColor
            self.registerButton.setTitleColor(self.unableFontColor, for: .normal)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let keyboardHeight = currentKeyboardFrame?.size.height {
            //포커싱된 텍스트뷰가 이야기 텍스트뷰일경우
            if textField == self.nicknameField {

                //해당 텍스트 뷰 위치를 찾아 스크롤 포커싱 해줌
                self.mainScrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContainerView.bounds.size.height - self.nicknameField.frame.origin.y + keyboardHeight - 20), animated: true)
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            pwdConfirmField.becomeFirstResponder()
        } else if textField == pwdConfirmField {
            nicknameField.becomeFirstResponder()
        } else if textField == nicknameField {
            nicknameField.resignFirstResponder()
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
                    self.emailDetailLabel.text = "사용하실 수 있는 이메일입니다."
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
        
        self.checkEnableRegisterButton()
    }

    @objc func passwordFieldDidChange(_ textField: UITextField) {

        
        self.pwdConfirmField.text = ""
        self.pwdConfirmField.errorMessage = ""
        self.pwdConfirmDetailLabel.text = ""
        self.pwdConfirmDetailLabel.textColor = self.successColor
        
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if text.count >= 6 {
                    floatingLabelTextField.errorMessage = ""
                    self.pwdDetailLabel.text = "사용하실 수 있는 비밀번호입니다."
                    self.pwdDetailLabel.textColor = self.successColor
                    self.passwordValidation = true
                } else {
                    floatingLabelTextField.errorMessage = " "
                    self.pwdDetailLabel.text = "비밀번호는 6자리 이상이여야 합니다."
                    self.pwdDetailLabel.textColor = self.failColor
                    self.passwordValidation = false
                }
            }
        }
//        let passwordPattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
//
//        let regex = try? NSRegularExpression(pattern: passwordPattern)
        
//        if let text = textField.text {
//            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
//                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
//                    floatingLabelTextField.errorMessage = ""
//                    self.pwdDetailLabel.text = "사용하실 수 있는 비밀번호입니다."
//                    self.pwdDetailLabel.textColor = self.successColor
//                    self.passwordValidation = true
//                } else {
//                    floatingLabelTextField.errorMessage = " "
//                    self.pwdDetailLabel.text = "비밀번호는 8~20자리 영문자,숫자,특수문자 조합입니다."
//                    self.pwdDetailLabel.textColor = self.failColor
//                    self.passwordValidation = false
//                }
//            }
//        }
        self.checkEnableRegisterButton()
    }
    
    @objc func pwdConfirmFieldDidChange(_ textField: UITextField) {
        
        if self.passwordValidation {
            if let text = textField.text {
                if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                    if text.count == self.passwordField.text?.count {
                        if text == self.passwordField.text {
                            floatingLabelTextField.errorMessage = ""
                            self.pwdConfirmDetailLabel.text = "비밀번호가 일치합니다."
                            self.pwdConfirmDetailLabel.textColor = self.successColor
                            self.pwdConfirmValidation = true
                        } else {
                            floatingLabelTextField.errorMessage = " "
                            self.pwdConfirmDetailLabel.text = "비밀번호가 일치하지 않습니다."
                            self.pwdConfirmDetailLabel.textColor = self.failColor
                            self.pwdConfirmValidation = false
                        }
                    }
                }
            }
        } else {
            self.passwordField.becomeFirstResponder()
            self.pwdConfirmField.text = ""
            self.pwdConfirmField.errorMessage = ""
            self.pwdConfirmDetailLabel.text = ""
            self.pwdConfirmDetailLabel.textColor = self.successColor
        }
        
        
        self.checkEnableRegisterButton()
    }
    
    @objc func nicknameFieldDidChange(_ textField: UITextField) {
        
        let nicknamePattern = "^[가-힣A-Za-z0-9]{4,20}$"
        
        let regex = try? NSRegularExpression(pattern: nicknamePattern)
        
        
        
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if let _ = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
                    floatingLabelTextField.errorMessage = ""
                    self.nicknameDetailLabel.text = "사용하실 수 있는 닉네임 입니다."
                    self.nicknameDetailLabel.textColor = self.successColor
                    self.nicknameValidation = true
                } else {
                    floatingLabelTextField.errorMessage = " "
                    self.nicknameDetailLabel.text = "닉네임은 4~20자리 한글,영문자,숫자만 가능합니다."
                    self.nicknameDetailLabel.textColor = self.failColor
                    self.nicknameValidation = false
                }
            }
        }
        
        self.checkEnableRegisterButton()
    }
}

