//
//  ViewController.swift
//  pubGDemo
//
//  Created by FH on 2020/7/13.
//  Copyright © 2020 Fuhan. All rights reserved.
//

import UIKit

class Vector4 : CustomStringConvertible {
    static let right = Vector4(x: 1, y: 0, z: 0, w: 0)
    static let forward = Vector4(x: 0, y: 1, z: 0, w: 0)
    static let up = Vector4(x: 0, y: 0, z: 1, w: 0)
    var x: Float = 0
    var y: Float = 0
    var z: Float = 0
    var w: Float = 0
    
    convenience init(x: Float, y: Float, z: Float, w: Float) {
        self.init()
        
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    var description: String {
        let tmpX = Int(x * 100)
        let tmpY = Int(y * 100)
        let tmpZ = Int(z * 100)
        return "[\(Float(tmpX) / 100.0), \(Float(tmpY) / 100.0), \(Float(tmpZ) / 100.0)]"
    }
    
    func norm() -> Float {
        return sqrt(x * x + y * y + z * z + w * w)
    }
    
    func normalize() -> Vector4 {
        let frt = norm()
        self.x = x / frt
        self.y = y / frt
        self.z = z / frt
        self.w = w / frt
        return self
    }
    
    func cross(rhs: Vector4) -> Vector4 {
        let vec4 = Vector4()
        vec4.x = y * rhs.z - rhs.y * z
        vec4.y = z * rhs.x - rhs.z * x
        vec4.z = x * rhs.y - rhs.x * y
        return vec4
    }
    
    func reverse() -> Vector4 {
        if self.x != 0 {
            self.x = -self.x
        }
        if self.y != 0 {
            self.y = -self.y
        }
        if self.z != 0 {
            self.z = -self.z
        }
        return self
    }
    
    static func *(lhs: Vector4, rhs: CATransform3D) -> Vector4 {
        let vec4 = Vector4()
        vec4.x = lhs.x * Float(rhs.m11) + lhs.y * Float(rhs.m21) + lhs.z * Float(rhs.m31) + lhs.w * Float(rhs.m41)
        vec4.y = lhs.x * Float(rhs.m12) + lhs.y * Float(rhs.m22) + lhs.z * Float(rhs.m32) + lhs.w * Float(rhs.m42)
        vec4.z = lhs.x * Float(rhs.m13) + lhs.y * Float(rhs.m23) + lhs.z * Float(rhs.m33) + lhs.w * Float(rhs.m43)
        vec4.w = lhs.x * Float(rhs.m14) + lhs.y * Float(rhs.m24) + lhs.z * Float(rhs.m34) + lhs.w * Float(rhs.m44)
        return vec4
    }
}

class ModelView : UIView {
    weak var config: ConfigModel!
    let screenCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    // speed == 4 when moving
    var speed: Float = 0
    var radian: Float = 0
    var recvLayer: CAShapeLayer!
    var soundLayer: CAShapeLayer!
    private(set) var forward: Vector4 = Vector4.right
    private(set) var right: Vector4 = Vector4(x: 0, y: -1, z: 0, w: 0)
    var up: Vector4 {
        return Vector4.up
    }
    var angel: Float {
        return radian / Float.pi * 180
    }
    var worldSpace: (x: CGFloat, y: CGFloat) {
        var worldX = self.center.x - screenCenter.x
        var worldY = screenCenter.y - self.center.y
        if worldX != 0
            && fabsf(Float(worldX)) < Float.ulpOfOne {
            worldX = 0
        }
        if worldY != 0
            && fabsf(Float(worldY)) < Float.ulpOfOne {
            worldY = 0
        }
        return (worldX, worldY)
    }
    
    init(frame: CGRect, config: ConfigModel) {
        super.init(frame: frame)
        self.config = config
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    convenience init(config: ConfigModel) {
        self.init(frame: .zero, config: config)
    }
    
    func update(radian: Float) {
        if speed > 0 {
            self.radian = radian
        }
    }
    
    func move() {
        speed = config.moveSpeed
    }
    
    func stop() {
        speed = 0
    }
    
    func handleVectors() {
        let transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(radian), 0, 0, 1)
        forward = Vector4.right * transform
        right = up.cross(rhs: forward).reverse()
    }
    
