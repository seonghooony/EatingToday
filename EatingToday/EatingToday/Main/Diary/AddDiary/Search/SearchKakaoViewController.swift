//
//  SearchKakaoViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/01.
//
import Foundation
import UIKit
import Alamofire
import SkyFloatingLabelTextField

protocol selectedStorePlaceDelegate: AnyObject {
    func showSelectedStorePlace(document: SelectedSearchResultDocument)
}

class SearchKakaoViewController: UIViewController {
    
    var resultList: SearchResultOverview?
    var SearchKeyword: String?
    
    weak var resultDelegate: selectedStorePlaceDelegate?
    
    let activeColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    let inactiveColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    let titleColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let customGray0 = UIColor(displayP3Red: 250/255, green: 250/255, blue: 253/255, alpha: 1)
    let customGray1 = UIColor(displayP3Red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    let customGray2 = UIColor(displayP3Red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
    let customGray3 = UIColor(displayP3Red: 130/255, green: 130/255, blue: 135/255, alpha: 1)
    
    let closeButton = UIButton()
    
    let headView: UIView = {
        let headView = UIView()
        let shadowSize: CGFloat = 10.0
        headView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 220 + shadowSize)).cgPath
        headView.backgroundColor = .white
        headView.layer.cornerRadius = 1
        headView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        headView.layer.shadowOffset = CGSize(width: 1, height: 4)
        headView.layer.shadowRadius = 15
        headView.layer.shadowOpacity = 1
        
        headView.layer.masksToBounds = false
//        headView.layer.shouldRasterize = true
//        headView.layer.rasterizationScale = UIScreen.main.scale

        

        return headView
    }()
    
