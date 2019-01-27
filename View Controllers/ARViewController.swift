//
//  ViewController.swift
//  CashMoney
//
//  Created by Cory Da Silva on 1/26/19.
//  Copyright © 2019 Cory Da Silva. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var detectedLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet var doStuffButton : UIButton!
    @IBOutlet var removeStuffButton : UIButton!
    
    var platformPlaced : Bool = false
    var platformNode : SCNNode? = nil
    //var offsetX : Float = -0.275
    //var offsetZ : Float = -0.25sto
    //var offsetY : Float = 0
    var piles = Array(repeating: Array(repeating: 0, count: 6), count: 12)
    var moneyNodes = [SCNNode]()
    var rowTracker = [Int] ()
    var columnTracker = [Int] ()
    
    @IBAction func removeMoney( sender : Any){
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if(node.name == "money"){
                node.removeFromParentNode()
            }
            for i in 0...11{
                for j in 0...5{
                    piles[i][j] = 0
                }
            }
        }
    }
    
    @IBAction func placeMoney(sender : Any){
        
        var counter = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            counter += 1
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.1, chamferRadius: 0)
            let node = SCNNode(geometry: box)
            
            let cashNumber = Int.random(in:0 ... 2)
            
            var casheScene = SCNScene(named: "art.scnassets/greenmoney.scn")
            var cashNode = casheScene!.rootNode.childNode(withName: "Cube", recursively: false)
            
            if (cashNumber == 0){
                casheScene = SCNScene(named: "art.scnassets/greenmoney2.scn")
                cashNode = casheScene!.rootNode.childNode(withName: "Cube", recursively: false)
            }
            else if(cashNumber == 1){
                casheScene = SCNScene(named: "art.scnassets/greenmoney3.scn")
                cashNode = casheScene!.rootNode.childNode(withName: "Cube", recursively: false)
            }
            
            let randX = Int.random(in: 0 ... 11)
            let randY = Int.random(in: 0 ... 5)
            
            let offsetX = (Float(randX) * 0.05) - 0.275
            let offsetZ = (Float(randY) * 0.1) - 0.25
            let offsetY = (Float(self.piles[randX][randY]) * 0.015) + 0.025
            
            print(offsetY)
            
            self.piles[randX][randY] += 1
            
            let boxX = (self.platformNode?.worldPosition.x)! + offsetX
            let boxY = (self.platformNode?.worldPosition.y)! + offsetY
            let boxZ = (self.platformNode?.worldPosition.z)! + offsetZ
            
            //print("X", boxX, "Y",boxY, "Z",boxZ)
            cashNode!.position = SCNVector3(boxX,boxY + 2,boxZ)
            cashNode!.name = "money"
            self.sceneView.scene.rootNode.addChildNode(cashNode!)
            
            let moveBy = SCNAction.move(to: SCNVector3(boxX,boxY,boxZ), duration: 0.75)
            cashNode?.runAction(moveBy)
            
            if counter == 1000 {
                timer.invalidate()
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        configureLighting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async { // Make sure you're on the main thread here
            if(!self.platformPlaced){
                self.detectedLabel.isHidden = false;
                self.placeImage.isHidden = false;
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        
        guard let hitTestResult = hitTestResults.first else { return }
        self.platformPlaced = true
        self.detectedLabel.isHidden = true
        self.placeImage.isHidden = true
        self.doStuffButton.isHidden = false
        self.removeStuffButton.isHidden = false
        
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        //Create square to place money
        let width = CGFloat(0.6)
        let height = CGFloat(0.6)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.transparentBlack
        
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        //add to scene
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        platformNode = planeNode
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
    open class var transparentBlack: UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.50)
    }
}