    func render() {
        if speed == 0 { return }
        
        let factorX: Float = 1
        let factorY: Float = -1
        let xChange = CGFloat(speed * factorX * cos(radian))
        let yChange = CGFloat(speed * factorY * sin(radian))
        self.center = CGPoint(x: self.center.x + xChange,
                              y: self.center.y + yChange)
        self.transform = CGAffineTransform.init(rotationAngle: CGFloat(Float.pi * 2 - radian))
        handleVectors()
    }
    
    func drawRecvCircle(recvRange: UInt) {
        if recvLayer != nil {
            recvLayer.removeFromSuperlayer()
            recvLayer = nil
        }
        
        if recvRange > 0 {
            let halfSize:CGFloat = min(bounds.size.width / 2, bounds.size.height / 2)
            let desiredLineWidth: CGFloat = 1
            let circlePath = UIBezierPath(
                    arcCenter: CGPoint(x: halfSize, y: halfSize),
                    radius: CGFloat(recvRange),
                    startAngle: CGFloat(0),
                    endAngle:CGFloat(Double.pi * 2),
                    clockwise: true)
        
            recvLayer = CAShapeLayer()
            recvLayer.path = circlePath.cgPath
            recvLayer.fillColor = UIColor.clear.cgColor
            recvLayer.strokeColor = UIColor.blue.cgColor
            recvLayer.lineWidth = desiredLineWidth
            recvLayer.lineDashPattern = [10, 15]
            layer.addSublayer(recvLayer)
        }
    }
    
    func drawSoundCircle(open: Bool) {
        if soundLayer != nil {
            soundLayer.removeFromSuperlayer()
            soundLayer = nil
        }
        
        if open {
            let halfSize:CGFloat = min(bounds.size.width / 2, bounds.size.height / 2)
            let desiredLineWidth: CGFloat = 1
            let circlePath = UIBezierPath(
                        arcCenter: CGPoint(x: halfSize, y: halfSize),
                        radius: CGFloat(Sound3DRadius),
                        startAngle: CGFloat(0),
                        endAngle:CGFloat(Double.pi * 2),
                        clockwise: true)
            soundLayer = CAShapeLayer()
            soundLayer.path = circlePath.cgPath
            soundLayer.fillColor = UIColor.clear.cgColor
            soundLayer.strokeColor = UIColor.green.cgColor
            soundLayer.lineWidth = desiredLineWidth
            soundLayer.lineDashPattern = [3, 6]
            layer.addSublayer(soundLayer)
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.red.set()
        let space: CGFloat = 4
        let x = space
        let y = space
        let width = rect.size.width - x * 2
        let height = rect.size.height - y * 2
        
        let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height),
                                cornerRadius: width / 2)
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: rect.size.width / 2, y: space))
        trianglePath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2))
        trianglePath.addLine(to: CGPoint(x: rect.size.width / 2, y: rect.size.height - space))
        trianglePath.close()
        trianglePath.usesEvenOddFillRule = false
        trianglePath.append(path)
        trianglePath.fill()
    }
}

//////////////////////////////////////////////////

class JoystickView : UIView {
    var onMoveFn: ((Float) -> ())!
    var onStopFn: (() -> ())!
    var circleView: UIView!
    var indicateView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(moveFn: @escaping (Float) -> (),
                     stopFn: @escaping () -> ()) {
        self.init(frame: .zero)
        self.onMoveFn = moveFn
        self.onStopFn = stopFn
        
        self.configureLayout { it in
            it.isEnabled = true
            it.alignItems = .center
            it.justifyContent = .center
        }
        
        circleView = UIView()
        circleView.configureLayout { it in
            it.isEnabled = true
            it.width = 100
            it.height = 100
            it.alignItems = .center
            it.justifyContent = .center
        }
        circleView.layer.cornerRadius = 50
        circleView.backgroundColor = .purple
        self.addSubview(circleView)
        
        indicateView = UIView()
        indicateView.configureLayout { it in
            it.isEnabled = true
            it.width = 40
            it.height = 40
        }
        indicateView.layer.cornerRadius = 20
        indicateView.backgroundColor = .yellow
        circleView.addSubview(indicateView)
        
        self.yoga.applyLayout(preservingOrigin: false)
    }

