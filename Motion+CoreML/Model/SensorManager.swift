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
    lazy var classifier: PyramidNet18 = {
        do {
            let config = MLModelConfiguration()
            return try PyramidNet18(configuration: config)
        } catch {
            fatalError("Failed to load a model: \(error)")
        }
    }()
    
    /// - Tag: classification results
    @Published var classLabel: String = "?"
    @Published var confidence: Double = 0.0
    
    
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
            do {
                let multiArray = try MLMultiArray.fromDouble(accelerometerData)
                let output = try classifier.prediction(input: multiArray)
                classLabel = output.classLabel
                confidence = output.Identity[output.classLabel] ?? -1.0
            } catch {
                fatalError("Failed to predict: \(error)")
            }
            
            print("🏃🏼 \(classLabel) \(confidence)")
            
            // remove all to new prediction
            accelerometerData.removeAll()
        }
    }
    
    func start(frequency: Double = 100.0) {
        if let motionManager = motionManager, motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
        }
        
        cancellable = Timer.publish(every: 1.0 / frequency, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.update()
            })
    }
    
    func cancel() {
        if let motionManager = motionManager, motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
        
        cancellable?.cancel()
    }
}
