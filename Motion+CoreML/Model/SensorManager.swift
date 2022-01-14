//
//  SensorManager.swift
//  Motion+CoreML
//
//  Created by MacBook Pro on 2022/01/14.
//

import CoreMotion
import Combine
import CoreML


class SensorManager: NSObject, ObservableObject {
    /// - Tag: CMMotionManager
    var motionManager: CMMotionManager?
    
    /// - Tag: published acceleration data
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    
    /// - Tag: acceleration data to classifiy
    private var accelerometerData = [Double]()

    private var cancellable: AnyCancellable?
    
    /// - Tag: activity classifier
//    lazy var classifier: VGG16 {
//        let config = 
//    }
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
    }
    
    private func update() {
        // collect acceleration data
        if let data = motionManager?.accelerometerData {
            x = data.acceleration.x
            y = data.acceleration.y
            z = data.acceleration.z
            
            accelerometerData.append(x)
            accelerometerData.append(y)
            accelerometerData.append(z)
        }
        else {
            x = Double.nan
            y = Double.nan
            z = Double.nan
        }
        
        // predict activity from acceleration data
        if accelerometerData.count == 256 * 3 {
            
        }
    }
    
    func start(frequency: Double = 100.0) {
        if let motionManager = motionManager, motionManager.isAccelerometerActive {
            motionManager.startAccelerometerUpdates()
        }
        
        cancellable = Timer.publish(every: 1.0 / frequency, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.update()
            })
    }
    
    func cancel() {
        
    }
}
