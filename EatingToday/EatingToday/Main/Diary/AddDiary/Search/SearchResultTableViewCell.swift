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
    
    let storeNameLabel = UILabel()
    let addressNameLabel = UILabel()
    let phoneLabel = UILabel()
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
        self.addSubview(self.storeNameLabel)
        self.storeNameLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        self.storeNameLabel.textColor = UIColor.darkGray
        
        self.addSubview(self.addressNameLabel)
        self.addressNameLabel.font = UIFont(name: "Helvetica Bold", size: 14)
        self.addressNameLabel.textColor = UIColor.lightGray
        
        self.addSubview(self.phoneLabel)
        self.phoneLabel.font = UIFont(name: "Helvetica", size: 14)
        self.phoneLabel.textColor = UIColor.lightGray
        
        self.addSubview(self.linkButton)
        self.linkButton.setImage(UIImage(systemName: "map"), for: .normal)
        self.linkButton.tintColor = .darkGray
        self.linkButton.addTarget(self, action: #selector(goUrl), for: .touchUpInside)
        
    }
    
    func constraintConfigure() {
        
        self.storeNameLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(0)

        }
        
        self.addressNameLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.storeNameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(0)

        }
        
        self.phoneLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.addressNameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(0)

        }
        self.linkButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(0)
            make.width.height.equalTo(30)
        }
        
        self.linkButton.imageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    
    }
    
}

