//
//  WalkthroughStepView.swift
//  SSC
//
//  Created by Zerui Wang on 16/4/23.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct WalkthroughStepView: View {
    @EnvironmentObject var provider: WalkthroughProvider
    var step: WalkthroughStep
    @Binding var simulationSpeed: Float
    var body: some View {
        VStack {
            Text(step.description).font(.body)
            Spacer()
            if provider.currentStep >= 4 {
                Slider(value: $simulationSpeed, in: 1...10, step: 1, minimumValueLabel: Image(systemName: "tortoise"), maximumValueLabel: Image(systemName: "hare"), label: {})
                Text("Current simulation speed: \(Int(simulationSpeed))s")
            }
            Button {
                provider.nextStep()
            } label: {
                Text((provider.currentStep == provider.steps.count - 1) ? "Restart":"Next").frame(maxWidth: .infinity)
            }
            .disabled(provider.nextButtonDisabled)
            .buttonStyle(.bordered)
            if (provider.currentStep == 4 || provider.currentStep == 5) {
                Text("You may use this template!")
                Image("node_image")
            }
        }.navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.large)
        .lineLimit(nil)
    }
}
