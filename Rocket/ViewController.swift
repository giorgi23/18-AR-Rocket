//
//  ViewController.swift
//  Rocket
//
//  Created by Giorgi Jashiashvili on 7/2/20.
//  Copyright © 2020 Giorgi Jashiashvili. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var storedRocketArray = [SCNNode]()
    var storedTextArray = [SCNNode]()
    var planeNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        //guard let scene = SCNScene(named: "art.scnassets/rocketship.scn") else {return}
        
        let startingScene = SCNScene()

        // Set the scene to the view
        sceneView.scene = startingScene
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if storedTextArray.isEmpty == false {
            
            for text in storedTextArray {
                text.removeFromParentNode()
            }
        }
        
//Uncomment if you want one rocket at a time
//        if storedRocketArray.isEmpty == false {
//            for rocket in storedRocketArray {
//                rocket.removeFromParentNode()
//            }
//        }
        
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: sceneView)
        
        let pressResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        guard let press = pressResults.first else { return }
        print("press")
            
        guard let rocketScene = SCNScene(named: "art.scnassets/rocketship.scn"),
            let rocketNode = rocketScene.rootNode.childNode(withName: "rocketship", recursively: true)
            else { return }
            
        rocketNode.position = SCNVector3(press.worldTransform.columns.3.x,
                                         press.worldTransform.columns.3.y + 0.05,
                                             press.worldTransform.columns.3.z)
        
        let rocketPhysics = SCNPhysicsBody(type: .dynamic, shape: nil)
        rocketPhysics.isAffectedByGravity = false
        
        
        rocketNode.physicsBody = rocketPhysics

        
        storedRocketArray.append(rocketNode)
            
        sceneView.scene.rootNode.addChildNode(rocketNode)
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "landing")!
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.transform = node.transform
        planeNode.eulerAngles.x = -.pi/2
        
        let planeBody = SCNPhysicsBody(type: .static, shape: nil)
        planeNode.physicsBody = planeBody
        
        planeNodes.append(planeNode)
        
        node.addChildNode(planeNode)
    }
    
    @IBAction func launch(_ sender: UIButton) {
        //TODO: call particle function
        
        let upAction = SCNAction.move(by: SCNVector3(0, 0.3, 0), duration: 3)
        upAction.timingMode = .easeInEaseOut
        
        for rocket in storedRocketArray {
            thrust(rocket)
            rocket.runAction(upAction)
        }
    }
    
    
    @IBAction func takeOff(_ sender: UIButton) {
        //TODO: call particle function
        
        for rocket in storedRocketArray {
            thrust(rocket)
            rocket.physicsBody?.applyForce(SCNVector3(0, 3, 0), asImpulse: true)
        }
        
        placeText()
    }
    
    //declare particle function
    func thrust(_ node: SCNNode) {
        guard let reactorParticles = SCNParticleSystem(named: "reactor", inDirectory: "art.scnassets"),
                       let engineNode = node.childNode(withName: "node2", recursively: true)
                   else { return }
                   reactorParticles.colliderNodes = planeNodes
                   engineNode.addParticleSystem(reactorParticles)


    }
    
    
    func placeText() {
        
        let text = SCNText(string: "Happy 4.07", extrusionDepth: 1.0)
        text.firstMaterial?.diffuse.contents = UIColor.blue
        text.firstMaterial?.isDoubleSided = true
        text.flatness = 0
        
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(-2, 0, -7)
        textNode.geometry = text
        textNode.scale = SCNVector3(0.1, 0.1, 0.1)
        
        textNode.opacity = 0
        let fadeAction = SCNAction.fadeIn(duration: 3)
        fadeAction.timingMode = .easeInEaseOut
        
        textNode.runAction(fadeAction)
        
        storedTextArray.append(textNode)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
