//
//  ActivityClassificationView.swift
//  Motion+CoreML
//
//  Created by MacBook Pro on 2022/01/14.
//

import SwiftUI

struct ActivityClassificationView: View {
    @ObservedObject var sensorManager = SensorManager()
    @State private var isLogging = false
    
    var body: some View {
        NavigationView {
            List {
                // class label
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text(sensorManager.classLabel)
                                .font(.system(.title, design: .rounded))
                                .padding(5)
                            Text("Confidence: \(String(format: "%.2f", sensorManager.confidence * 100)) %")
                                .font(.system(.body, design: .rounded).monospacedDigit())
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                Section {
                    SensorData(axis: "x", value: sensorManager.x)
                    SensorData(axis: "y", value: sensorManager.y)
                    SensorData(axis: "z", value: sensorManager.z)
                } header: {
                    Text("Accelerometer")
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isLogging.toggle()
                        
                        if isLogging {
                            sensorManager.start()
                        } else {
                            sensorManager.cancel()
                        }
                    } label: {
                        if isLogging {
                            Image(systemName: "stop.fill")
                        } else {
                            Image(systemName: "arrowtriangle.right.fill")
                        }
                    }

                }
            }
        }
    }
}

struct SensorData: View {
    var axis: String
    var value: Double
    var body: some View {
        HStack {
            Text(axis)
                .font(.system(.body, design: .rounded))
                .padding(.horizontal, 15)
            Spacer()
            Text(String(format: "%.3f", value))
                .font(.system(.body, design: .rounded).monospacedDigit())
                .foregroundColor(.secondary)
        }
    }
}

struct ActivityClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityClassificationView()
    }
}