    let searchHeadLabel = UILabel()
    let searchsubLabel = UILabel()
//    let searchTextField = PaddedTextField()
    let searchTextField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: 0, y: 0, width: CGFloat(UIScreen.main.bounds.width) * 0.85, height: 45), iconType: .image)
    
    let mainView = UIView()
    
    let emptyView = UIView()
    let emptyLabel = UILabel()
    
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
        scrollViewEndEditing()
        //searchKakaoApiPlace()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //빈 화면을 눌러줄때 마다 하단 키보드나 데이트피커가 사라짐
        self.view.endEditing(true)
    }
    
    // 스크롤뷰에서 클릭시 endEditing 기능 먹도록 함
    func scrollViewEndEditing() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.endEdit))
        singleTap.numberOfTapsRequired = 1
        singleTap.isEnabled = true
        singleTap.cancelsTouchesInView = false
        self.resultTableView.addGestureRecognizer(singleTap)
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
    
    @objc func endEdit() {
        self.view.endEditing(true)
    }
    
    func viewConfigure() {
        self.view.backgroundColor = customGray0
        //self.view.addSubview(self.closeButton)
//        self.view.layer.cornerRadius = 15
        
        
        self.headView.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.closeButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        self.view.addSubview(self.headView)
        self.headView.backgroundColor = .white
//        self.headView.layer.cornerRadius = 15
        
        
        self.headView.addSubview(self.searchHeadLabel)
        self.searchHeadLabel.text = "가게 이름 검색"
        self.searchHeadLabel.textAlignment = .center
        self.searchHeadLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        self.searchHeadLabel.textColor = UIColor.black
        
        self.headView.addSubview(self.searchsubLabel)
        self.searchsubLabel.text = "방문하셨던 가게 이름을 검색해 주세요."
        self.searchsubLabel.textAlignment = .center
        self.searchsubLabel.font = UIFont(name: "Helvetica Bold", size: 17)
        self.searchsubLabel.textColor = UIColor.black
        
        self.headView.addSubview(self.searchTextField)
        self.searchTextField.placeholder = "장소 또는 주소 입력"
        self.searchTextField.title = ""
        //클리어버튼 생성
        self.searchTextField.clearButtonMode = .whileEditing
        //맞춤법 검사
        self.searchTextField.autocorrectionType = .no
        //첫글자 자동 대문자
        self.searchTextField.autocapitalizationType = .none
        //text키보드모드
        self.searchTextField.keyboardType = .default
        //text 비밀번호 가림
        self.searchTextField.isSecureTextEntry = false
        //커서 색상
        self.searchTextField.tintColor = titleColor
        //안쪽 텍스트 색상
        self.searchTextField.textColor = .black
        //안쪽 텍스트 폰트
        self.searchTextField.font = UIFont(name: "Helvetica", size: 18)
        //기본 라인 색상
        self.searchTextField.lineColor = inactiveColor
        //선택 라인 색상
        self.searchTextField.selectedLineColor = activeColor
        //선택 위쪽 타이틀 색상
        self.searchTextField.selectedTitleColor = titleColor
        //선택 위쪽 텍스트 폰트
        self.searchTextField.titleFont = UIFont(name: "Helvetica", size: 0)!
        //기본 아래 선 굵기
        self.searchTextField.lineHeight = 1.5
        //선택 시 아래 선 굵기
        self.searchTextField.selectedLineHeight = 2.0
        //에러 시 색상
        self.searchTextField.errorColor = .red
        //이미지 추가
        self.searchTextField.iconType = .image
        self.searchTextField.iconColor = inactiveColor
        self.searchTextField.selectedIconColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 93/255, alpha: 1)
        self.searchTextField.iconMarginBottom = 10.0
        self.searchTextField.iconMarginLeft = 5.0
        self.searchTextField.iconImage = UIImage(systemName: "magnifyingglass")
        
        
        //실시간 검색
        self.searchTextField.addTarget(self, action: #selector(searchKeywords), for: .editingChanged)
        //에러용 액션 추가
//        self.searchTextField.addTarget(self, action: #selector(emailFieldDidChange(_:)), for: .editingChanged)
        //키보드 return 클릭시 반응하도록 위임
//        self.searchTextField.delegate = self
        
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .clear
        
        self.emptyView.isHidden = false
        self.mainView.addSubview(self.emptyView)
        self.emptyView.backgroundColor = .clear
        
        self.emptyView.addSubview(self.emptyLabel)
        self.emptyLabel.text = "검색 결과가 없습니다."
        self.emptyLabel.textAlignment = .center
        self.emptyLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        self.emptyLabel.textColor = customGray3
        
        self.resultTableView.isHidden = true
        self.mainView.addSubview(resultTableView)
        self.resultTableView.backgroundColor = .clear
        self.resultTableView.showsVerticalScrollIndicator = false
        //드래그시 키보드 내리기
        self.resultTableView.keyboardDismissMode = .onDrag
    }
    
    func constraintConfigure() {
        
        let leadingTrailingSize = 30
        
        self.headView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.leading.equalToSuperview().offset(25)
            make.height.width.equalTo(24)
            
        }
        self.closeButton.imageView?.snp.makeConstraints { make in
            make.height.width.equalTo(15)
        }
        
        self.searchHeadLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            //make.leading.equalToSuperview().offset(10)
        }
        self.searchsubLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.searchHeadLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        
        self.searchTextField.snp.makeConstraints{ make in
            make.top.equalTo(self.searchsubLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.height.equalTo(45)
        }
        
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        
        self.resultTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            
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
                        self.emptyView.isHidden = true
                        self.resultTableView.isHidden = false
                        debugPrint(result.documents[0].place_name)
                        self.resultList = result
                        
                        self.resultTableView.reloadData()
                    } else {
                        self.emptyView.isHidden = false
                        self.resultTableView.isHidden = true
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
        cell?.backgroundColor = .clear
        cell?.storeNameLabel.text = resultList?.documents[indexPath.row].place_name
        cell?.addressNameLabel.text = resultList?.documents[indexPath.row].address_name
        cell?.phoneLabel.text = resultList?.documents[indexPath.row].phone
        cell?.link = resultList?.documents[indexPath.row].place_url
        cell?.cellDelegate = self
        //cell?.linkButton.setTitle("상세보기", for: .normal)
        
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
        let selectedDocument = SelectedSearchResultDocument(
            address_name: resultList?.documents[indexPath.row].address_name,
            road_address_name: resultList?.documents[indexPath.row].road_address_name,
            phone: resultList?.documents[indexPath.row].phone,
            place_name: resultList?.documents[indexPath.row].place_name,
            place_url: resultList?.documents[indexPath.row].place_url,
            x: resultList?.documents[indexPath.row].x,
            y: resultList?.documents[indexPath.row].y
        )
        self.resultDelegate?.showSelectedStorePlace(document: selectedDocument)
        self.dismiss(animated: true, completion: nil)

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
