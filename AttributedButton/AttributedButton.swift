//
//  AttributedButton.swift
//  AttributedButton
//
//  Created by Konrad on 03/09/2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import Foundation
import UIKit

public protocol Attribute {
    var font: UIFont                                    { get }
    var string: String?                                 { get }
    var additionalStyles: [NSAttributedStringKey: Any]? { get }
}

public class AttributedText {
    public var attribute: Attribute?       = nil
    public var foregroundColor: UIColor    = UIColor.black
    public var action: (() -> Void)?       = nil
    
    public init(attribute: Attribute? = nil, foregroundColor: UIColor = UIColor.black, action: (() -> Void)? = nil) {
        self.attribute = attribute
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    public var attributedString: NSAttributedString {
        guard let attribute = self.attribute else { return NSAttributedString(string: "") }
        guard let string = attribute.string else { return NSAttributedString(string: "") }
        var attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor:  self.foregroundColor,
            NSAttributedStringKey.font:             attribute.font
        ]
        
        // underline
        if let styles = attribute.additionalStyles {
            for style in styles {
                attributes[style.key] = style.value
            }
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
}

extension Array where Element == AttributedText {
    public var attributedString: NSAttributedString {
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString()
        self.map { $0.attributedString }
            .forEach { mutableAttributedString.append($0) }
        return mutableAttributedString
    }
    
    public var attributedRanges: [NSRange] {
        let attributedStrings = self.map { $0.attributedString }
        var ranges: [NSRange] = []
        var index: Int = 0
        for attributedString in attributedStrings {
            let length = attributedString.length
            let range: NSRange = NSMakeRange(index, length)
            ranges.append(range)
            index += length
        }
        return ranges
    }
}


public class AttributedButton: UIButton {
    fileprivate var attributedText: [AttributedText] = []
    
    // set attributed text
    public func setAttributedText(attributes: [Attribute], state: UIControlState = UIControlState.normal) {
        let attributedText: [AttributedText] = attributes.map { AttributedText(attribute: $0) }
        self.setAttributedText(attributedText: attributedText, state: state)
    }
    
    // set attributed text
    public func setAttributedText(attributedText: [AttributedText], state: UIControlState = UIControlState.normal) {
        self.attributedText = attributedText
        self.setAttributedTitle(attributedText.attributedString, for: state)
        self.layoutIfNeeded()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = self.attributedTextAction(touches: touches) else {
            super.touchesBegan(touches, with: event)
            return
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let action = self.attributedTextAction(touches: touches) else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        // action for attributed text
        action()
    }
    
    public func attributedTextAction(touches: Set<UITouch>) -> (() -> Void)? {
        return self.attributedText(touches: touches)?.action
    }
    
    public func attributedText(touches: Set<UITouch>) -> AttributedText? {
        guard let attributedTitle = self.attributedTitle(for: UIControlState.normal) else { return nil }
        guard let titleLabel = self.titleLabel else { return nil }
        for touch in touches {
            let touchPoint = touch.location(in: titleLabel)
            guard let index = self.character(point: touchPoint) else { continue }
            guard 0 <= index && index < attributedTitle.length else { continue }
            let range = NSMakeRange(index, 0)
            guard let attributedText = self.attributedText(range: range) else { continue }
            return attributedText
        }
        return nil
    }
    
    fileprivate func attributedText(range: NSRange) -> AttributedText? {
        let attributedRanges = self.attributedText.attributedRanges
        for (i, attributedRange) in attributedRanges.enumerated() {
            guard attributedRange.location <= range.location &&
                range.location <= attributedRange.location + attributedRange.length else { continue }
            return self.attributedText[i]
        }
        return nil
    }
    
    fileprivate func character(point: CGPoint) -> Int? {
        guard let attributedTitle = self.attributedTitle(for: UIControlState.normal) else { return nil }
        guard let titleLabel = self.titleLabel else { return nil }
        let frame = titleLabel.frame
        let boundingBox: CGRect = titleLabel.bounds
        let path = CGMutablePath()
        path.addRect(boundingBox, transform: .identity)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedTitle as CFAttributedString)
        let ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedTitle.length), path, nil)
        let verticalPadding: CGFloat = (frame.height - boundingBox.height) / 2
        let horizontalPadding: CGFloat = (frame.width - boundingBox.width) / 2
        let ctPointX: CGFloat = point.x - horizontalPadding
        let ctPointY: CGFloat = boundingBox.height - (point.y - verticalPadding)
        let ctPoint = CGPoint(x: ctPointX, y: ctPointY)
        let lines = CTFrameGetLines(ctFrame) as! [CTLine]
        var lineOrigins: [CGPoint] = [CGPoint](repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &lineOrigins)
        var indexOfCharacter: Int? = nil
        
        for i in 0..<lines.count {
            let line = lines[i]
            var ascent: CGFloat = 0.0
            var descent: CGFloat = 0.0
            var leading: CGFloat = 0.0
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            let origin = lineOrigins[i]
            if ctPoint.y > (origin.y) - descent {
                indexOfCharacter = CTLineGetStringIndexForPosition(line, ctPoint)
                break
            }
        }
        return indexOfCharacter
    }
}
