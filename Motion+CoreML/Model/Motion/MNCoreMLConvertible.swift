//
//  MNCoreMLConvertible.swift
//  Motion+CoreML
//
//  Created by MacBook Pro on 2022/01/15.
//

import CoreML

public protocol MNCoreMLModelConvertible {
    func prediction(input: MLMultiArray) throws -> MNCoreMLOutputConvertible
    func predictions(inputs: [MLMultiArray]) throws -> [MNCoreMLOutputConvertible]
}

public protocol MNCoreMLOutputConvertible {
    var Identity: [String: Double] { get }
    var classLabel: String { get }
}
