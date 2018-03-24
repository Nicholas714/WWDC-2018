import SceneKit

class IntroScene {
    
    var sceneView = SCNView(frame: GameManager.current.rootSize)
    
    init() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
            
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false
        
        let cameraNode = SCNNode()
        cameraNode.physicsBody = SCNPhysicsBody.dynamic()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 10000
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 400)
        scene.rootNode.addChildNode(cameraNode)
        
        let exp1 = SCNParticleSystem()
        let exp2 = SCNParticleSystem()
        
        for color in [UIColor.brown] {
            exp1.loops = true
            exp1.birthRate = 15000
            exp1.emissionDuration = 5
            exp1.emitterShape = SCNCylinder(radius: 4, height: 40)
            exp1.particleLifeSpan = 15
            exp1.particleVelocity = CGFloat(-100)
            exp1.particleSize = 0.4
            exp1.particleColor = color
            exp1.isAffectedByPhysicsFields = true
            exp1.isAffectedByGravity = true
            scene.addParticleSystem(exp1, transform: SCNMatrix4MakeRotation(0, 0, 0, 0))
        }
        
        for color in [UIColor.brown] {
            exp2.loops = true
            exp2.birthRate = 15000
            exp2.emissionDuration = 5
            exp2.emitterShape = SCNCylinder(radius: 4, height: 40)
            exp2.particleLifeSpan = 15
            exp2.particleVelocity = CGFloat(100)
            exp2.particleSize = 0.4
            exp2.particleColor = color
            exp2.isAffectedByPhysicsFields = true
            exp2.isAffectedByGravity = true
            scene.addParticleSystem(exp2, transform: SCNMatrix4MakeRotation(0, 0, 0, 0))
        }
        
        let moveToTop = SCNAction.move(to: SCNVector3(x: 0, y: 400, z: 0), duration: 15)
        let rotToTop = SCNAction.rotate(toAxisAngle: SCNVector4(-1, 0, 0, Float.pi / 2), duration: 15)
        moveToTop.timingMode = .easeIn
        rotToTop.timingMode = .easeIn
        cameraNode.runAction(SCNAction.group([moveToTop, rotToTop]))
        
        Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { (_) in
            
            let wwdcText = SCNText(string: "WWDC18", extrusionDepth: 1.0)
            let wwdcNode = SCNNode(geometry: wwdcText)
            wwdcNode.position = SCNVector3(x: -33, y: 0, z: 0)
            wwdcNode.rotation = SCNVector4(-1, 0, 0, Float.pi / 2)
            wwdcNode.opacity = 0.0
            let fadeIn = SCNAction.fadeIn(duration: 10)
            wwdcNode.runAction(fadeIn)
            scene.rootNode.addChildNode(wwdcNode)
            
            var rad: CGFloat = 4
            Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { (_) in
                if rad < 100 {
                    rad += 0.5
                    exp1.particleSize += 0.001
                    exp1.birthRate += 30
                    exp2.birthRate += 30
                    exp1.emitterShape = SCNCylinder(radius: rad, height: 40)
                    exp2.particleSize += 0.001
                    exp2.emitterShape = SCNCylinder(radius: rad, height: 40)
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 18, repeats: false) { (_) in
            let a = SCNAction.move(to: SCNVector3Make(0, 0, 0), duration: 8)
            a.timingMode = .easeIn
            cameraNode.runAction(a)
        }
        
        Timer.scheduledTimer(withTimeInterval: 27, repeats: false) { (_) in
            GameManager.current.firstShow3D()
        }
        
        let field = SCNPhysicsField.vortex()
        field.strength = -10
        field.direction = SCNVector3(x: 0, y: -1, z: 0)
        let fieldNode = SCNNode()
        fieldNode.physicsField = field
        scene.rootNode.addChildNode(fieldNode)
    }
    
}
