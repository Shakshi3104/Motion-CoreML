//
//  MNCoreML.swift
//  Motion+CoreML
//
//  Created by MacBook Pro on 2022/01/15.
//

import CoreML

// MARK: - MNCoreMLModel
public class MNCoreMLModel: NSObject {
    private var model: MNCoreMLModelConvertible
    
    public init(for model: MNCoreMLModelConvertible) {
        self.model = model
    }
    
    public func prediction(from input: [Double]) throws -> MNCoreMLOutputConvertible {
        let multiArray = try MLMultiArray.fromDouble(input)
        let output = try model.prediction(input: multiArray)
        return output
    }
}

// MARK: - MNRequest
public protocol MNRequest {
    var model: MNCoreMLModel { get }
    var results: MNCoreMLOutputConvertible? { get set }
    
    func prediction(from input: [Double]) throws
}

// MARK: - MNRequestCompletionHandler
public typealias MNRequestCompletionHandler = (MNRequest, Error?) -> Void


// MARK: - MNCoreMLRequest
public class MNCoreMLRequest: MNRequest {
    
    public var results: MNCoreMLOutputConvertible?
    public var model: MNCoreMLModel
    
    public init(model: MNCoreMLModel, completionHandler: MNRequestCompletionHandler? = nil) {
        self.model = model
        
        completionHandler?(self, nil)
    }
    
    public func prediction(from input: [Double]) throws {
        results = try model.prediction(from: input)
    }
}

// MARK: - MNSensorDataRequestHandler
public class MNSensorDataRequestHandler: NSObject {
    private var sensorData: [Double]
    
    public init(array: [Double]) {
        self.sensorData = array
    }
    
    public func perform(_ requests: [MNRequest]) throws {
        try requests.forEach { request in
            try request.prediction(from: sensorData)
        }
    }
}
