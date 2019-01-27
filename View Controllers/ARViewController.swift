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
    @IBOutlet var shareButton : UIButton!
    @IBOutlet var moneyText1 : UILabel!
    @IBOutlet var moneyText2 : UILabel!
    @IBOutlet var cameraButton : UIButton!
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    var age : Int?
    var startingAmount : Float?
    var monthlyAmount : Float?
    var moneyCount : Int?
    var platformPlaced : Bool = false
    var platformNode : SCNNode? = nil
    var moneyStatus : Int = 1
    //var offsetX : Float = -0.275
    //var offsetZ : Float = -0.25sto
    //var offsetY : Float = 0
    var piles = Array(repeating: Array(repeating: 0, count: 6), count: 12)
    var moneyNodes = [SCNNode]()
    var rowTracker = [Int] ()
    var columnTracker = [Int] ()
    var firstYear : Float?
    var tenYear : Float?
    var twentyFiveYear : Float?
    
    @IBAction func removeMoney( sender : Any){
        clearScreen()
        moneyStatus = 1
        doStuffButton.setTitle("Show me 1 year later", for: .normal)
        moneyText1.isHidden = true
        moneyText2.isHidden = true

    }
    
    func clearScreen(){
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
    
    @IBAction func sharePhoto ( sender : Any){
        detectedLabel.isHidden = true
        placeImage.isHidden = true
        doStuffButton.isHidden = true
        removeStuffButton.isHidden = true
        shareButton.isHidden = true
        moneyText1.isHidden = true
        moneyText2.isHidden = true
        cameraButton.isHidden = false

    }
    
    @IBAction func takePhoto (){
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        view!.drawHierarchy(in: bounds, afterScreenUpdates: false)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [img!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
        doStuffButton.isHidden = false
        removeStuffButton.isHidden = false
        shareButton.isHidden = false
        cameraButton.isHidden = true
    }
    
    @IBAction func placeMoney(sender : Any){
        
        var counter = 0
        var timeInterval = 0.05
        
        if moneyStatus == 1{
            moneyCount = Int(ceil(firstYear! / 100))
            moneyText1.isHidden = false
            moneyText2.isHidden = false
            moneyText1.text = String(format: "$%.02f", firstYear!)
            moneyText2.text = "after 1 year"
        }
        else if(moneyStatus == 2){
            clearScreen()
            moneyCount = Int(ceil(tenYear! / 100))
            moneyText1.text = String(format: "$%.02f", tenYear!)
            moneyText2.text = "after 10 years"
            timeInterval = 0.025
        }
        else if(moneyStatus == 3){
            clearScreen()
            moneyCount = Int(ceil(twentyFiveYear! / 100))
            moneyText1.text = String(format: "$%.02f", twentyFiveYear!)
            moneyText2.text = "after 25 years"
            timeInterval = 0.001

        }
        else if(moneyStatus == 4){
             self.performSegue(withIdentifier: "lastScreenSegue", sender: self)
        }
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            counter += 1
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.1, chamferRadius: 0)
            _ = SCNNode(geometry: box)
            
            let cashNumber = Int.random(in:0 ... 2)
            
            var casheScene = SCNScene(named: "art.scnassets/final-cash.scn")
            var cashNode = casheScene!.rootNode.childNode(withName: "cash", recursively: false)
            
            if (cashNumber == 0){
                casheScene = SCNScene(named: "art.scnassets/final-cash2.scn")
                cashNode = casheScene!.rootNode.childNode(withName: "cash", recursively: false)
            }
            else if(cashNumber == 1){
                casheScene = SCNScene(named: "art.scnassets/final-cash3.scn")
                cashNode = casheScene!.rootNode.childNode(withName: "cash", recursively: false)
            }
            
            let randX = Int.random(in: 0 ... 11)
            let randY = Int.random(in: 0 ... 5)
            
            let offsetX = (Float(randX) * 0.05) - 0.275
            let offsetZ = (Float(randY) * 0.1) - 0.25
            let offsetY = (Float(self.piles[randX][randY]) * 0.015) + 0.025
            
            
            self.piles[randX][randY] += 1
            
            let boxX = (self.platformNode?.worldPosition.x)! + offsetX
            let boxY = (self.platformNode?.worldPosition.y)! + offsetY
            let boxZ = (self.platformNode?.worldPosition.z)! + offsetZ
            
            cashNode!.position = SCNVector3(boxX,boxY + 2,boxZ)
            cashNode!.name = "money"
            self.sceneView.scene.rootNode.addChildNode(cashNode!)
            
            let moveBy = SCNAction.move(to: SCNVector3(boxX,boxY,boxZ), duration: 0.5)
            cashNode?.runAction(moveBy)
            
            if counter >= (self.moneyCount! - 1) {
                timer.invalidate()
            }
        }
        
        if(moneyStatus == 1){
            moneyStatus = 2
            doStuffButton.setTitle("Show me 10 years later", for: .normal)
        }
        else if(moneyStatus == 2){
            moneyStatus = 3
            doStuffButton.setTitle("Show me 25 years later", for: .normal)
        }
        else if(moneyStatus == 3){
            doStuffButton.setTitle("I'm ready to start saving", for: .normal)
            moneyStatus = 4
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        configureLighting()
        
        doStuffButton.layer.cornerRadius = 7
        doStuffButton.clipsToBounds = true
        
        monthlyAmount = mainDelegate.monthlyIncome ?? 0
        age = mainDelegate.age ?? 0
        startingAmount = mainDelegate.startingAmount ?? 0
        firstYear = firstYearCalc(principal: startingAmount!, monthly: monthlyAmount!)
        tenYear = tenYearCalc(principal: startingAmount!, monthly: monthlyAmount!)
        twentyFiveYear = twentyFiveYearCalc(principal: startingAmount!, monthly: monthlyAmount!)
        
        print(firstYear)
        print(tenYear)
        print(twentyFiveYear)
    }
    
    func firstYearCalc(principal : Float, monthly : Float) -> Float{
        let total = pow(principal * ( 1 + (0.0845 / 1)), 1 * 1)
        return (total + (monthly * 12))
    }
    
    func tenYearCalc(principal : Float, monthly : Float) -> Float {
        var total = principal * 1.0845
        var annualDeposit = monthly * 12
        total += annualDeposit
        
        for _ in 0...8 {
            var newTotal = total * 1.0845
            newTotal += annualDeposit
            total = newTotal
        }
        
        return (total)
    }
    
    func twentyFiveYearCalc(principal : Float, monthly : Float) -> Float {
        var total = principal * 1.0845
        var annualDeposit = monthly * 12
        total += annualDeposit
        
        for _ in 0...23 {
            var newTotal = total * 1.0845
            newTotal += annualDeposit
            total = newTotal
        }
        
        return (total)
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
                self.detectedLabel.text = "Tap to place surface"
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
        self.shareButton.isHidden = false
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
        recognizer.isEnabled = false
        
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

