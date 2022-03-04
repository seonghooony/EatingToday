//
//  SearchKakaoViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/01.
//
import Foundation
import UIKit
import Alamofire

class SearchKakaoViewController: UIViewController {
    
    var resultList: SearchResultOverview?
    var SearchKeyword: String?
    
    let closeButton = UIButton()
    
    let headView = UIView()
    
    let searchHeadLabel = UILabel()
    let searchTextField = PaddedTextField()
    
    let mainView = UIView()
    
    private lazy var resultTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .black
//        tableView.separatorStyle = .none
//        tableView.separatorColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
        
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
        //searchKakaoApiPlace()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func searchKeywords() {
        let currentkeword = self.searchTextField.text ?? ""
        if currentkeword.count > 0 {
            searchKakaoApiPlace(keyword: self.searchTextField.text ?? "서울")
        }
    }
    
    func viewConfigure() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.closeButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        self.view.addSubview(self.headView)
        //self.headView.backgroundColor = .red
        
        self.headView.addSubview(self.searchHeadLabel)
        self.searchHeadLabel.text = "가게 이름 검색"
        self.searchHeadLabel.textAlignment = .center
        
        self.headView.addSubview(self.searchTextField)
        //self.searchTextField.placeholder = "가게 이름을 입력해주세요."
        self.searchTextField.layer.cornerRadius = 20
        self.searchTextField.layer.borderWidth = 1.5
        self.searchTextField.layer.borderColor = UIColor.black.cgColor
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "가게 이름을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.searchTextField.clearButtonMode = .whileEditing
        self.searchTextField.addTarget(self, action: #selector(searchKeywords), for: .editingChanged)
        //self.searchTextField.addLeftPadding()
        //self.searchTextField.addRightImage(image: UIImage(systemName: "magnifyingglass")!)
        
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .blue
        
        self.mainView.addSubview(resultTableView)
        
    }
    
    func constraintConfigure() {
    
        self.closeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.height.width.equalTo(30)
            
        }
        
        self.headView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        self.searchHeadLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        self.searchTextField.snp.makeConstraints{ make in
            make.top.equalTo(searchHeadLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        self.resultTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            
        }
    }
    
    func searchKakaoApiPlace(keyword: String ) {
        
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK 188f4e2c0a595ea58c5ffe55583061c1"
        ]
        let parameters: [String: Any] = [
            "query" : keyword,
            //"query" : SearchKeyword ?? "강아지공원",
            "page" : 1,
            "size": 10
        ]
        let urlStr = "https://dapi.kakao.com/v2/local/search/keyword.json"
        let url = URL(string: urlStr)!
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseData(completionHandler: { (response) in
            debugPrint(response)
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SearchResultOverview.self, from: data)
                    if !result.documents.isEmpty {
                        debugPrint(result.documents[0].place_name)
                        self.resultList = result
                        
                        self.resultTableView.reloadData()
                    }
                    
                }catch{
                    debugPrint("alamofire data JSON Decoder error")
                }
            case .failure(let error):
                print("dd")
            }
            
            //데이터 세팅
            //테이블 뷰
            //검색란 만들기
            
        })
        
//        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
//            //debugPrint(response)
//
//            switch response.result {
//            case .success(let value):
//                debugPrint(value)
//            case .failure(let error):
//                print("dd")
//            }
//
//            //데이터 세팅
//            //테이블 뷰
//            //검색란 만들기
//
//        })
        
    }
    
    
}
class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
//    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.inset(by: padding)
//    }
}


extension SearchKakaoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList?.documents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell
        cell?.selectionStyle = .none
        cell?.backgroundColor = .brown
        cell?.storeName.text = resultList?.documents[indexPath.row].place_name
        cell?.addressName.text = resultList?.documents[indexPath.row].address_name
        cell?.link = resultList?.documents[indexPath.row].place_url
        cell?.cellDelegate = self
        cell?.linkButton.setTitle("상세보기", for: .normal)
        
        cell?.contentView.isUserInteractionEnabled = false
        
        return cell ?? UITableViewCell()
    }
}

extension SearchKakaoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("선택됨")

    }
}

extension SearchKakaoViewController: goUrlCellInfoDelegate {
    func goUrlButtonTapped(link: String) {
        print("상세보기클릭")
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
