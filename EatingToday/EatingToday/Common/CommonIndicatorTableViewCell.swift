//
//  CommonIndicatorTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/04/02.
//

import UIKit

class CommonIndicatorTableViewCell: UITableViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        activityIndicator.center = self.center
        activityIndicator.color = UIColor.black
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        // Start animation.
        activityIndicator.stopAnimating()
        self.isUserInteractionEnabled = true

        return activityIndicator

    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    func viewConfigure() {
        
        self.addSubview(self.activityIndicator)
        
    }
    
    func constraintConfigure() {
        
        self.activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
    }
}
