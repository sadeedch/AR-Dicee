//
//  ViewController.swift
//  AR-Dicee
//
//  Created by Sadeed Ahmed  on 17/6/20.
//  Copyright © 2020 Sadeed Ahmad. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // debug option to look for feature points (dots in camera)
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        
//        // creates an AR moon
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        
        
//
//        // Create a new scene with 3D dice
//        let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//        diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//        sceneView.scene.rootNode.addChildNode(diceNode)
//        }
            
        sceneView.automaticallyUpdatesLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal    //enables the horizontal detection
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    /// detects the touch and converts into a real world location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            //converts the touch location into a 3D location
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                //creates a new dice scene
                let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        //addeed property will make the dice sit on the plane rather than half inside
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                        )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                
                    // animate to roll and show the random value of dice
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    diceNode.runAction(SCNAction.rotateBy(
                        x: CGFloat(randomX),
                        y: 0,
                        z: CGFloat(randomZ),
                        duration: 0.5))
                }
            }
        }
    }
    
    
    //setting up the horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {

           let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            // y is 0 because we want it on ground not above the ground level.
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)

            // transform the plane into a horizontal postion (x and z axis) as default one is on x and y axis.
            //-float.pi/2 represents the 90 degress clockwise
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            //uses SCNNode in this function's parameter
            node.addChildNode(planeNode)
        }
        else {return}
    }

    
}
