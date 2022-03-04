//
//  SearchResultTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/04.
//

import UIKit
import SnapKit

protocol goUrlCellInfoDelegate: AnyObject {
    func goUrlButtonTapped(link: String)
}

class SearchResultTableViewCell: UITableViewCell {
    
    var cellDelegate: goUrlCellInfoDelegate?
    
    let storeName = UILabel()
    let addressName = UILabel()
    var link: String?
    let linkButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    @objc func goUrl() {
        cellDelegate?.goUrlButtonTapped(link: self.link!)
    }
    
    func viewConfigure() {
        self.addSubview(self.storeName)
        self.addSubview(self.addressName)
        self.addSubview(self.linkButton)
        self.linkButton.addTarget(self, action: #selector(goUrl), for: .touchUpInside)
    
    }
    
    func constraintConfigure() {
        
        self.storeName.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.addressName.snp.makeConstraints{ make in
            make.top.equalTo(self.storeName.snp.bottom).offset(2)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.linkButton.snp.makeConstraints{ make in
            make.top.equalTo(self.addressName.snp.bottom).offset(2)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(0)
            //make.trailing.equalToSuperview().offset(0)
        }
    
    }
    
}

