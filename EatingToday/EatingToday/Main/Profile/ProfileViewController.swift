//
//  ProfileViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore
import AcknowList

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var nickname: String?
    
    let customGray1 = UIColor(displayP3Red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    
    let headerView = UIView()
    let titleLabel = UILabel()
    let emailLabel = UILabel()
    
    let mainView = UIView()
    let optionTableView = UITableView()
    
    let footerView = UIView()
    let licenseLabelButton = UIButton()
    let gitUrlButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.getUserNickname()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    func getUserNickname() {

        if let uid = Auth.auth().currentUser?.uid {
            let userDiariesList = db.collection("users").document(uid)
            
            userDiariesList.getDocument { [weak self] document, error in
                if let error = error {
                    print("Error get Diary List : \(error.localizedDescription)")
                    return
                }
                
//                print("\(result?.documentID) : \(result?.data())")
                
                if let documentData = document?.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                        let userDiaryInfo = try JSONDecoder().decode(UserDiaryInfo.self, from: jsonData)
                        if let nickname = userDiaryInfo.nickname {
                            
                            self?.nickname = nickname
                            var headerString = ""
                            let titleFont = UIFont(name: "Helvetica Bold", size: 21)
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineSpacing = 10
                            headerString = "\(nickname) 님, 이팅그램과 함께\n즐거운 시간을 보내고 계신가요?"
                            
                            let titleAtrributes: [NSAttributedString.Key: Any] = [
                                .font: titleFont,
                                .foregroundColor: UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1),
                                .paragraphStyle: paragraphStyle
                            ]
                            
                            let attributeStr = NSMutableAttributedString(string: headerString, attributes: titleAtrributes)
                                
                            
                            
                            attributeStr.addAttribute(.foregroundColor, value: UIColor.blue, range: (headerString as NSString).range(of: nickname))
                                
                            self?.titleLabel.attributedText = attributeStr
                            
                        } else {
                            print("유저 내 닉네임없음")
                        }
                        
                        
                    } catch let error {
                        print("ERROR JSON Parsing \(error)")
                        
                    }
                } else {
                    print("유저 정보 없음")
                }

            }
        } else {
            print("로그아웃 상태")
            let titleFont = UIFont(name: "Helvetica Bold", size: 21)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            
            var headerString = "로그아웃 상태입니다.\n다시 로그인 해주세요."
            
            let titleAtrributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1),
                .paragraphStyle: paragraphStyle
            ]
            let attributeStr = NSMutableAttributedString(string: headerString, attributes: titleAtrributes)
            self.titleLabel.attributedText = attributeStr
        }
    }
    
    private func viewConfigure() {
        self.view.backgroundColor = customGray1
        self.view.addSubview(self.headerView)
        self.headerView.backgroundColor = .white
        self.headerView.addSubview(self.titleLabel)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.textAlignment = .left
        
        self.headerView.addSubview(self.emailLabel)
        if let email = Auth.auth().currentUser?.email {
            self.emailLabel.text = "\(email)"
        }
        self.emailLabel.textColor = .lightGray
        self.emailLabel.font = UIFont(name: "Helvetica Bold", size: 13)
        
        self.mainView.backgroundColor = .clear
        self.view.addSubview(self.mainView)
        
        self.optionTableView.delegate = self
        self.optionTableView.dataSource = self
        self.optionTableView.register(settingOptionTableViewCell.self, forCellReuseIdentifier: "settingOptionTableViewCell")
        self.optionTableView.backgroundColor = .clear
        self.mainView.addSubview(self.optionTableView)
        
        self.footerView.backgroundColor = .clear
        self.view.addSubview(self.footerView)
        self.footerView.addSubview(self.licenseLabelButton)
        self.footerView.addSubview(self.gitUrlButton)
    
    }
    
    private func constraintConfigure() {
        
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.2)
            
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(20)
        }
        
        self.emailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.4)
            
        }
        
        self.optionTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.footerView.snp.makeConstraints { make in
            make.top.equalTo(self.mainView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.3)
        
        }
    
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingOptionTableViewCell", for: indexPath) as? settingOptionTableViewCell else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            cell.optionNameLabel.text = "내 정보 수정"
            
        } else if indexPath.row == 1 {
            cell.optionNameLabel.text = "사용한 라이브러리 license 보기"
        } else if indexPath.row == 2 {
            cell.optionNameLabel.text = "로그아웃"
            cell.optionNameLabel.textColor = .red
            cell.arrowImageView.isHidden = true
            
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            print("내정보 수정하러가야함")
            
        } else if indexPath.row == 1 {
            let acknowList = AcknowListViewController(fileNamed: "Pods-EatingToday-acknowledgements")
            navigationController?.pushViewController(acknowList, animated: true)
            
        } else if indexPath.row == 2 {
            print("로그아웃 해야함")
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("ERROR signing out: \(signOutError)")
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            
            
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
//            navigationController.modalPresentationStyle = .fullScreen
//            navigationController.modalTransitionStyle = .crossDissolve
//            self.present(navigationController, animated: true, completion: nil)
        
            self.view.window?.rootViewController = navigationController
        
        }
        
    }
}
