//
//  InfoView.swift
//  JengaAR
//
//  Created by Nicholas Grana on 3/18/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
    var line1Text: String
    var line2Text: String
    var bottomText: String
    
    lazy var infoView: UILabel = {
        let label = infoLabel(title: "0", scale: 0.5)
        label.center = CGPoint(x: self.frame.minX + 20, y: self.frame.minY + 20)
        addSubview(label)
        return label
    }()
    
    init(frame: CGRect, line1: String, line2: String, bottom: String) {
        line1Text = line1
        line2Text = line2
        bottomText = bottom

        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let label1 = infoLabel(title: "Push out each block until the tower fallsz", scale: 0.18, font: UIFont.boldSystemFont(ofSize: 16.0))
        addSubview(label1)
        let label2 = infoLabel(title: "Tap to push a block", scale: 0.15, font: UIFont.boldSystemFont(ofSize: 16.0))
        addSubview(label2)
        let bottom = infoLabel(title: "WWDC18", scale: 0.95, font: UIFont.boldSystemFont(ofSize: 16.0))
        addSubview(bottom)
        
        let resetButton = UIButton(frame: CGRect(x: frame.minX, y: bottom.center.y, width: 50, height: 50))
        resetButton.backgroundColor = UIColor.white
        resetButton.setTitleColor(.black, for: .normal)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        resetButton.layer.cornerRadius = resetButton.frame.width / 2 / 2
        resetButton.center = CGPoint(x: resetButton.center.x + resetButton.frame.width / 2, y: resetButton.center.y - resetButton.frame.height / 2)
        addSubview(resetButton)
        
        [label1, label2, bottom].forEach { (label) in
            UIView.animate(withDuration: 2.0, animations: {
                label.alpha = 1.0
            })
        }
    }
    
    func infoLabel(title: String, scale: CGFloat, font: UIFont = UIFont.systemFont(ofSize: 12.0, weight: .ultraLight)) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = title
        label.font = font
        label.sizeToFit()
        label.alpha = 0
        label.center = CGPoint(x: center.x, y: frame.maxY * scale)
        //label.backgroundColor = UIColor.white//.withAlphaComponent(0.2)
        
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
