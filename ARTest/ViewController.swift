//
//  ViewController.swift
//  ARTest
//
//  Created by mahmoud on 11/24/18.
//  Copyright © 2018 mahmoud. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
       // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // cube model
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        cube.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = cube
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        // sphere model
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        material.diffuse.contents =  UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        // importing 3D object.
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
//        if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true){
//        diceNode.position = SCNVector3(0.1, 0.1, -0.2)
//        sceneView.scene.rootNode.addChildNode(diceNode)
//        }
        
        sceneView.automaticallyUpdatesLighting = true
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
    
    override func touchesBegan(_ touches : Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let res = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = res.first{
            let dice = SCNScene(named: "art.scnassets/diceCollada.scn")
            if let diceNode  = dice?.rootNode.childNode(withName: "Dice", recursively: true){
                diceNode.position = SCNVector3(
                    hitResult.worldTransform.columns.3.x,
                    hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                    hitResult.worldTransform.columns.3.z)
                diceArray.append(diceNode)
                sceneView.scene.rootNode.addChildNode(diceNode)
                roll(node: diceNode)
            }
            }
        }
    }
    
    @IBAction func rollButton(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
        
    }
    
    func rollAll()  {
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(node: dice)
            }
        }
    }
    
    func roll(node:SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        node.runAction(
            SCNAction.rotateBy(
            x: CGFloat(randomX * 5)
            , y: 0
            , z: CGFloat(randomZ * 5)
            , duration: 0.5))
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            let planeAnchor = anchor as! ARPlaneAnchor

            let plane  = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
            plane.materials = [material]
            planeNode.geometry = plane
            node.addChildNode(planeNode)

        }else{
            return
        }
    }

}
