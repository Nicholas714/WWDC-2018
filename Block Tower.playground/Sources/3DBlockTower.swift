//
//  JSCNScene.swift
//  JengaAR
//
//  Created by Nicholas Grana on 3/17/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import SceneKit
import ARKit
import UIKit

class SCNTowerView: SCNView, ARSCNViewDelegate {
    
    // MARK: Properties
    
    var isCreated = false
    var jScene: SCNTowerScene!
    
    // MARK: Creation of view
    
    func setup() {
        jScene = SCNTowerScene()
        scene = jScene
        jScene.setup(for: self)
        delegate = self

        backgroundColor = UIColor.black
        allowsCameraControl = true
        autoenablesDefaultLighting = true
        scene = scene
        
        defaultCameraController.interactionMode = .orbitTurntable
        defaultCameraController.maximumVerticalAngle = 60.0
        defaultCameraController.minimumVerticalAngle = 1.0
        
        // remove all gestures put pan to move and pinch to zoom
        for gesture in gestureRecognizers! {
            if gesture is UIRotationGestureRecognizer || gesture is UITapGestureRecognizer || gesture is UILongPressGestureRecognizer {
                if let index = gestureRecognizers?.index(of: gesture) {
                    gestureRecognizers!.remove(at: index)
                }
            }
        }
        // add tap gesture to move blocks
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        addGestureRecognizer(tap)
        
        overlaySKScene = OverlayInfoScene(size: frame.size, line1: "Push out each block until the tower falls", line2: "Tap to push a block", bottom: "WWDC18")
    }
    
    // TODO: add button to switch to ARView
    
    // MARK: Gestures
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let hit = hitTest(location, options: [:])
        
        let force = 3
        
        if let first = hit.first, let povPos = pointOfView?.position {
            let side = Side.camSide(cameraPosition: povPos)
            
            switch side {
            case .north:
                first.node.physicsBody?.applyForce(SCNVector3(0, 0, -force), asImpulse: true)
            case .south:
                first.node.physicsBody?.applyForce(SCNVector3(0, 0, force), asImpulse: true)
            case .west:
                first.node.physicsBody?.applyForce(SCNVector3(-force, 0, 0), asImpulse: true)
            case .east:
                first.node.physicsBody?.applyForce(SCNVector3(force, 0, 0), asImpulse: true)
            case .top:
                return
            }
        }
    }
    
}

class SCNTowerScene: SCNScene, UIGestureRecognizerDelegate {
    
    var sceneView: SCNTowerView!
    
    var nodeOrigin = [SCNNode: SCNMatrix4]()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    let camPos = SCNVector3(x: 0, y: 5, z: 25)
    
    func setup(for sceneView: SCNTowerView) {
        self.sceneView = sceneView
        
        setupCamera()
        setupLighting()
        createFloor()
        createTower()
        
        physicsWorld.gravity = SCNVector3(0, -30, 0)
        
        let sphere = SCNSphere(radius: 30)
        sphere.firstMaterial?.isDoubleSided = true
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "clouds.jpg")
        let bgSphere = SCNNode(geometry: sphere)
        rootNode.addChildNode(bgSphere)
    }
    
    func setupCamera() {
        cameraNode.camera = camera
        cameraNode.position = camPos 
        rootNode.addChildNode(cameraNode)
    }
    
    func setupLighting() {
        sceneView.autoenablesDefaultLighting = false
        
        let lighting = UIImage(named: "spherical.jpg")
        sceneView.scene?.lightingEnvironment.contents = lighting
    }
    
    // MARK: Node creation
    
    func createTower() {
        let length: CGFloat = 4
        let width: CGFloat = length / CGFloat(3)
        let height: CGFloat = 1
        
        for y in 0...10 {
            for x in -1...1 {
                let box = SCNBox(width: width, height: height, length: length, chamferRadius: (width / 2) * 0.15)
                
                let wood = JMaterial(type: .wood)
                wood.apply(to: box)
                
                let boxNode = SCNNode(geometry: box)
                
                if y % 2 == 0 {
                    boxNode.position = SCNVector3(x: Float(x) * Float(width), y: Float(y) * Float(height) + 0.5, z: 0)
                } else {
                    boxNode.position = SCNVector3(x: 0, y: Float(y) * Float(height) + 0.5, z: Float(x) * Float(width))
                    boxNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float.pi / 2)
                }
                
                boxNode.physicsBody = SCNPhysicsBody.dynamic()
                boxNode.physicsBody?.friction = 0.9
                boxNode.physicsBody?.mass = 0.1
                rootNode.addChildNode(boxNode)
                
                nodeOrigin[boxNode] = boxNode.transform
            }
        }
        
    }
    
    func createFloor() {
        let floor = SCNFloor()
        JMaterial(type: .floor).apply(to: floor)
        floor.reflectivity = 0.2
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 50, y: 0, z: 50)
        floorNode.physicsBody = SCNPhysicsBody.static()
        rootNode.addChildNode(floorNode)
    }
    
    func resetWorld() {
        for node in rootNode.childNodes(passingTest: { (node, _) -> Bool in
            return node.geometry != nil && node.geometry! is SCNBox
        }) {
            if let origin = nodeOrigin[node] {
                sceneView.pointOfView?.position = camPos
                sceneView.pointOfView?.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
                sceneView.pointOfView?.camera?.fieldOfView = 60
                
                node.physicsBody?.clearAllForces()
                //node.physicsBody = nil
                //SCNAction.move(to: origin, duration: 1.0)
                node.transform = origin
                node.physicsBody?.resetTransform()
            }
        }
    }
    
}

