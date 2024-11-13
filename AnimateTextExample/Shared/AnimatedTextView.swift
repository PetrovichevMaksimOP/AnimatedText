//
//  AnimatedTextView.swift
//  AnimateTextExample
//
//  Created by petrovichev maxim on 13.11.2024.
//

import SwiftUI

struct AnimatedTextView: View {
    var configuration: TextAnimationConfiguration
    
    @State private var text: String = ""
    
    var body: some View {
        let settings = createEffectSettings()
        let fontSize = CGFloat(configuration.properties.font.size)
        
        AnimateText<ATCustomEffect>(
            $text,
            fontSize: fontSize,
            textAlignment: getTextAlignment(),
            userInfo: settings
        )
        .font(getFont())
        .foregroundColor(.clear) // Colors are handled by the effect
        .multilineTextAlignment(getTextAlignment())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            text = configuration.text
        }
    }
    
    func getFont() -> Font {
        var font: Font = .system(size: CGFloat(configuration.properties.font.size))
        if configuration.properties.font.name != "System" {
            font = Font.custom(configuration.properties.font.name, size: CGFloat(configuration.properties.font.size))
        }
        
        switch configuration.properties.font.style {
        case "regular":
            break
        case "bold":
            font = font.weight(.bold)
        case "italic":
            font = font.italic()
        default:
            break
        }
        return font
    }
    
    func getTextAlignment() -> TextAlignment {
        switch configuration.properties.alignment.horizontal {
        case "left":
            return .leading
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }
    
    func createEffectSettings() -> EffectSettings {
        // Parse ranges
        let appearanceRanges = parseRanges(from: configuration.animations.appearance.range)
        let mainRanges = parseRanges(from: configuration.animations.main.range)
        let disappearanceRanges = parseRanges(from: configuration.animations.disappearance.range)
        
        // Create animations
        let appearanceAnimation = Animation.easeIn(duration: (configuration.animations.appearance.interval ?? 300) / 1000)
        let disappearanceAnimation = Animation.easeOut(duration: (configuration.animations.disappearance.interval ?? 300) / 1000)
        
        // Colors
        var colors: [Color] = []
        var colorPatternType: ColorPatternType = .singleColor
        
        if configuration.properties.color.type == "singleColor", let defaultColor = configuration.properties.color.defaultColor {
            if let color = Color(hex: defaultColor) {
                colors = [color]
            }
        } else if configuration.properties.color.type == "patternColor", let colorStrings = configuration.properties.color.colors {
            colors = colorStrings.compactMap { Color(hex: $0) }
            colorPatternType = .sequentialPattern // or .randomPattern based on user selection
        }
        
        // Delay before disappearance
        let delayBeforeDisappearance = (configuration.animations.disappearance.totalTime ?? 2000) / 1000
        
        // Create settings
        return EffectSettings(
            appearanceSettings: AppearanceSettings(
                type: configuration.animations.appearance.type,
                animation: appearanceAnimation,
                delayBetweenElements: (configuration.animations.appearance.interval ?? 100) / 1000,
                totalDuration: (configuration.animations.appearance.totalTime ?? 1000) / 1000,
                elementTime: (configuration.animations.appearance.elementTime ?? 100) / 1000,
                unit: UnitType(rawValue: configuration.animations.appearance.unit ?? "letters") ?? .letters,
                ranges: appearanceRanges
            ),
            mainAnimationSettings: MainAnimationSettings(
                type: configuration.animations.main.type,
                unit: UnitType(rawValue: configuration.animations.main.unit ?? "letters") ?? .letters,
                ranges: mainRanges,
                deviationIntensity: configuration.animations.main.deviationIntensity,
                cycleDuration: configuration.animations.main.cycleDuration,
                jumpIntensity: configuration.animations.main.jumpIntensity,
                changeStepDuration: configuration.animations.main.changeStepDuration,
                rotationDegree: configuration.animations.main.rotationDegree,
                verticalJumpIntensity: configuration.animations.main.verticalJumpIntensity,
                waveCycleDuration: configuration.animations.main.waveCycleDuration,
                waveLength: configuration.animations.main.waveLength
            ),
            disappearanceSettings: DisappearanceSettings(
                type: configuration.animations.disappearance.type,
                animation: disappearanceAnimation,
                delayBetweenElements: (configuration.animations.disappearance.interval ?? 100) / 1000,
                totalDuration: (configuration.animations.disappearance.totalTime ?? 1000) / 1000,
                elementTime: (configuration.animations.disappearance.elementTime ?? 100) / 1000,
                unit: UnitType(rawValue: configuration.animations.disappearance.unit ?? "letters") ?? .letters,
                ranges: disappearanceRanges
            ),
            delayBeforeDisappearance: delayBeforeDisappearance,
            colors: colors,
            colorPatternType: colorPatternType
        )
    }
    
    func parseRanges(from rangeString: String?) -> [Range<Int>]? {
        guard let rangeString = rangeString, !rangeString.isEmpty else {
            return nil
        }
        let components = rangeString.split(separator: ",")
        var ranges: [Range<Int>] = []
        
        for component in components {
            let bounds = component.split(separator: "-").compactMap { Int($0) }
            if bounds.count == 2, let lower = bounds.first, let upper = bounds.last {
                ranges.append((lower - 1)..<upper)
            } else if bounds.count == 1, let index = bounds.first {
                ranges.append((index - 1)..<index)
            }
        }
        return ranges
    }
}



import SwiftUI

// MARK: - Supporting Structures

struct EffectSettings {
    var appearanceSettings: AppearanceSettings
    var mainAnimationSettings: MainAnimationSettings
    var disappearanceSettings: DisappearanceSettings
    var delayBeforeDisappearance: Double
    var colors: [Color]
    var colorPatternType: ColorPatternType
}

struct AppearanceSettings {
    var type: String
    var animation: Animation
    var delayBetweenElements: Double?
    var totalDuration: Double?
    var elementTime: Double?
    var unit: UnitType
    var ranges: [Range<Int>]?
}

struct MainAnimationSettings {
    var type: String
    var unit: UnitType
    var ranges: [Range<Int>]?
    var deviationIntensity: Double?
    var cycleDuration: Double?
    var jumpIntensity: Double?
    var changeStepDuration: Double?
    var rotationDegree: Double?
    var verticalJumpIntensity: Double?
    var waveCycleDuration: Double?
    var waveLength: Int?
}

struct DisappearanceSettings {
    var type: String
    var animation: Animation
    var delayBetweenElements: Double?
    var totalDuration: Double?
    var elementTime: Double?
    var unit: UnitType
    var ranges: [Range<Int>]?
}

enum ColorPatternType {
    case singleColor
    case randomPattern
    case sequentialPattern
}

