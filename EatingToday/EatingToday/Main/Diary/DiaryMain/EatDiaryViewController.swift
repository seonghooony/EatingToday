//
//  EatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore

class EatDiaryViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var currentPage = 1
    
    
    let headView = UIView()
    let titleButton = UIButton()
    let diaryAddButton = UIButton()
    let mainView = UIView()
    private lazy var boardTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .black
//        tableView.separatorStyle = .none
//        tableView.separatorColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EatTableViewCell.self, forCellReuseIdentifier: "EatTableViewCell")
        
        return tableView
    }()
    
    var userDiaries = Array<String>()
    var diaryInfos = Array<DiaryInfo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.getUserDiaryList()
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @objc func addDairyButtonTapped() {
        print("클릭")
        let addDairyVC = AddEatDiaryViewController()
//        addDairyVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        self.present(addDairyVC, animated: true, completion: nil)
        
        
        navigationController?.pushViewController(addDairyVC, animated: true)
    }
    
    
    
    func getUserDiaryList() {
        self.userDiaries.removeAll()
        self.diaryInfos.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid {
            let userDiariesList = db.collection("users").document(uid)
            
            userDiariesList.getDocument { document, error in
                if let error = error {
                    print("Error get Diary List : \(error.localizedDescription)")
                    return
                }
                
//                print("\(result?.documentID) : \(result?.data())")
                
                if let documentData = document?.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                        let userDiaryInfo = try JSONDecoder().decode(UserDiaryInfo.self, from: jsonData)
                        if let diaryList = userDiaryInfo.diary {
                            self.userDiaries = diaryList
                           
                            self.getDiaryInfo()
                        }
                        
                        
                        
                        
                        
                        
                    } catch let error {
                        print("ERROR JSON Parsing \(error)")
                        
                    }
                }

            }
        }
        
        
    }
    
    func getDiaryInfo() {
        
        if self.userDiaries.count > 0 {
            
            
            for i in 0..<self.userDiaries.count {
                let diaryInfoDoc = self.db.collection("diaries").document(self.userDiaries[i])
                
                diaryInfoDoc.getDocument { document, error in
                    if let error = error {
                        print("Error get Diary Info : \(error.localizedDescription)")
                        return
                    }
                    //print("document?.data() : \(document?.data())")
                    
                    if let documentData = document?.data() {

                        do {

                            let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                            if let diaryInfo = try? JSONDecoder().decode(DiaryInfo.self, from: jsonData) {
                                
                                self.diaryInfos.append(diaryInfo)
//                                print("0: \(self.diaryInfos)")
                                print("넣음")
                                
                            }
                            
                        } catch let error {
                            print("ERROR JSON Parsing \(error)")

                        }

                        self.boardTableView.reloadData()
                        print("다시만듬")
                        
                    }
                }
            }
                
            
            
            
            
            
        }
        
        
        
    }
    
    func viewConfigure() {
        
        self.view.addSubview(self.headView)
        self.headView.backgroundColor = .white
    
        self.headView.addSubview(titleButton)
        self.titleButton.setTitle("Eatingram", for: .normal)
        self.titleButton.setTitleColor(.black, for: .normal)
        self.titleButton.titleLabel?.textAlignment = .center
        self.titleButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 25)
        
        self.headView.addSubview(diaryAddButton)
        self.diaryAddButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        self.diaryAddButton.imageView?.tintColor = .black
        self.diaryAddButton.addTarget(self, action: #selector(addDairyButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .white
        self.mainView.addSubview(boardTableView)
        
        
        
    }
    
    func constraintConfigure() {
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.titleButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
            //make.trailing.equalToSuperview().offset(0)
        }
        
        self.diaryAddButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            //make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.mainView.snp.makeConstraints{ make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.boardTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
            
        }
    }
        

}

extension EatDiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diaryInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EatTableViewCell", for: indexPath) as? EatTableViewCell
        cell?.selectionStyle = .none
        
        let cellDiaryInfo = self.diaryInfos[indexPath.row]
        
        cell?.titleLabel.text = cellDiaryInfo.place_info?.place_name
        cell?.scoreLabel.rating = Double(cellDiaryInfo.score!)
        cell?.scoreLabel.text = "\(cellDiaryInfo.score!)점"
        cell?.locationLabel.text = cellDiaryInfo.place_info?.address_name
        cell?.categoryLabel.text = cellDiaryInfo.category
        cell?.dateLabel.text = cellDiaryInfo.date
        cell?.storyLabel.text = cellDiaryInfo.story
        
        return cell ?? UITableViewCell()
    }
}

extension EatDiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 800
    }
}
