//
//  SignInTestViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/30.
//

import UIKit
import SnapKit

// window.rootViewController = UINavigationController(rootViewController: SignInViewController())

class SignInTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Firebase Test setup (Logout, Withdrawal)
        testSetup()
    }
    
    // MARK: - UI & Features for test
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var withdrawalButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("회원 탈퇴", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.addTarget(self, action: #selector(withdrawalButtonPressed), for: .touchUpInside)
        return button
    }()
    

    private func testSetup() {
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(withdrawalButton)
        withdrawalButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(logoutButton).offset(80)
        }
    }
    
    
    @objc private func logoutButtonPressed() {
        print("Sign Out completed with Apple ID")
    }
    
    @objc private func withdrawalButtonPressed() {
        print("Withdrawal completed with Apple ID")
    }
}