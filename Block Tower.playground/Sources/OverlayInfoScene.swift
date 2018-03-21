import UIKit
import SpriteKit
import SceneKit

extension SKLabelNode {
    
    func fade() {
        run(SKAction.sequence([SKAction.fadeOut(withDuration: 2.0), SKAction.run({
            self.removeFromParent()
        })]))
    }
    
    func show() {
        run(SKAction.fadeIn(withDuration: 2.0))
    }
    
}

class OverlayInfoScene: SKScene {

    var line1Label: SKLabelNode
    var line2Label: SKLabelNode
    var bottomLabel: SKLabelNode
    var reset: TowerButton
    var ar: TowerButton

    let toggle: () -> Void = {
        if GameManager.current.is3D {
            GameManager.current.showAR()
        } else {
            GameManager.current.show3D()
        }
    }
    
    let resetGame: () -> Void = {
        if GameManager.current.is3D {
            GameManager.current.scnSceneView.jScene.resetWorld()
        } else {
            GameManager.current.arSceneView.jScene.resetWorld()
        }
    }
    
    init(size: CGSize, line1: String, line2: String, bottom: String) {
        line1Label = SKLabelNode(text: line1)
        line2Label = SKLabelNode(text: line2)
        bottomLabel = SKLabelNode(text: bottom)
        reset = TowerButton(title: "Reset", onClick: resetGame)
        ar = TowerButton(title: "AR/3D", onClick: toggle)
        
        super.init(size: size)
        
        setup()
    }
    
    func setup() {
        let infoFont = UIFont.boldSystemFont(ofSize: 16.0).fontName

        scaleMode = .aspectFit

        bottomLabel.fontSize = 16
        bottomLabel.alpha = 0
        bottomLabel.fontName = infoFont
        
        addChild(bottomLabel)
        
        line1Label.fontSize = 16
        
        line1Label.fontName = infoFont
        line1Label.alpha = 0
        addChild(line1Label)
        
        line2Label.fontSize = 16
        
        line2Label.fontName = infoFont
        line2Label.alpha = 0
        addChild(line2Label)
        
        [line1Label, line2Label, bottomLabel].forEach { (label) in
            label.show()
        }
        
        addChild(reset)
        addChild(ar)
        
        updatePositions()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePositions() {
        bottomLabel.position = CGPoint(x: frame.midX, y: 10)
        line1Label.position = CGPoint(x: frame.midX, y: frame.height - 125)
        line2Label.position = CGPoint(x: frame.midX, y: frame.height - 100)
        ar.position = CGPoint(x: frame.minX + reset.frame.width / 2 + 20, y: frame.maxY * 0.1)
        reset.position = CGPoint(x: frame.maxX - reset.frame.width / 2 - 20, y: frame.maxY * 0.1)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let newSize = GameManager.current.is3D ? GameManager.current.scnSceneView.frame.size : GameManager.current.arSceneView.frame.size
        if size != newSize {
            size = newSize
            updatePositions()
        }
    }
    
}

class TowerButton: SKSpriteNode {
    
    let infoFont = UIFont.boldSystemFont(ofSize: 16.0).fontName
    
    let label: SKLabelNode
    let buttonSize = CGSize(width: 100, height: 50)
    
    let onClick: () -> Void
    
    init(title: String, onClick: @escaping () -> Void) {
        self.onClick = onClick
        
        label = SKLabelNode(text: title)
        label.fontSize = 19
        label.fontName = infoFont
        label.fontColor = UIColor.black
        
        let bg = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: buttonSize), cornerRadius: (buttonSize.height - 1) / 2)
        bg.strokeColor = UIColor.white
        bg.fillColor = UIColor.white
        let bgTexture = SKView().texture(from: bg)!
        
        super.init(texture: bgTexture, color: UIColor.white, size: buttonSize)
        
        isUserInteractionEnabled = true 
        
        label.zPosition = 3
        zPosition = 2
        
        label.position = CGPoint(x: frame.midX, y: frame.midY - label.frame.height / 2)
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            alpha = 0.6
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let clickedResets = nodes(at: touch.location(in: self)).filter({ (node) -> Bool in
                return node is TowerButton
            })
            
            if clickedResets.isEmpty {
                 alpha = 1.0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            alpha = 1.0
            onClick()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            alpha = 1.0
            onClick()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