    func getRadian(start: CGPoint, end: CGPoint) -> Float {
        let ab = fabsf(Float(end.x - start.x))
        let bc = fabsf(Float(end.y - start.y))
        let ac = sqrtf(ab * ab + bc * bc)
        var radian: Float = 0
        
        if ac == 0 {
            return -1
        }
        if ab == 0 {
            radian = end.y > start.y ? (Float.pi * 3 / 2.0) : (Float.pi / 2)
        } else if bc == 0 {
            radian = end.x > start.x ? 0 : Float.pi
        } else {
            let denominator = ab * ab + ac * ac - bc * bc
            let numerator = 2 * ac * ab
            radian = acosf(denominator / numerator)
            if end.x > start.x && end.y < start.y {
                radian += 0
            } else if end.x < start.x && end.y < start.y {
                radian = Float.pi - radian
            } else if end.x < start.x && end.y > start.y {
                radian += Float.pi
            } else {
                radian = Float.pi * 2 - radian
            }
        }
        return radian
    }

    func handleTouch(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            let centerPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            let x2 = (point.x - centerPoint.x) * (point.x - centerPoint.x)
            let y2 = (point.y - centerPoint.y) * (point.y - centerPoint.y)
            let distance = sqrt(x2 + y2)
            let radian = getRadian(start: centerPoint, end: point)
            if distance > frame.size.width / 2 {
                let factorX: Float = 1
                let factorY: Float = -1
                let x = (self.frame.size.width / 2) * CGFloat(1 + factorX * cos(radian))
                let y = (self.frame.size.height / 2) * CGFloat(1 + factorY * sin(radian))
                self.indicateView.center = CGPoint(x: x, y: y)
            } else {
                self.indicateView.center = point
            }
            self.onMoveFn(radian)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {[unowned self] in
            self.indicateView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        }
        self.onStopFn()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {[unowned self] in
            self.indicateView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        }
        self.onStopFn()
    }
}

//////////////////////////////////////////////////

class ViewController: UIViewController {
    var displayLink: CADisplayLink!
    var config: ConfigModel!
    var model: ModelView!
    var joystick: JoystickView!
    var modelInfo: UILabel!
        
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
    }
    
    override func viewDidLayoutSubviews() {
        if (config == nil
            && UIScreen.main.bounds.width > UIScreen.main.bounds.height) {
            config = ConfigModel.loadFromLocal({[unowned self] range in
                self.model.drawRecvCircle(recvRange: range)
//                self.model.drawRecvCircle(recvRange: self.config.audioModel == AudioModel.world ? range : 0)
            }, { _ in
//                self.model.drawRecvCircle(recvRange: type == AudioModel.world ? self.config.recvRange : 0)
            }, {[unowned self] type in
                self.model.drawSoundCircle(open: type != SoundEffect.disable)
            })
            
            view.configureLayout { it in
                it.isEnabled = true
            }
            
            let infoDiv = UIView()
            infoDiv.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.paddingLeft = 4
                it.position = .absolute
                it.left = 30
                it.top = 20
            }
            infoDiv.backgroundColor = .white
            view.addSubview(infoDiv)
            modelInfo = UILabel()
            modelInfo.configureLayout { it in
                it.isEnabled = true
                it.width = 140
                it.height = 60
            }
            modelInfo.numberOfLines = 0
            modelInfo.lineBreakMode = .byWordWrapping
            modelInfo.font = UIFont.systemFont(ofSize: 11)
            modelInfo.textColor = .black
            infoDiv.addSubview(modelInfo)
            
            let btnSetting = UIButton()
            btnSetting.configureLayout { it in
                it.isEnabled = true
                it.marginTop = 20
                it.marginRight = 20
                it.alignSelf = .flexEnd
                it.width = 60
                it.height = 25
            }
            btnSetting.setTitle("Setting", for: .normal)
            btnSetting.setTitleColor(.orange, for: .normal)
            btnSetting.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnSetting.addTarget(self, action: #selector(onSetting), for: .touchUpInside)
            view.addSubview(btnSetting)
            
            joystick = JoystickView(moveFn: {[unowned self] radian in
                self.model.move()
                self.model.update(radian: radian)
            }, stopFn: {[unowned self] in
                self.model.stop()
            })
            joystick.configureLayout { it in
                it.isEnabled = true
                it.position = .absolute
                it.left = 60
                it.bottom = 30
            }
            view.addSubview(joystick)
            view.yoga.applyLayout(preservingOrigin: false)
            
            model = ModelView(config: config)
            model.bounds = CGRect(x: 0, y: 0, width: 18, height: 18)
            model.center = view.center
            view.addSubview(model)
            
            drawCoordinate()
        }
    }

    @objc func onSetting() {
        let settingVC = SettingVC(config: config)
        settingVC.modalPresentationStyle = .fullScreen
        present(settingVC, animated: true, completion: nil)
    }
    
    func drawCoordinate() {
        let desiredLineWidth: CGFloat = 1
        var circlePath = UIBezierPath(
                arcCenter: CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2),
                radius: CGFloat(Sound3DRadius),
                startAngle: CGFloat(0),
                endAngle:CGFloat(Double.pi * 2),
                clockwise: true)

        let sound3DLayer = CAShapeLayer()
        sound3DLayer.path = circlePath.cgPath
        sound3DLayer.fillColor = UIColor.clear.cgColor
        sound3DLayer.strokeColor = UIColor.green.cgColor
        sound3DLayer.lineWidth = desiredLineWidth
        view.layer.addSublayer(sound3DLayer)
        
        circlePath = UIBezierPath(
                arcCenter: CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2),
                radius: CGFloat(RecvRangeRadius),
                startAngle: CGFloat(0),
                endAngle:CGFloat(Double.pi * 2),
                clockwise: true)

        let receRangeLayer = CAShapeLayer()
        receRangeLayer.path = circlePath.cgPath
        receRangeLayer.fillColor = UIColor.clear.cgColor
        receRangeLayer.strokeColor = UIColor.blue.cgColor
        receRangeLayer.lineWidth = desiredLineWidth
        view.layer.addSublayer(receRangeLayer)
        
        // TODO: 当前不需要测试
