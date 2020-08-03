//
//  ConfigModel.swift
//  pubGDemo
//
//  Created by FH on 2020/7/13.
//  Copyright © 2020 Fuhan. All rights reserved.
//

import Foundation

// radius = pixels * 10
public let Sound3DRadius: UInt = 10
public let RecvRangeRadius: UInt = 100

extension AgoraGMEConnectionState : CustomStringConvertible {
    public var description: String {
        switch self {
        case .connecting:
            return ".Connecting"
        case .disconnected:
            return ".Disconnected"
        default:
            return ".Connected"
        }
    }
}

extension AgoraGMEConnectionChangedReason : CustomStringConvertible {
    public var description: String {
        switch self {
        case .aborted:
            return ".Aborted"
        case .connecting:
            return ".Connecting"
        case .createRoomFail:
            return ".CreateRoomFail"
        case .rtmDisconnect:
            return ".RtmDisconnect"
        default:
            return ".Default"
        }
    }
}

extension AgoraGMEAudioMode : CustomStringConvertible, Codable {
    public var description: String {
        switch self {
        case .team:
            return "Only Team"
        default:
            return "All World"
        }
    }
}

public enum SoundEffect : Int, CustomStringConvertible, Codable {
    case disable
    case enable
    case applyToTeam
    
    public var description: String {
        switch self {
        case .disable:
            return "Close"
        case .enable:
            return "Open"
        default:
            return "Include Team"
        }
    }
}

@propertyWrapper
class PropInfo<T: Codable> : Codable {
    private var listeners: [(T) -> ()] = []
    var wrappedValue: T {
        willSet {
            for fn in listeners {
                fn(newValue)
            }
        }
    }
    
    var projectValue: Self {
        return self
    }
    
    private enum CodingKeys: String, CodingKey {
        case wrappedValue
    }
        
    init(wrappedValue value: T) {
        self.wrappedValue = value
    }
    
    func thunk(_ fn: @escaping (T) -> ()) {
        listeners.append(fn)
    }
}

@objc
public class ConfigModel : NSObject, Codable {
    var moveSpeed: Float = 0.6
    @PropInfo
    var recvRange: UInt = RecvRangeRadius
    @PropInfo
    var audioModel: AgoraGMEAudioMode = .world
    @PropInfo
    var soundEffect: SoundEffect = .enable
    var appId: String = "01234567890123456789012345678901"
    var channelId: String = "pubG"
    var teamId: Int = 123
    var rtcToken: String?
    var rtcUserId: UInt?
    var rtmToken: String?
    var isJoined: Bool = false
    var userId: UInt = 0
    var agoraKit: AgoraRtcEngineKit!
    var agoraGmeKit: AgoraGmeKit!
    var updateRecvRangeFn: ((UInt) -> ())!
    var updateAudioModeFn: ((AgoraGMEAudioMode) -> ())!
    var updateSpatializerFn: ((SoundEffect) -> ())!
    var enterRoomSuccFn: (() -> ())?
    
    private enum CodingKeys: String, CodingKey {
        case moveSpeed, recvRange, audioModel, soundEffect, appId, channelId, teamId, rtcToken, rtcUserId, rtmToken
    }
    
    override init() {
        super.init()
        
        let path = NSHomeDirectory() + "/Library/Cache"
        let url = URL(fileURLWithPath: path, isDirectory: true)
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDir) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func updateRecvRange(_ range: UInt) {
        self.agoraGmeKit.updateAudioRecvRange(range)
    }
    
    private func updateAudioMode(_ type: AgoraGMEAudioMode) {
        self.agoraGmeKit.setRangeAudioMode(type)
    }
    
    private func updateSpatializer(_ type: SoundEffect) {
        if type == .disable {
            self.agoraGmeKit.enableSpatializer(false, applyToTeam: false)
        } else {
            let applyToTeam = type == .applyToTeam
            self.agoraGmeKit.enableSpatializer(true, applyToTeam: applyToTeam)
        }
    }
    
    func dataBinding() {
        _recvRange.thunk {[unowned self] in
            if self.isJoined {
                self.updateRecvRange($0)
            }
            self.updateRecvRangeFn($0)
        }
        
        _audioModel.thunk {[unowned self] in
            if self.isJoined {
                self.updateAudioMode($0)
            }
            self.updateAudioModeFn($0)
        }
        
        _soundEffect.thunk {[unowned self] in
            if self.isJoined {
                self.updateSpatializer($0)
            }
            self.updateSpatializerFn($0)
        }
    }
    
    func updatePosition(position: [NSNumber], forward: [NSNumber], right: [NSNumber], up: [NSNumber]) {
        if (self.isJoined) {
            self.agoraGmeKit.updateSelfPosition(position, axisForward: forward, axisRight: right, axisUp: up);
        }
    }
    
    func joinRoom(_ joinSuccFn: @escaping () -> ()) {
        enterRoomSuccFn = nil
        leaveChannel()
        
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
            agoraKit.setClientRole(.broadcaster)
            agoraKit.setChannelProfile(.game)
            agoraKit.enableAudio()
            
            agoraGmeKit = AgoraGmeKit.sharedGMEngine(withAppId: appId, rtcEngine: agoraKit, delegate: self)
            agoraGmeKit.setRangeAudioTeamId(self.teamId)
            updateAudioMode(self.audioModel)
            agoraGmeKit.enableMainQueueDispatch(false)
        }

