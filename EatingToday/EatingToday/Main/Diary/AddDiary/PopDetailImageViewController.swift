//
//  PopDetailImageViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/06.
//

import UIKit
import SnapKit
import Lottie

class PopDetailImageViewController: UIViewController {
    
    let containerScrollView = UIScrollView()
    let containerView = UIView()
    let detailImageView = UIImageView()
    let animationView = AnimationView(name: "loadingImage")
    
    let popCloseButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
    }
    
    @objc func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
//    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
//        detailImageView.transform = detailImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
//        pinch.scale = 1
//    }
    
    func viewConfigure() {
        
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
//        self.view.addGestureRecognizer(pinch)
        

        self.view.addSubview(self.containerView)
//        self.containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
//        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 4)
//        self.containerView.layer.shadowRadius = 10
//        self.containerView.layer.shadowOpacity = 1
//        self.containerView.layer.cornerRadius = 10
        self.containerView.backgroundColor = .white
        
        self.containerView.addSubview(animationView)
        self.animationView.play()
        self.animationView.loopMode = .loop
        
        self.containerView.addSubview(self.containerScrollView)
        self.containerScrollView.setNeedsUpdateConstraints()
        self.containerScrollView.delegate = self
        self.containerScrollView.zoomScale = 1.0
        self.containerScrollView.minimumZoomScale = 1.0
        self.containerScrollView.maximumZoomScale = 8.0
        
        self.containerScrollView.addSubview(detailImageView)
        
        self.containerView.addSubview(popCloseButton)
        self.popCloseButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.popCloseButton.tintColor = .black
        self.popCloseButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
    
    }
    
    
    func constraintConfigure() {
        
        self.animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        self.containerScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.detailImageView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
            make.width.height.equalTo(self.containerView)
        }
        
        self.popCloseButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(15)
        }
    }
}


extension PopDetailImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.containerScrollView.zoomScale <= 1.0 {
            self.containerScrollView.zoomScale = 1.0
        }
        
        if self.containerScrollView.zoomScale >= 8.0 {
            self.containerScrollView.zoomScale = 8.0
        }
    }
}
