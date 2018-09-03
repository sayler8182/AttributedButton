//
//  ViewController.swift
//  AttributedButton
//
//  Created by Konrad on 03/09/2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import UIKit

enum AppAttibute: Attribute {
    case small(string: String)
    case smallBold(string: String)
    case smallUnderlined(string: String)
    
    var font: UIFont {
        switch self {
        case .small:                        return UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        case .smallBold:                    return UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.semibold)
        case .smallUnderlined:              return UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.semibold)
        }
    }
    
    var string: String? {
        switch self {
        case .small(let string):            return string
        case .smallBold(let string):        return string
        case .smallUnderlined(let string):  return string
        }
    }
    
    var additionalStyles: [NSAttributedStringKey : Any]? {
        switch self {
        case .small:                        return nil
        case .smallBold:                    return nil
        case .smallUnderlined:              return [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        }
    }
}

class ViewController: UIViewController {
    
    fileprivate lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView(frame: CGRect(x: 0,
                                                               y: 64,
                                                               width: self.view.frame.width,
                                                               height: 200))
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.axis = UILayoutConstraintAxis.vertical
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.stackView)
        self.makeButtons()
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    // make buttons
    fileprivate func makeButtons() {
        
        // button1
        let button1: AttributedButton = self.makeButton()
        button1.setAttributedText(attributes: [
            AppAttibute.small(string: "I agree to the Terms and the Privacy Policy."),
            ])
        button1.sizeToFit()
        self.stackView.addArrangedSubview(button1)
        
        // button 2
        let button2: AttributedButton = self.makeButton()
        button2.setAttributedText(attributedText: [
            AttributedText(attribute: AppAttibute.small(string: "I agree to "), foregroundColor: UIColor.darkGray),
            AttributedText(attribute: AppAttibute.smallBold(string: "the Terms"), foregroundColor: UIColor.black),
            AttributedText(attribute: AppAttibute.small(string: " and "), foregroundColor: UIColor.darkGray),
            AttributedText(attribute: AppAttibute.smallBold(string: "the Privacy Policy"), foregroundColor: UIColor.black),
            AttributedText(attribute: AppAttibute.small(string: "."), foregroundColor: UIColor.darkGray),
            ])
        button2.sizeToFit()
        self.stackView.addArrangedSubview(button2)
        
        // button 2
        let button3: AttributedButton = self.makeButton()
        button3.setAttributedText(attributedText: [
            AttributedText(attribute: AppAttibute.small(string: "I agree to "), foregroundColor: UIColor.darkGray),
            AttributedText(attribute: AppAttibute.smallUnderlined(string: "the Terms"), foregroundColor: UIColor.black) {
                print("Navigate to 'the Terms'")
            },
            AttributedText(attribute: AppAttibute.small(string: " and "), foregroundColor: UIColor.darkGray),
            AttributedText(attribute: AppAttibute.smallUnderlined(string: "the Privacy Policy"), foregroundColor: UIColor.black) {
                print("Navigate to 'the Privacy Policy'")
            },
            AttributedText(attribute: AppAttibute.small(string: "."), foregroundColor: UIColor.darkGray),
            ])
        button3.sizeToFit()
        self.stackView.addArrangedSubview(button3)
    }
    
    // make button
    fileprivate func makeButton() -> AttributedButton {
        let button: AttributedButton = AttributedButton()
        button.titleEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 8)
        button.addTarget(self, action: #selector(buttonClick(_:)), for: UIControlEvents.touchUpInside)
        button.setImage(#imageLiteral(resourceName: "checkbox_off"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "checkbox_on"), for: .selected)
        return button
    }
}

