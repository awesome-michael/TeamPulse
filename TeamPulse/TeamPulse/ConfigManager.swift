//
//  ConfigManager.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

class ConfigManager {
    
    class func userName() -> String? {
        return UserDefaults.standard.string(forKey: "userName")
    }
    
    class func setUserName(userName: String?) {
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.synchronize()
    }
    
    class func userId() -> String? {
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    class func setUserId(userId: String?) {
        UserDefaults.standard.setValue(userId, forKey: "userId")
        UserDefaults.standard.synchronize()
    }
    
    class func password() -> String? {
        return UserDefaults.standard.string(forKey: "password")
    }
    
    class func setPassword(password: String?) {
        UserDefaults.standard.setValue(password, forKey: "password")
        UserDefaults.standard.synchronize()
    }
    
    class func certificateFileName() -> String? {
        return UserDefaults.standard.string(forKey: "certificateFileName")
    }
    
    class func setCertificateFileName(fileName: String?) {
        UserDefaults.standard.setValue(fileName, forKey: "certificateFileName")
        UserDefaults.standard.synchronize()
    }
    
    class func certificatePassword() -> String? {
        return UserDefaults.standard.string(forKey: "certificatePassword")
    }
    
    class func setCertificatePassword(password: String?) {
        UserDefaults.standard.setValue(password, forKey: "certificatePassword")
        UserDefaults.standard.synchronize()
    }
    
    class func loadedCertificateId() -> String? {
        return UserDefaults.standard.string(forKey: "certificateId")
    }
    
    class func setLoadedCertificateId(certificateId: String?) {
        UserDefaults.standard.setValue(certificateId, forKey: "certificateId")
        UserDefaults.standard.synchronize()
    }
    
    class func iotEndpointHostname() -> String {
        return UserDefaults.standard.string(forKey: "iotEndpointHostname") ?? ""
    }
    
    class func setIoTEndpointHostname(hostname: String) {
        UserDefaults.standard.setValue(hostname, forKey: "iotEndpointHostname")
        UserDefaults.standard.synchronize()
    }
    
    class func iotEndpointPort() -> UInt16 {
        return UInt16(UserDefaults.standard.integer(forKey: "iotEndpointPort") )
    }
    
    class func setIoTEndpointPort(port: UInt16) {
        UserDefaults.standard.setValue(port, forKey: "iotEndpointPort")
        UserDefaults.standard.synchronize()
    }
    
    class func deviceId() -> String {
        return UserDefaults.standard.string(forKey: "deviceId") ?? ""
    }
    
    class func setDeviceId(deviceId: String) {
        UserDefaults.standard.setValue(deviceId, forKey: "deviceId")
        UserDefaults.standard.synchronize()
    }
}
