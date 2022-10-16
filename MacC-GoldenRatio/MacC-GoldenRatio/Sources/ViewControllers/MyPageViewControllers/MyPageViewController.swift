//
//  MyPageViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import FirebaseAuth
import SnapKit
import UIKit

class MyPageViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    private let myDevice = UIScreen.getDevice()
    private let viewModel = MyPageViewModel.shared
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "마이페이지"
        label.font = .tabTitleFont
        
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "닉네임"
        label.font = .labelSubTitleFont2
        
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "홀리 마운틴"
        label.font = .labelTtitleFont2
        
        return label
    }()
    
    private lazy var profileSettingButton: UIButton = {
        let button = UIButton()

        let title = "프로필 설정"
        let attributes = [NSAttributedString.Key.font:UIFont.labelSubTitleFont2]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        button.setAttributedTitle(mutableAttributedString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onTapProfileSetting), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var travelsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "가본 여행지"
        label.font = .labelSubTitleFont2

        return label
    }()
    
    private lazy var travelsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(TravelsCollectionViewCell.self, forCellWithReuseIdentifier: TravelsCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
            self.view.backgroundColor = .backgroundTexture
            self.setupViewModel()
            self.configureViews()
            self.configureNickName()
            self.configureProfileImage()
            self.configureTravelLocations()
            self.profileImageView.layer.cornerRadius = self.myDevice.myPageProfileImageSize.width * 0.5
        }
    }
    
    private func configureViews() {
        [titleLabel, profileImageView, nickNameTitleLabel, nickNameLabel, profileSettingButton, travelsTitleLabel, travelsCollectionView, menuTableView].forEach{
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageVerticalPadding)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
            make.size.equalTo(myDevice.myPageProfileImageSize)
        }
        nickNameTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(titleLabel.snp.bottom).offset(myDevice.myPageVerticalPadding)
        }
        nickNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(nickNameTitleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing2)
        }
        profileSettingButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)

        }
        travelsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileSettingButton.snp.bottom).offset(myDevice.myPageVerticalSpacing3)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
        }
        travelsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(travelsTitleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing2)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(myDevice.myPageHorizontalPadding)
            make.bottom.equalTo(menuTableView.snp.top).offset(-myDevice.myPageVerticalSpacing2)
        }
        menuTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(myDevice.myPageMenuTableViewHeight)
        }
    }
    
    private func configureNickName() {
        self.nickNameLabel.text = self.viewModel.myUser.userName
    }
    
    private func configureTravelLocations() {
        self.travelsCollectionView.reloadData()
    }
    
    private func configureProfileImage() {
        self.profileImageView.image = self.viewModel.myProfileImage
    }
    
    @objc private func onTapProfileSetting() {
        let viewController = SetProfileImageViewController()
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
    
    private func onTapLogOutButtonTapped() {
        let ac = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in
            self.authLogout()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func onTapWithdrawalButtonTapped() {
        let ac = UIAlertController(title: "회원탈퇴 하시겠습니까?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in
            self.authWithdrawal()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func authLogout() {
        let firebaseAuth = Auth.auth()
        
        do{
            try firebaseAuth.signOut()
            print("Sign Out completed with Apple ID")
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("ERROR: signOut \(signOutError.localizedDescription)")
        }
    }
    
    private func authWithdrawal() {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let withdrawalError = error {
                print("ERROR: withdrawal \(withdrawalError.localizedDescription)")
            } else {
                print("Withdrawal completed with Apple ID")
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.myTravelLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelsCollectionViewCell.identifier, for: indexPath) as? TravelsCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let image = UIImage(named: "stampLayout") else { return UICollectionViewCell() }
        let travelLocation = viewModel.myTravelLocations[indexPath.item]
        cell.setUI(image: image, location: travelLocation)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 50) / 6
        let height = width
        return CGSize(width: width, height: height)
    }
    
}

extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        let menuTitle = viewModel.menuArray[indexPath.item]
        
        cell.setUI(title: menuTitle.0, subTitle: menuTitle.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.menuArray[indexPath.item].0 {
        case "오픈소스":
            break
        case "앱 평가하기":
            break
        case "로그아웃":
            self.onTapLogOutButtonTapped()
            break
        case "회원탈퇴":
            self.onTapWithdrawalButtonTapped()
            break
        default: break
        }
    }
}

private extension MyPageViewController {
    func setupViewModel() {
        viewModel.$myUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureNickName()
            }
            .store(in: &cancelBag)
        
        viewModel.$myTravelLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureTravelLocations()
            }
            .store(in: &cancelBag)
        
        viewModel.$myProfileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureProfileImage()
            }
            .store(in: &cancelBag)
    }
}

class MenuTableViewCell: UITableViewCell {
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = .labelTtitleFont2
        label.textColor = .black
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .labelSubTitleFont2
        label.textColor = .buttonColor

        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(menuLabel)
        contentView.addSubview(subTitleLabel)

        menuLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }

    }
    
    func setUI(title: String, subTitle: String?){
        self.menuLabel.text = title
        guard let subTitle = subTitle else { return }
        self.subTitleLabel.text = subTitle
    }
}
