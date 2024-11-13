//
//  ATCustomEffect.swift
//  AnimateTextExample
//
//  Created by petrovichev maxim on 13.11.2024.
//

// MARK: - Custom Effect

import Foundation
import SwiftUI

public struct ATCustomEffect: ATTextAnimateEffect {
    public var data: ATElementData
    public var userInfo: Any?
    
    @State private var phase: AnimationPhase = .appearing
    @State private var isVisible: Bool = false
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    private var color: Color = .black

    // Animation phases
    private enum AnimationPhase {
        case appearing
        case main
        case disappearing
    }

    // Settings
    private var effectSettings: EffectSettings?

    public init(_ data: ATElementData, _ userInfo: Any?) {
        self.data = data
        self.userInfo = userInfo

        if let settings = userInfo as? EffectSettings {
            self.effectSettings = settings
            // Color is assigned in AnimateText and passed via data.color
            self.color = data.color
        } else {
            self.color = .black
        }
    }

    public func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .opacity(isVisible ? 1 : 0)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                startAnimationSequence()
            }
    }

    private func startAnimationSequence() {
        if shouldAnimate(in: .appearing) {
            applyAppearanceAnimation()
        } else {
            isVisible = true
            phase = .main
        }

        // Main Animation starts immediately after appearance
        let mainAnimationDelay = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + mainAnimationDelay) {
            if shouldAnimate(in: .main) {
                applyMainAnimation()
            }
        }

        // Disappearance Phase
        let disappearanceStartDelay = (effectSettings?.delayBeforeDisappearance ?? 0)
        if shouldAnimate(in: .disappearing) {
            DispatchQueue.main.asyncAfter(deadline: .now() + disappearanceStartDelay) {
                applyDisappearanceAnimation()
            }
        } else {
            // Disappear immediately after delay without animation
            DispatchQueue.main.asyncAfter(deadline: .now() + disappearanceStartDelay) {
                isVisible = false
                phase = .disappearing
            }
        }
    }

    private func applyAppearanceAnimation() {
        guard let settings = effectSettings else { return }
        let type = settings.appearanceSettings.type
        let animation = settings.appearanceSettings.animation
        var delay: Double = 0.0
        let unitIndex = getUnitIndex(unitType: settings.appearanceSettings.unit)

        switch type {
        case "allAtOnce":
            delay = 0.0
        case "sequentially":
            let interval = settings.appearanceSettings.delayBetweenElements ?? 0
            delay = interval * Double(unitIndex)
        case "random":
            let totalTime = settings.appearanceSettings.totalDuration ?? 1.0
            let elementTime = settings.appearanceSettings.elementTime ?? 0.1
            let maxDelay = totalTime - elementTime
            delay = Double.random(in: 0...maxDelay)
        default:
            delay = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(animation) {
                isVisible = true
                phase = .main
            }
        }
    }

    private func applyMainAnimation() {
        guard let settings = effectSettings else { return }
        let mainType = settings.mainAnimationSettings.type
        let unitIndex = getUnitIndex(unitType: settings.mainAnimationSettings.unit)
        
        switch mainType {
        case "cyclicMovement":
            let intensity = settings.mainAnimationSettings.deviationIntensity ?? 10
            let duration = settings.mainAnimationSettings.cycleDuration ?? 1.0
            let phaseShift = Double(unitIndex) * 0.5
            withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                offset = .zero
            }
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                let time = Date().timeIntervalSinceReferenceDate
                let xOffset = CGFloat(intensity * sin(2 * .pi * time / duration + phaseShift))
                let yOffset = CGFloat(intensity * cos(2 * .pi * time / duration + phaseShift))
                offset = CGSize(width: xOffset, height: yOffset)
            }
        case "jumping":
            let intensity = settings.mainAnimationSettings.jumpIntensity ?? 10
            let stepDuration = settings.mainAnimationSettings.changeStepDuration ?? 0.2
            let rotationDegree = settings.mainAnimationSettings.rotationDegree ?? 15.0
            withAnimation(Animation.linear(duration: stepDuration).repeatForever(autoreverses: true)) {
                offset = .zero
                rotation = 0
            }
            Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { _ in
                let randomOffset = CGFloat.random(in: -intensity...intensity)
                let randomRotation = Double.random(in: -rotationDegree...rotationDegree)
                offset = CGSize(width: randomOffset, height: randomOffset)
                rotation = randomRotation
            }
        case "wave":
            let intensity = settings.mainAnimationSettings.verticalJumpIntensity ?? 10
            let cycleDuration = settings.mainAnimationSettings.waveCycleDuration ?? 2.0
            let waveLength = settings.mainAnimationSettings.waveLength ?? 5
            let phase = Double(unitIndex % waveLength) / Double(waveLength) * 2 * .pi
            withAnimation(Animation.linear(duration: cycleDuration).repeatForever(autoreverses: false)) {
                offset = .zero
            }
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                let time = Date().timeIntervalSinceReferenceDate
                let yOffset = CGFloat(intensity * sin(2 * .pi * time / cycleDuration + phase))
                offset = CGSize(width: 0, height: yOffset)
            }
        default:
            break
        }
    }

    private func applyDisappearanceAnimation() {
        guard let settings = effectSettings else { return }
        let type = settings.disappearanceSettings.type
        let animation = settings.disappearanceSettings.animation
        var delay: Double = 0.0
        let unitIndex = getUnitIndex(unitType: settings.disappearanceSettings.unit)

        switch type {
        case "allAtOnce":
            delay = 0.0
        case "sequentially":
            let interval = settings.disappearanceSettings.delayBetweenElements ?? 0
            delay = interval * Double(unitIndex)
        case "random":
            let totalTime = settings.disappearanceSettings.totalDuration ?? 1.0
            let elementTime = settings.disappearanceSettings.elementTime ?? 0.1
            let maxDelay = totalTime - elementTime
            delay = Double.random(in: 0...maxDelay)
        default:
            delay = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(animation) {
                isVisible = false
                phase = .disappearing
            }
        }
    }

    private func shouldAnimate(in phase: AnimationPhase) -> Bool {
        guard let settings = effectSettings else {
            return true
        }
        var ranges: [Range<Int>]?
        var unitType: UnitType
        switch phase {
        case .appearing:
            ranges = settings.appearanceSettings.ranges
            unitType = settings.appearanceSettings.unit
        case .main:
            ranges = settings.mainAnimationSettings.ranges
            unitType = settings.mainAnimationSettings.unit
        case .disappearing:
            ranges = settings.disappearanceSettings.ranges
            unitType = settings.disappearanceSettings.unit
        }
        let unitIndex = getUnitIndex(unitType: unitType)
        if let ranges = ranges {
            return ranges.contains { $0.contains(unitIndex) }
        }
        return true
    }

    private func getUnitIndex(unitType: UnitType) -> Int {
        switch unitType {
        case .letters:
            return data.index
        case .words:
            return data.wordIndex
        }
    }
}