        enterRoomSuccFn = joinSuccFn
        agoraKit.joinChannel(byToken: rtcToken, channelId: channelId, info: nil, uid: rtcUserId ?? userId) {
            [unowned self]
            (channel, uId, elapsed) in
            self.userId = uId
            info("join rtc \(channel) succ, and userId: \(uId)、elapsed: \(elapsed)")
            let result = self.agoraGmeKit.enterRoom(byToken: self.rtmToken,
                                                    roomName: channel,
                                                    userId: uId)
            if (result != 0) {
                alert("init room error: \(result)")
            }
        }
    }
    
    func leaveChannel() {
        if agoraKit != nil {
            if self.isJoined {
                agoraKit.leaveChannel {[weak self] _ in
                    if let self = self {
                        self.isJoined = false
                        self.agoraGmeKit.exitRoom()
                        self.agoraKit = nil
                        self.agoraGmeKit = nil
                    }
                }
            } else {
                agoraKit = nil
                agoraGmeKit = nil
            }
        }
    }
    
    func saveToLocal() {
        let data = try! JSONEncoder().encode(self)
        try! data.write(to: Self.localPath())
    }
    
    static func loadFromLocal(_ updateRecvRangeFn: @escaping (UInt) -> (),
                              _ updateAudioModeFn: @escaping (AgoraGMEAudioMode) -> (),
                              _ updateSpatializerFn: @escaping (SoundEffect) -> ()) -> ConfigModel {
        var result: ConfigModel! = nil
        if let data = try? Data(contentsOf: Self.localPath()),
            let config = try? JSONDecoder().decode(ConfigModel.self, from: data) {
            result = config
        } else {
            result = ConfigModel()
        }
        
        result.updateRecvRangeFn = updateRecvRangeFn
        result.updateAudioModeFn = updateAudioModeFn
        result.updateSpatializerFn = updateSpatializerFn
        result.dataBinding()
        return result
    }
    
    static func localPath() -> URL {
        let path = NSHomeDirectory() + "/Library/Cache"
        var url = URL(fileURLWithPath: path, isDirectory: true)
        url.appendPathComponent("config.data")
        return url
    }
}

func warning(_ content: String) {
    print(">>> warning: \(content)")
}

func info(_ content: String) {
    print(">>> info: \(content)")
}

func alert(_ content: String) {
    print(">>> alert: \(content)")
}

extension ConfigModel : AgoraRtcEngineDelegate, AgoraGMEngineDelegate {
    
    // REMARK: gm engine delegate
    
    public func gmEngine(_ engine: AgoraGmeKit, didOccurError errorCode: AgoraErrorCode) {
        alert("gmEngine occur error: \(errorCode)")
    }
    
    public func gmEngineDidRequestToken(_ engine: AgoraGmeKit) {
        info("gmEngine did request token")
    }
    
    public func gmEngineDidEnterRoom(_ engine: AgoraGmeKit) {
        info("gmEngine did enter room succ.")
        
        DispatchQueue.main.sync {
            self.isJoined = true
            self.updateRecvRange(self.recvRange)
            self.updateSpatializer(self.soundEffect)
            self.enterRoomSuccFn?()
        }
    }
    
    public func gmEngineDidFailed(toEnterRoom engine: AgoraGmeKit) {
        alert("gmEngine did enter room failed.")
    }
    
    public func gmEngine(_ engine: AgoraGmeKit, didLostSynchronizationWithTimeInterval lostSynchronizationTimeInterval: TimeInterval) {
        info("gmEngine lost sync interval: \(lostSynchronizationTimeInterval)")
    }
    
    public func gmEngine(_ engine: AgoraGmeKit, didGetSynchronizedWithTimeInterval lostSynchronizationTimeInterval: TimeInterval) {
        info("gmEngine get sync interval: \(lostSynchronizationTimeInterval)")
    }
    
    public func gmEngine(_ engine: AgoraGmeKit, teamMatesDidChangedWithUsers users: [NSNumber]) {
        info("gmEngine did teamMates changed users: \(users)")
    }
    
    public func gmEngine(_ engine: AgoraGmeKit, connectionDidChangedTo state: AgoraGMEConnectionState, with reason: AgoraGMEConnectionChangedReason) {
        info("gmEngine did connect changed state: \(state) with reason: \(reason)")
    }
    
    // REMARK: rtc engine delegate
    
    public func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        alert("Connection Interrupted")
    }
    
    public func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        alert("Connection Lost")
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        warning("\(warningCode)")
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        alert("rtc \(errorCode)")
    }
    
    public func rtcEngineMediaEngineDidStartCall(_ engine: AgoraRtcEngineKit) {
        info("Media engine did start call")
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        info("Did join channel")
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        info("Did rejoin channel")
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        info("Did Joined Of Uid: \(uid)")
    }
    
    public func rtcEngineMediaEngineDidAudioMixingFinish(_ engine: AgoraRtcEngineKit) {
        info("Media engine did Audio Mining finish")
    }
}
