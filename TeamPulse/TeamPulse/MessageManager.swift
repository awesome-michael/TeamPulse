//
//  MQTTManager.swift
//  TeamPulse prev. HomeSensor
//
//  Created by Michael Teeuw on 08/01/16.
//  Copyright © 2016 Michael Teeuw. All rights reserved.
//

import Foundation
import CocoaMQTT

class MessageManager: NSObject, CocoaMQTTDelegate {
    
    static let sharedInstance = MessageManager()
    
    var heartRatesDict = [String : HeartRateModel]()

    var delegate:MessageManagerDelegate?

    let mqtt = CocoaMQTT(clientID: "HeartSensor-" + String(ProcessInfo().processIdentifier), host: ConfigManager.iotEndpointHostname(), port: ConfigManager.iotEndpointPort())
    var connected = false {
        didSet {
            delegate?.messageManagerConnectionChanged(messageManager: self)
        }
    }
    
    override init() {
        super.init()
        print("Init MQTT manager")
        ConfigManager.setCertificateFileName(fileName: "pulse")
        ConfigManager.setCertificatePassword(password: "rQRf9awTiVeA")
        ConfigManager.setDeviceId(deviceId: "0x15f91")
        
        mqtt.username = ConfigManager.userName()
        mqtt.password = ConfigManager.password()
        mqtt.keepAlive = 60
        mqtt.delegate = self
        //mqtt.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt.enableSSL = true
        mqtt.allowUntrustCACertificate = true
        
        let clientCertArray = getClientCertFromP12File(certName: ConfigManager.certificateFileName()!, certPassword: ConfigManager.certificatePassword()!)
        
        var sslSettings: [String: NSObject] = [:]
        sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
        
        mqtt.sslSettings = sslSettings

        connect()
    }
    
    func connect() {
        if mqtt.connState != .connected && mqtt.connState != .connecting {
            mqtt.connect();
        }
    }
    
    func isConnected() -> Bool {
        return mqtt.connState == .connected || mqtt.connState == .connecting
    }
    
    func publishHeartRate(heartRate: Double, userName: String, userId: String) {
        let heartRateString = String(format: "%.0f", heartRate)
        let json = """
        {
        "heartRate": \(heartRateString),
        "userName": "\(userName)",
        "userId": "\(userId)"
        }
        """
        publishToTopic(topic: "devices/\(ConfigManager.deviceId())/state/reported/delta", payload: json)
    }
    
    func subscribeToHeartRates() {
        subscribeToTopic(topic: "heartrate")
    }
    
    func getClientCertFromP12File(certName: String, certPassword: String) -> CFArray? {
        // get p12 file path
        let resourcePath = Bundle.main.path(forResource: certName, ofType: "p12")
        
        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file: \(certName).p12")
            return nil
        }
        
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                print("Failed to open the certificate file: \(certName).p12")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        
        return certArray
    }

}

// MARK: CocoaMQTTDelegate Methods
extension MessageManager {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        for topic in topics{
            print("Subscribed to topic: ", topic)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {}
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("Ping!")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("Pong!")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("Disconnected from MQTT!",err!)
        connected = false
        connect()
    }

    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connected to MQTT server.")
        connected = true
        // subscribe to heartrates
        subscribeToHeartRates()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let string = message.string {
            
            print(message.topic, string)
            
//            for device in sensorManager.devices {
//
//                let deviceConnectedTopic = sensorManager.topicForDeviceConnection(device)
//                if deviceConnectedTopic == message.topic {
//                    device.receivedNewConnectionValue(string)
//                } else if "\(deviceConnectedTopic)/timestamp" == message.topic {
//                    device.receivedNewConnectionTimestamp(string)
//                }
//
//                for sensor in device.sensors {
//                    let sensorTopic = sensorManager.topicForSensor(sensor, onDevice: device)
//                    if sensorTopic == message.topic {
//                        sensor.receivedNewValue(string)
//                    } else if "\(sensorTopic)/timestamp" == message.topic {
//                        sensor.receivedNewTimestamp(string)
//                    }
//
//                    if let notificationTopic = sensorManager.topicForNotificationSubscriptionForSensorOnDevice(sensor, onDevice: device) {
//                        if notificationTopic == message.topic {
//                            if let notificationType = NotificationType(rawValue: string) {
//                                sensor.publishNotificationSubscriptionChange = false
//                                sensor.notificationSubscription = notificationType
//                            }
//                        }
//                    }
//                }
//            }
        }
        
        //Parse the message looking for JSON format data
        do {
            let heartRateModel = try JSONDecoder().decode(HeartRateModel.self, from: (message.string?.data(using: .utf8)!)!)
            self.heartRatesDict[heartRateModel.userId] = heartRateModel
            NotificationCenter.default.post(name: .newHeartRateMQTT, object: heartRateModel)
        } catch {
            print("Error decoding message.")
        }
    }
    
    // optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
        /// Validate the server certificate
        ///
        /// some custom validation
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        ///
        
        completionHandler(true)
    }
 
    
    func subscribeToTopic(topic:String) {
        if mqtt.connState == .connected {
            print("Subscribe to: ", topic)
            mqtt.subscribe(topic, qos: CocoaMQTTQOS.qos1)
        } else {
            print("Can't subscribe to \(topic). Not connected.")
        }
        
    }
    
    func publishToTopic(topic:String, payload:String) {
        if mqtt.connState == .connected {
            print("Publish: ", topic, ": ", payload)
            mqtt.publish(topic, withString: payload, qos: CocoaMQTTQOS.qos1, retained: true, dup: true)
        } else {
            print("Can't publish to \(topic). Not connected.")
        }
    }
}

protocol MessageManagerDelegate {
    func messageManagerConnectionChanged(messageManager:MessageManager)
}
