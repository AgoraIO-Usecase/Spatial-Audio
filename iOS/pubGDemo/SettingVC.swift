//
//  SettingVC.swift
//  pubGDemo
//
//  Created by FH on 2020/7/13.
//  Copyright © 2020 Fuhan. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {
    var config: ConfigModel!
    var btnSubmit: UIButton!
    var txtMoveSpeed: UITextField!
    var txtAppId: UITextField!
    var txtChannel: UITextField!
    var txtRange: UITextField!
    var txtPlayerId: UITextField!
    var txtTeamId: UITextField!

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    convenience init(config: ConfigModel) {
        self.init()        
        self.config = config
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(onTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func onTap() {
        if let speed = txtMoveSpeed.text {
            if let moveSpeed = Float(speed), moveSpeed > 0 {
                config.moveSpeed = moveSpeed
            }
        }
        txtMoveSpeed.resignFirstResponder()
        config.appId = txtAppId.text ?? ""
        txtAppId.resignFirstResponder()
        config.channelId = txtChannel.text ?? ""
        txtChannel.resignFirstResponder()
        if let range = txtRange.text {
            if let recvRange = UInt(range),
            recvRange > 0 && recvRange != config.recvRange {
                config.recvRange = recvRange
            }
        }
        txtRange.resignFirstResponder()
        if let rtcUserId = txtPlayerId.text, rtcUserId.count > 0 {
            config.rtcUserId = UInt(rtcUserId)
        }
        txtPlayerId.resignFirstResponder()
        if let teamId = txtTeamId.text, teamId.count > 0 {
            config.teamId = Int(teamId) ?? 123
        }
        txtTeamId.resignFirstResponder()
        
        config.saveToLocal()
    }
    
    override func viewDidLayoutSubviews() {
        if self.btnSubmit == nil
            && UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            view.configureLayout { it in
                it.isEnabled = true
            }
            
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let btnBack = UIButton()
            btnBack.backgroundColor = .brown
            btnBack.setTitle("Close", for: .normal)
            btnBack.setTitleColor(.orange, for: .normal)
            btnBack.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnBack.addTarget(self, action: #selector(onClose), for: .touchUpInside)
            btnBack.configureLayout { it in
                it.isEnabled = true
                it.marginTop = YGValue(statusBarHeight)
                it.marginLeft = 20
                it.width = 60
                it.height = 25
            }
            view.addSubview(btnBack)
            
            let scroll = UIScrollView()
            scroll.configureLayout { it in
                it.isEnabled = true
                it.width = YGValue(UIScreen.main.bounds.width - 20 * 2)
                it.marginTop = 20
                it.marginLeft = 20
                it.marginRight = 20
                it.maxHeight = YGValue(UIScreen.main.bounds.height - statusBarHeight - 25)
            }
            view.addSubview(scroll)
            
            let content = UIView()
            content.configureLayout { it in
                it.isEnabled = true
            }
            scroll.addSubview(content)
            
            let lineMarginBottom = 6
            // move speed
            let line0 = UIView()
            line0.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line0)
            let lblMoveSpeed = UILabel()
            lblMoveSpeed.configureLayout { it in
                it.isEnabled = true
                it.width = 120
                it.marginBottom = 4
            }
            lblMoveSpeed.font = UIFont.systemFont(ofSize: 14)
            lblMoveSpeed.textColor = .white
            lblMoveSpeed.text = "Move Speed: "
            line0.addSubview(lblMoveSpeed)
            txtMoveSpeed = UITextField()
            txtMoveSpeed.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtMoveSpeed.autocorrectionType = .no
            txtMoveSpeed.autocapitalizationType = .none
            txtMoveSpeed.text = "\(config.moveSpeed)"
            txtMoveSpeed.backgroundColor = .white
            txtMoveSpeed.font = UIFont.systemFont(ofSize: 14)
            let txtMoveSpeedPadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtMoveSpeed.leftView = txtMoveSpeedPadding
            txtMoveSpeed.leftViewMode = .always
            line0.addSubview(txtMoveSpeed)
            
            // appId info
            let line1 = UIView()
            line1.configureLayout { it in
                it.isEnabled = true
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line1)
            let lblAppId = UILabel()
            lblAppId.configureLayout { it in
                it.isEnabled = true
                it.width = 120
                it.marginBottom = 4
            }
            lblAppId.font = UIFont.systemFont(ofSize: 14)
            lblAppId.textColor = .white
            lblAppId.text = "AppId: "
            line1.addSubview(lblAppId)
            txtAppId = UITextField()
            txtAppId.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtAppId.autocorrectionType = .no
            txtAppId.autocapitalizationType = .none
            txtAppId.text = config.appId
            txtAppId.backgroundColor = .white
            txtAppId.font = UIFont.systemFont(ofSize: 14)
            let txtAppIdPadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtAppId.leftView = txtAppIdPadding
            txtAppId.leftViewMode = .always
            line1.addSubview(txtAppId)
            
            // channel info
            let line2 = UIView()
            line2.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line2)
            let lblChannel = UILabel()
            lblChannel.configureLayout { it in
                it.isEnabled = true
                it.width = 120
            }
            lblChannel.font = UIFont.systemFont(ofSize: 14)
            lblChannel.textColor = .white
            lblChannel.text = "Channel Name: "
            line2.addSubview(lblChannel)
            txtChannel = UITextField()
            txtChannel.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtChannel.autocorrectionType = .no
            txtChannel.autocapitalizationType = .none
            txtChannel.text = config.channelId
            txtChannel.backgroundColor = .white
            txtChannel.font = UIFont.systemFont(ofSize: 14)
            let txtChannelPadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtChannel.leftView = txtChannelPadding
            txtChannel.leftViewMode = .always
            line2.addSubview(txtChannel)
            btnSubmit = UIButton()
            btnSubmit.configureLayout { it in
                it.isEnabled = true
                it.height = 30
                it.marginBottom = 40
            }
            btnSubmit.backgroundColor = self.config.isJoined ? .orange : .brown
            btnSubmit.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnSubmit.setTitleColor(.white, for: .normal)
            btnSubmit.setTitle(self.config.isJoined ? "Leave Channel" : "Join Channel", for: .normal)
            btnSubmit.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
            content.addSubview(btnSubmit)
            
            // recvRange info
            let line3 = UIView()
            line3.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line3)
            let lblRecvRange = UILabel()
            lblRecvRange.configureLayout { it in
                it.isEnabled = true
                it.width = 120
            }
            lblRecvRange.text = "Receive Range："
            lblRecvRange.font = UIFont.systemFont(ofSize: 14)
            lblRecvRange.textColor = .white
            line3.addSubview(lblRecvRange)
            txtRange = UITextField()
            txtRange.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtRange.keyboardType = .numberPad
            txtRange.autocorrectionType = .no
            txtRange.autocapitalizationType = .none
            txtRange.text = "\(config.recvRange)"
            txtRange.backgroundColor = .white
            txtRange.font = UIFont.systemFont(ofSize: 14)
            let txtRangePadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtRange.leftView = txtRangePadding
            txtRange.leftViewMode = .always
            line3.addSubview(txtRange)
            
            // audio model && sound effect
            let line4 = UIView()
            line4.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line4)
            let btnAudioModel = UIButton()
            btnAudioModel.configureLayout { it in
                it.isEnabled = true
                it.height = 30
                it.marginRight = 8
                it.flexGrow = 1
            }
            btnAudioModel.backgroundColor = .brown
            btnAudioModel.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btnAudioModel.setTitleColor(.white, for: .normal)
            btnAudioModel.setTitle("Model: \(config.audioModel)", for: .normal)
            btnAudioModel.addTarget(self, action: #selector(onSwitchAudioModel), for: .touchUpInside)
            line4.addSubview(btnAudioModel)
            let btnSoundEffect = UIButton()
            btnSoundEffect.configureLayout { it in
                it.isEnabled = true
                it.height = 30
                it.flexGrow = 1
            }
            btnSoundEffect.backgroundColor = .brown
            btnSoundEffect.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btnSoundEffect.setTitleColor(.white, for: .normal)
            btnSoundEffect.setTitle("3D: \(config.soundEffect)", for: .normal)
            btnSoundEffect.addTarget(self, action: #selector(onSwitchSoundEffect), for: .touchUpInside)
            line4.addSubview(btnSoundEffect)
                        
            // teamId info
            let line6 = UIView()
            line6.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line6)
            let lblTeamId = UILabel()
            lblTeamId.configureLayout { it in
                it.isEnabled = true
                it.width = 120
            }
            lblTeamId.font = UIFont.systemFont(ofSize: 14)
            lblTeamId.textColor = .white
            lblTeamId.text = "Team Id："
            line6.addSubview(lblTeamId)
            txtTeamId = UITextField()
            txtTeamId.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtTeamId.keyboardType = .numberPad
            txtTeamId.autocorrectionType = .no
            txtTeamId.autocapitalizationType = .none
            txtTeamId.text = "\(config.teamId)"
            txtTeamId.backgroundColor = .white
            txtTeamId.font = UIFont.systemFont(ofSize: 14)
            let txtTeamIdPadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtTeamId.leftView = txtTeamIdPadding
            txtTeamId.leftViewMode = .always
            line6.addSubview(txtTeamId)
            
            // playerId info
            let line5 = UIView()
            line5.configureLayout { it in
                it.isEnabled = true
                it.flexDirection = .row
                it.marginBottom = YGValue(lineMarginBottom)
            }
            content.addSubview(line5)
            let lblPlayerId = UILabel()
            lblPlayerId.configureLayout { it in
                it.isEnabled = true
                it.width = 120
            }
            lblPlayerId.font = UIFont.systemFont(ofSize: 14)
            lblPlayerId.textColor = .white
            lblPlayerId.text = "Player Id："
            line5.addSubview(lblPlayerId)
            txtPlayerId = UITextField()
            txtPlayerId.configureLayout { it in
                it.isEnabled = true
                it.height = 25
                it.flexGrow = 1
            }
            txtPlayerId.keyboardType = .numberPad
            txtPlayerId.autocorrectionType = .no
            txtPlayerId.autocapitalizationType = .none
            txtPlayerId.text = config.rtcUserId == nil ? "" : "\(config.rtcUserId!)"
            txtPlayerId.backgroundColor = .white
            txtPlayerId.font = UIFont.systemFont(ofSize: 14)
            let txtPlayerIdPadding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 25))
            txtPlayerId.leftView = txtPlayerIdPadding
            txtPlayerId.leftViewMode = .always
            line5.addSubview(txtPlayerId)
            
            view.yoga.applyLayout(preservingOrigin: false)
            scroll.contentSize = content.yoga.intrinsicSize
        }
    }
    
    @objc func onClose() {
        onTap()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onSubmit() {
        if config.isJoined {
            config.leaveChannel()
            self.btnSubmit.setTitle("Join Channel", for: .normal)
            self.btnSubmit.backgroundColor = .brown
        } else {
            config.joinRoom {[weak self] in
                if let self = self {
                    self.btnSubmit.setTitle("Leave Channel", for: .normal)
                    self.btnSubmit.backgroundColor = .orange
                }
            }
        }
    }
    
    @objc func onSwitchAudioModel(btn: UIButton) {
        let updateFn = {
            [unowned self]
            (type: AgoraGMEAudioMode) in
            self.config.audioModel = type
            btn.setTitle("Model: \(type)", for: .normal)
            btn.yoga.markDirty()
            self.view.yoga.applyLayout(preservingOrigin: false)
        }
        
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        let item1 = UIAlertAction(title: AgoraGMEAudioMode.team.description,
                                  style: config.audioModel == AgoraGMEAudioMode.team ? .destructive : .default) { _ in
            updateFn(.team)
        }
        alert.addAction(item1)
        let item2 = UIAlertAction(title: AgoraGMEAudioMode.world.description,
                                  style: config.audioModel == AgoraGMEAudioMode.world ? .destructive : .default) { _ in
            updateFn(.world)
        }
        alert.addAction(item2)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func onSwitchSoundEffect(btn: UIButton) {
        let updateFn = {
            [unowned self]
            (type: SoundEffect) in
            self.config.soundEffect = type
            btn.setTitle("3D: \(type)", for: .normal)
            btn.yoga.markDirty()
            self.view.yoga.applyLayout(preservingOrigin: false)
        }
        
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        let item1 = UIAlertAction(title: SoundEffect.disable.description,
                                  style: config.soundEffect == SoundEffect.disable ? .destructive : .default) { _ in
            updateFn(.disable)
        }
        alert.addAction(item1)
        let item2 = UIAlertAction(title: SoundEffect.enable.description,
                                  style: config.soundEffect == SoundEffect.enable ? .destructive : .default) { _ in
            updateFn(.enable)
        }
        alert.addAction(item2)
        let item3 = UIAlertAction(title: SoundEffect.applyToTeam.description,
                                  style: config.soundEffect == SoundEffect.applyToTeam ? .destructive : .default) { _ in
            updateFn(.applyToTeam)
        }
        alert.addAction(item3)
        present(alert, animated: true, completion: nil)
    }
}