//        circlePath = UIBezierPath(
//                arcCenter: CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2),
//                radius: CGFloat(RecvRangeRadius * 2),
//                startAngle: CGFloat(0),
//                endAngle:CGFloat(Double.pi * 2),
//                clockwise: true)
//
//        let outRangeLayer = CAShapeLayer()
//        outRangeLayer.path = circlePath.cgPath
//        outRangeLayer.fillColor = UIColor.clear.cgColor
//        outRangeLayer.strokeColor = UIColor.lightGray.cgColor
//        outRangeLayer.lineWidth = desiredLineWidth
//        view.layer.addSublayer(outRangeLayer)
        
        
        // draw model
        model.drawRecvCircle(recvRange: config.recvRange)
//        model.drawRecvCircle(recvRange: config.audioModel == AudioModel.world ? config.recvRange : 0)
        self.model.drawSoundCircle(open: self.config.soundEffect != SoundEffect.disable)
        // start fps callback
        displayLink = CADisplayLink(target: self, selector: #selector(onDisplayRefresh))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: .current, forMode: .common)
    }
    
    @objc func onDisplayRefresh() {
        model.render()
        // update model space info
        let worldSpace = model.worldSpace
        modelInfo.text = """
        x: \(String(format: "%0.1f", worldSpace.x)), y: \(String(format: "%0.1f", worldSpace.y))
        angel: \(String(format: "%0.1f", model.angel)), radian: \(String(format: "%0.1f", model.radian))
        forward: \(model.forward)
        right: \(model.right)
        """
        // update position info
        self.config.updatePosition(position: [
                NSNumber(value: Float(worldSpace.x)),
                NSNumber(value: Float(worldSpace.y)),
                NSNumber(value: 0)
            ],
                                   forward: [
                NSNumber(value: Float(model.forward.x)),
                NSNumber(value: Float(model.forward.y)),
                NSNumber(value: Float(model.forward.z))
            ],
                                   right: [
                NSNumber(value: Float(model.right.x)),
                NSNumber(value: Float(model.right.y)),
                NSNumber(value: Float(model.right.z))
            ],
                                   up: [
                NSNumber(value: Float(model.up.x)),
                NSNumber(value: Float(model.up.y)),
                NSNumber(value: Float(model.up.z))
        ])
    }
}
