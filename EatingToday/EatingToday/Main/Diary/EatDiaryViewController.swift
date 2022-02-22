//
//  EatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit
import SnapKit

class EatDiaryViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    func viewConfigure() {
        
        self.view.addSubview(self.headView)
        self.headView.backgroundColor = .white
        
        self.headView.addSubview(titleButton)
        self.titleButton.setTitle("Eatingram", for: .normal)
        self.titleButton.setTitleColor(UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1), for: .normal)
        self.titleButton.titleLabel?.textAlignment = .center
        self.titleButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 25)
        
        self.headView.addSubview(diaryAddButton)
        self.diaryAddButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        self.diaryAddButton.imageView?.tintColor = .black
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EatTableViewCell", for: indexPath) as? EatTableViewCell
        cell?.selectionStyle = .none
        
        return cell ?? UITableViewCell()
    }
}

extension EatDiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 500
    }
}
