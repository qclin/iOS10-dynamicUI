//
//  ViewController.swift
//  DynamicField
//
//  Created by Qiao Lin on 2/19/17.
//  Copyright © 2017 Qiao Lin. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {

    @IBOutlet weak var orangeView: UIView!
    var views: [UIView]{
        return [self.squareView, self.pentagonView]
    }
    
    var behaviors: [UIDynamicBehavior]{
        return [collision, noise]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        animator.addBehavior(collision)
//        animator.addBehavior(centerGravity)
//        animator.addBehavior(gravity)
//        animator.addBehavior(turbulence)
//        animator.addBehavior(noise)
        
        view.addSubview(squareView)
        view.addSubview(pentagonView)
        animator.addBehaviors(behaviors)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func panning(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state{
        case .began:
            // when panning begins, disable animator to not affect the orangeView
//            collision.removeItem(orangeView)
//            gravity.removeItem(orangeView)
//            turbulence.removeItem(orangeView)
//            noise.removeItem(orangeView)
//            velocity.removeItem(orangeView)
            collision.removeItems()
            noise.removeItems()
        case .changed:
            // when panning in progress, move orangeView where finger is pointing
            sender.view?.center = sender.location(in: view)
        case .ended, .cancelled:
            // when panning ends, re-enable behaviors
//            collision.addItem(orangeView)
//            gravity.addItem(orangeView)
//            turbulence.addItem(orangeView)
//            noise.addItem(orangeView)
//            velocity.addItem(orangeView)
            collision.addItems(views)
            noise.addItems(views)
        default: ()
        }
    }

    lazy var animator : UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.view)
//        animator.isDebugEnabled = true
        return animator
    }()
    
    lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior(items: self.views)
        collision.translatesReferenceBoundsIntoBoundary = true
        return collision
    }()
    
    lazy var centerGravity : UIFieldBehavior = {
        let centerGravity = UIFieldBehavior.radialGravityField(position: self.view.center)
        centerGravity.addItem(self.orangeView)
        centerGravity.region = UIRegion(radius: 200)
        centerGravity.strength = -1 //repel items
        return centerGravity
    }()
    
    lazy var gravity : UIFieldBehavior = {
        let vector = CGVector(dx: 0.4, dy: 1.0)
        let gravity = UIFieldBehavior.linearGravityField(direction: vector)
//        gravity.strength = CGFloat(0.1)
//        gravity.animationSpeed = 1.8
        gravity.region = UIRegion(radius: 200)
        gravity.addItem(self.orangeView)
        return gravity
    }()
    
    lazy var turbulence : UIFieldBehavior = {
        let turbulence = UIFieldBehavior.turbulenceField(smoothness: 0.5, animationSpeed: 60.0)
        turbulence.strength = 12.0
        turbulence.region = UIRegion(radius: 200.0)
        turbulence.position = self.orangeView.bounds.size.center
        turbulence.addItems(self.views)
        return turbulence
    }()
    
    
    lazy var noise: UIFieldBehavior = {
        let noise = UIFieldBehavior.noiseField(smoothness: 0.9, animationSpeed: 1.0)
        noise.addItems(self.views)
        return noise
    }()
    
    lazy var magnet: UIFieldBehavior = {
        let magnet = UIFieldBehavior.magneticField()
        magnet.addItems(self.views)
        return magnet
    }()
    
    lazy var velocity: UIFieldBehavior = {
        let vector = CGVector(dx: -0.4, dy: -0.5)
        let velocity = UIFieldBehavior.velocityField(direction: vector)
        velocity.position = self.view.center
        velocity.region = UIRegion(radius: 100.0)
        velocity.addItem(self.orangeView)
        return velocity
    }()
    
    lazy var squareView:UIView = {
        let view = UIView(frame: CGRect(x:0, y:0, width: 100, height: 100))
        view.createPanGestureRecognizerOn(self)
        view.backgroundColor = UIColor.brown
        return view
    }()
    
    lazy var pentagonView: PentagonView = {
        let view = PentagonView.pentagonViewWithDiameter(100)
        view.createPanGestureRecognizerOn(self)
        view.backgroundColor = UIColor.clear
        view.center = self.view.center
        return view
    }()
    
    // recenter the gravity when user rotates the device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        centerGravity.position = size.center
    }
    
}

extension CGSize {
    public var center: CGPoint {
        return CGPoint(x: width/2.0, y: height/2.0)
    }
}

// extend class to add array of items
extension UIFieldBehavior{
    public func addItems(_ items: [UIDynamicItem]){
        for item in items{
            addItem(item)
        }
    }
    
    public func removeItems(){
        for item in items{
            removeItem(item)
        }
    }
}

extension UICollisionBehavior{
    public func addItems(_ items: [UIDynamicItem]){
        for item in items{
            addItem(item)
        }
    }
    
    public func removeItems(){
        for item in items{
            removeItem(item)
        }
    }
}
// extend class to add array of behaviors
extension UIDynamicAnimator{
    public func addBehaviors(_ behaviors: [UIDynamicBehavior]){
        for behavior in behaviors{
            addBehavior(behavior)
        }
    }
}

// perform a function over every item in this array of numbers
extension StrideThrough{
    func forEach(_ f: (Iterator.Element) -> Void){
        for item in self{
            f(item)
        }
    }
}

class PentagonView: UIView{
    private var diameter: CGFloat = 0.0
    
    class func pentagonViewWithDiameter(_ diameter: CGFloat) -> PentagonView{
        return PentagonView(diameter: diameter)
    }
    
    init(diameter: CGFloat) {
        self.diameter = diameter
        super.init(frame: CGRect(x:0, y:0, width: diameter, height: diameter))
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    var radius: CGFloat{
        return diameter / 2.0
    }
    
    func pointFromAngle(_ angle: Double) -> CGPoint{
        let x = radius + (radius * cos(CGFloat(angle)))
        let y = radius + (radius * sin(CGFloat(angle)))
        return CGPoint(x: x, y: y)
    }
    
    lazy var path: UIBezierPath = {
        let path = UIBezierPath()
        path.move(to: self.pointFromAngle(0))
        
        let oneSlice = (M_PI * 2.0)/5.0
        let lessOneSlice = (M_PI * 2.0) - oneSlice
        
        stride(from: oneSlice, through: lessOneSlice, by: oneSlice).forEach{
            path.addLine(to: self.pointFromAngle($0))
        }
        path.close()
        return path
    }()
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        UIColor.clear.setFill()
        context.fill(rect)
        UIColor.yellow.setFill()
        path.fill()
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType{
        return .path
    }
    override var collisionBoundingPath: UIBezierPath{
        let path = self.path.copy() as! UIBezierPath
        path.apply(CGAffineTransform(translationX: -radius, y: -radius))
        return path
    }
}

extension UIView{
    func createPanGestureRecognizerOn(_ obj: AnyObject){
        let pgr = UIPanGestureRecognizer(
            target: obj, action: #selector(ViewController.panning(_:)))
        addGestureRecognizer(pgr)
    }
}
