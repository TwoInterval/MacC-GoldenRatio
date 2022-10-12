//
//  CustomPopUpView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/11.
//

import SnapKit
import UIKit

class PopUpViewController: UIViewController {
    private let device = UIScreen.getDevice()
    private var contentView: UIView?
    private var buttons: [UIButton] = []
    private var popUpPosition: PopUpPosition?
    
    enum PopUpPosition {
        case bottom
        case top
    }
    
    convenience init(popUpPosition: PopUpPosition) {
        self.init()
        
        self.popUpPosition = popUpPosition
        modalPresentationStyle = .overFullScreen
    }

    convenience init(contentView: UIView) {
        self.init()

        self.contentView = contentView
        modalPresentationStyle = .overFullScreen
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.addGestureRecognizer(tapGestureRecognizer)

        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        switch popUpPosition {
        case .top:
            view.transform = CGAffineTransform(a: 0.5, b: 0, c: 0, d: 0.5, tx: 50.0, ty: -30.0)
        case .bottom:
            view.transform = CGAffineTransform(a: 0.5, b: 0, c: 0, d: 0.5, tx: 50.0, ty: 30.0)
        default:
            return view
        }
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 6.0
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeButtonStack()
        setupViews()
        makeConstraints()
    }

    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(buttonStackView)
    }

    private func makeConstraints() {
        backgroundView.snp.makeConstraints {
            $0.size.equalToSuperview()
        }
        
        switch popUpPosition {
        case .bottom:
            containerView.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(device.MyDiariesViewAddDiaryButtonPadding + 130)
                $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(device.MyDiariesViewAddDiaryButtonPadding)
            }
            
        case .top:
            containerView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(20)
                $0.top.equalToSuperview().inset(100)
                $0.width.equalTo(155)
            }
            
        default:
            return
        }
        
        
        buttonStackView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalTo(containerView).inset(10)
        }
    }
    
    private func makeButtonStack() {
        buttons.forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }
    
    public func addButton(buttonTitle: String, action: (() -> Void)? = nil) {
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .light)
        button.setTitleColor(.black, for: .normal)
        button.isUserInteractionEnabled = true
        button.addAction(for: .touchUpInside) { _ in
            self.dismissController()
            action?()
        }
        buttons.append(button)
    }
    
    @objc func dismissController() {
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: Extension - Button Action을 위한 Closure Target 설정
extension UIControl {
    public typealias UIControlTargetClosure = (UIControl) -> ()

    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure

        } set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }

    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }

}