//
//  MainViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/16.
//

import UIKit
import SnapKit
import Firebase
import GoogleSignIn
import FirebaseAuth


class MainViewController: UITabBarController {
    
//    let titleView = UIView()
//    let titleButton = UIButton()
//    let diaryAddButton = UIButton()
//    let mainView = UIView()
//    let boardCollectionView = UICollectionView()
    
    var defaultIndex = 0 {
        didSet {
            self.selectedIndex = defaultIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.selectedIndex = defaultIndex
        
    }
    
}

extension MainViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let firstNavigationController = UINavigationController()
        let firstTabConroller = EatDiaryViewController()
        firstNavigationController.addChild(firstTabConroller)
        firstNavigationController.tabBarItem.image = UIImage(systemName: "house")
        firstNavigationController.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        firstNavigationController.tabBarItem.title = "홈"
        
        let secondNavigationController = UINavigationController()
        let secondTabConroller = DiaryMapViewController()
        secondNavigationController.addChild(secondTabConroller)
        secondNavigationController.tabBarItem.image = UIImage(systemName: "map")
        secondNavigationController.tabBarItem.selectedImage = UIImage(systemName: "map.fill")
        secondNavigationController.tabBarItem.title = "지도"
        
        let thirdNavigationController = UINavigationController()
        let thirdTabConroller = ProfileViewController()
        thirdNavigationController.addChild(thirdTabConroller)
        thirdNavigationController.tabBarItem.image = UIImage(systemName: "person")
        thirdNavigationController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        thirdNavigationController.tabBarItem.title = "프로필"
        
        let viewControllers = [firstNavigationController, secondNavigationController, thirdNavigationController]
        self.setViewControllers(viewControllers, animated: true)
        
        let tabBar: UITabBar = self.tabBar
        tabBar.backgroundColor = .white
        tabBar.barTintColor = UIColor.white
        
        tabBar.tintColor = UIColor(displayP3Red: 214/255, green: 52/255, blue: 71/255, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor(displayP3Red: 209/255, green: 206/255, blue: 189/255, alpha: 1)
        tabBar.isHidden = false
        
        tabBar.layer.borderWidth = 0.20
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        
        //큰 이미지 자르기 : 이미지가 tabbar보다 큰 경우 밖으로 튀어나옴
        tabBar.clipsToBounds = true
        
        
        self.hidesBottomBarWhenPushed = false
        
    }
}
