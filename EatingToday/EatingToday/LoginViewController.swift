//
//  LoginViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/16.
//

import UIKit
import SnapKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    let titleImage = UIImageView()
    
    let titleLabel = UILabel()
    let idFeild = UITextField()
    let pwFeild = UITextField()
    let loginButton = UIButton()
    
    let emailRegisterButton = UIButton()
    let googleLoginButton = UIButton()
    let appleLoginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    func viewConfigure() {
        view.backgroundColor = UIColor(displayP3Red: 248/255, green: 237/255, blue: 227/255, alpha: 1)
        
        self.view.addSubview(self.titleImage)
        self.titleImage.image = UIImage(systemName: "pencil")
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.text = "EatingToday"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Chalkduster", size: 25)
        self.titleLabel.textColor = UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1)
        
        self.view.addSubview(self.idFeild)
        self.idFeild.backgroundColor = UIColor(displayP3Red: 251/255, green: 248/255, blue: 241/255, alpha: 1)
        self.idFeild.placeholder = "Email"
        self.view.addSubview(self.pwFeild)
        self.pwFeild.backgroundColor = UIColor(displayP3Red: 251/255, green: 248/255, blue: 241/255, alpha: 1)
        self.pwFeild.placeholder = "Password"
        self.pwFeild.isSecureTextEntry = true
        
        self.view.addSubview(self.loginButton)
        self.loginButton.backgroundColor = UIColor(displayP3Red: 221/255, green: 74/255, blue: 72/255, alpha: 1)
        self.loginButton.setTitle("로그인", for: .normal)
        self.loginButton.layer.cornerRadius = 5
        
        self.view.addSubview(self.googleLoginButton)
        self.googleLoginButton.setImage(UIImage(named: "logo_google"), for: .normal)
        self.googleLoginButton.setTitle("구글로 로그인", for: .normal)
        self.googleLoginButton.backgroundColor = UIColor(displayP3Red: 236/255, green: 179/255, blue: 144/255, alpha: 1)
        self.googleLoginButton.layer.cornerRadius = 15
        
        self.view.addSubview(self.appleLoginButton)
        self.appleLoginButton.setImage(UIImage(named: "logo_apple"), for: .normal)
        self.appleLoginButton.setTitle("애플로 로그인", for: .normal)
        self.appleLoginButton.backgroundColor = UIColor(displayP3Red: 236/255, green: 179/255, blue: 144/255, alpha: 1)
        self.appleLoginButton.layer.cornerRadius = 15
        
        
        
    }
    
    func constraintConfigure() {
//        self.LoginView.snp.makeConstraints{ make in
//            make.top.equalTo(self.view)
//            make.width.equalTo(self.view)
//            make.height.equalTo(self.view)
//        }
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
            make.top.equalTo(self.pwFeild.snp.bottom).offset(10)
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
            make.top.equalTo(self.googleLoginButton.snp.bottom).offset(10)
            make.height.equalTo(35)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
}
