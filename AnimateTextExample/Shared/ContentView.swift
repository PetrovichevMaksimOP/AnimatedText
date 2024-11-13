//
//  ContentView.swift
//  AnimateTextExample
//
//  Created by jasu on 2022/02/05.
//  Copyright (c) 2022 jasu All rights reserved.
//

import SwiftUI

import SwiftUI

// MARK: - Enums and Protocols

enum FontStyle: String, CaseIterable, Identifiable {
    case regular, bold, italic
    var id: String { self.rawValue }
}

enum TextAlignmentOption: String, CaseIterable, Identifiable {
    case left, center, right
    var id: String { self.rawValue }
}

enum MainAnimationType: String, CaseIterable, Identifiable {
    case none
    case cyclicMovement
    case jumping
    case wave
    var id: String { self.rawValue }
}

enum UnitType: String, CaseIterable, Identifiable {
    case letters
    case words
    var id: String { self.rawValue }
}

enum AppearanceAnimationType: String, CaseIterable, Identifiable {
    case allAtOnce
    case sequentially
    case random
    var id: String { self.rawValue }
}

enum DisappearanceAnimationType: String, CaseIterable, Identifiable {
    case allAtOnce
    case sequentially
    case random
    var id: String { self.rawValue }
}

// MARK: - Data Models

struct TextAnimationConfiguration: Codable {
    var text: String
    var properties: TextProperties
    var animations: AnimationsConfiguration
    var position: Position
}

struct TextProperties: Codable {
    var font: FontProperties
    var alignment: AlignmentProperties
    var color: ColorProperties
}

struct FontProperties: Codable {
    var name: String
    var size: Double
    var style: String
}

struct AlignmentProperties: Codable {
    var horizontal: String
}

struct ColorProperties: Codable {
    var type: String
    var defaultColor: String?
    var colors: [String]?
}

struct AnimationsConfiguration: Codable {
    var appearance: AnimationSettings
    var main: AnimationSettings
    var disappearance: AnimationSettings
}

struct AnimationSettings: Codable {
    var type: String
    var unit: String?
    var interval: Double?
    var elementTime: Double?
    var totalTime: Double?
    var range: String?
    
    // Parameters for main animations
    // For cyclic movement
    var deviationIntensity: Double?
    var cycleDuration: Double?
    
    // For jumping
    var jumpIntensity: Double?
    var changeStepDuration: Double?
    var rotationDegree: Double?
    
    // For wave
    var verticalJumpIntensity: Double?
    var waveCycleDuration: Double?
    var waveLength: Int?
}

struct Position: Codable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

// MARK: - Main View

struct TextAnimationConfiguratorView: View {
    // MARK: - State Variables
    
    // Text properties
    @State private var inputText: String = "Hello, World!"
    @State private var selectedFontName: String = "System"
    @State private var fontSize: Double = 24.0
    @State private var fontStyle: FontStyle = .regular
    @State private var textAlignment: TextAlignmentOption = .left
    
    // Color properties
    @State private var colorType: String = "singleColor"
    @State private var defaultColor: String = "#000000"
    @State private var colorPattern: String = ""
    
    // Appearance animation properties
    @State private var appearanceAnimation: AppearanceAnimationType = .allAtOnce
    @State private var appearanceAnimationUnit: UnitType = .letters
    @State private var appearanceInterval: Double = 100.0
    @State private var appearanceElementTime: Double = 100.0
    @State private var appearanceTotalTime: Double = 1000.0
    @State private var appearanceRange: String = ""
    
    // Main animation properties
    @State private var mainAnimation: MainAnimationType = .none
    @State private var mainAnimationUnit: UnitType = .letters
    @State private var mainAnimationRange: String = ""
    
    // Parameters for cyclic movement
    @State private var cyclicDeviationIntensity: Double = 10.0
    @State private var cyclicCycleDuration: Double = 1.0
    
    // Parameters for jumping
    @State private var jumpingIntensity: Double = 10.0
    @State private var jumpingStepDuration: Double = 0.2
    @State private var jumpingRotationDegree: Double = 15.0
    
    // Parameters for wave
    @State private var waveVerticalIntensity: Double = 10.0
    @State private var waveCycleDuration: Double = 2.0
    @State private var waveLength: Double = 5.0
    
    // Disappearance animation properties
    @State private var disappearanceAnimation: DisappearanceAnimationType = .allAtOnce
    @State private var disappearanceAnimationUnit: UnitType = .letters
    @State private var disappearanceInterval: Double = 100.0
    @State private var disappearanceElementTime: Double = 100.0
    @State private var disappearanceTotalTime: Double = 1000.0
    @State private var disappearanceRange: String = ""
    
    // Position properties
    @State private var positionX: Double = 0.0
    @State private var positionY: Double = 0.0
    @State private var positionWidth: Double = 300.0
    @State private var positionHeight: Double = 200.0
    
    // Other state variables
    @State private var showAnimatedText: Bool = false
    @State private var configuration: TextAnimationConfiguration?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showJSONInput: Bool = false
    @State private var jsonInput: String = ""
    
    // MARK: - Dismiss Keyboard
    @FocusState private var focusedField: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Settings View
            ScrollView {
                VStack(alignment: .leading) {
                    // Text Input
                    Text("Текст:")
                        .font(.headline)
                    TextEditor(text: $inputText)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                        .padding(.bottom)
                        .focused($focusedField)
                    
                    // Font Settings
                    Text("Шрифт:")
                        .font(.headline)
                    HStack {
                        TextField("Название шрифта", text: $selectedFontName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField)
                        Stepper("Размер: \(Int(fontSize))", value: $fontSize, in: 10...100)
                    }
                    Picker("Стиль", selection: $fontStyle) {
                        ForEach(FontStyle.allCases) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)
                    
                    // Alignment
                    Text("Выравнивание:")
                        .font(.headline)
                    Picker("Выравнивание", selection: $textAlignment) {
                        ForEach(TextAlignmentOption.allCases) { alignment in
                            Text(alignment.rawValue.capitalized).tag(alignment)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)
                    
                    // Color Settings
                    Text("Цвет текста:")
                        .font(.headline)
                    Picker("Тип цвета", selection: $colorType) {
                        Text("Один цвет").tag("singleColor")
                        Text("Множество цветов").tag("patternColor")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)
                    
                    if colorType == "singleColor" {
                        TextField("Цвет (HEX)", text: $defaultColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom)
                            .focused($focusedField)
                    } else {
                        TextField("Цвета (через запятую, HEX)", text: $colorPattern)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom)
                            .focused($focusedField)
                    }
                    
                    // Appearance Animation
                    Group {
                        Text("Анимация появления:")
                            .font(.headline)
                        Picker("Тип", selection: $appearanceAnimation) {
                            ForEach(AppearanceAnimationType.allCases) { animation in
                                Text(animation.rawValue.capitalized).tag(animation)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                        
                        if appearanceAnimation != .allAtOnce {
                            Picker("Применять к", selection: $appearanceAnimationUnit) {
                                ForEach(UnitType.allCases) { unit in
                                    Text(unit.rawValue.capitalized).tag(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom)
                            
                            if appearanceAnimation == .sequentially {
                                Text("Интервал между элементами (мс): \(Int(appearanceInterval))")
                                Slider(value: $appearanceInterval, in: 0...1000, step: 10)
                                    .padding(.bottom)
                            } else if appearanceAnimation == .random {
                                Text("Время появления одного элемента (мс): \(Int(appearanceElementTime))")
                                Slider(value: $appearanceElementTime, in: 0...1000, step: 10)
                                    .padding(.bottom)
                                Text("Общее время появления (мс): \(Int(appearanceTotalTime))")
                                Slider(value: $appearanceTotalTime, in: 0...5000, step: 100)
                                    .padding(.bottom)
                            }
                            
                            // Range Input
                            TextField("Диапазоны (напр. 1-1,5-18,22-34)", text: $appearanceRange)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom)
                                .focused($focusedField)
                        }
                    }
                    
                    // Main Animation
                    Group {
                        Text("Основная анимация:")
                            .font(.headline)
                        Picker("Тип", selection: $mainAnimation) {
                            ForEach(MainAnimationType.allCases) { animation in
                                Text(animationDisplayName(animation)).tag(animation)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                        
                        if mainAnimation != .none {
                            Picker("Применять к", selection: $mainAnimationUnit) {
                                ForEach(UnitType.allCases) { unit in
                                    Text(unit.rawValue.capitalized).tag(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom)
                            
                            // Range Input
                            TextField("Диапазоны (напр. 1-1,5-18,22-34)", text: $mainAnimationRange)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom)
                                .focused($focusedField)
                        }
                        
                        // Additional settings for main animations
                        if mainAnimation == .cyclicMovement {
                            Text("Интенсивность отклонения буквы: \(Int(cyclicDeviationIntensity))")
                            Slider(value: $cyclicDeviationIntensity, in: 0...50, step: 1)
                                .padding(.bottom)
                            
                            Text("Скорость цикла (сек): \(String(format: "%.1f", cyclicCycleDuration))")
                            Slider(value: $cyclicCycleDuration, in: 0.1...5.0, step: 0.1)
                                .padding(.bottom)
                        } else if mainAnimation == .jumping {
                            Text("Интенсивность скачков буквы: \(Int(jumpingIntensity))")
                            Slider(value: $jumpingIntensity, in: 0...50, step: 1)
                                .padding(.bottom)
                            
                            Text("Шаг изменения положения (сек): \(String(format: "%.1f", jumpingStepDuration))")
                            Slider(value: $jumpingStepDuration, in: 0.1...2.0, step: 0.1)
                                .padding(.bottom)
                            
                            Text("Степень отклонения буквы (градусы): \(Int(jumpingRotationDegree))")
                            Slider(value: $jumpingRotationDegree, in: 0...360, step: 1)
                                .padding(.bottom)
                        } else if mainAnimation == .wave {
                            Text("Интенсивность скачков по вертикали: \(Int(waveVerticalIntensity))")
                            Slider(value: $waveVerticalIntensity, in: 0...50, step: 1)
                                .padding(.bottom)
                            
                            Text("Время одного цикла волны (сек): \(String(format: "%.1f", waveCycleDuration))")
                            Slider(value: $waveCycleDuration, in: 0.1...5.0, step: 0.1)
                                .padding(.bottom)
                            
                            Text("Длина одной волны (букв): \(Int(waveLength))")
                            Slider(value: $waveLength, in: 1...20, step: 1)
                                .padding(.bottom)
                        }
                    }
                    
                    // Disappearance Animation
                    Group {
                        Text("Анимация исчезновения:")
                            .font(.headline)
                        Picker("Тип", selection: $disappearanceAnimation) {
                            ForEach(DisappearanceAnimationType.allCases) { animation in
                                Text(animation.rawValue.capitalized).tag(animation)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                        
                        if disappearanceAnimation != .allAtOnce {
                            Picker("Применять к", selection: $disappearanceAnimationUnit) {
                                ForEach(UnitType.allCases) { unit in
                                    Text(unit.rawValue.capitalized).tag(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom)
                            
                            if disappearanceAnimation == .sequentially {
                                Text("Интервал между элементами (мс): \(Int(disappearanceInterval))")
                                Slider(value: $disappearanceInterval, in: 0...1000, step: 10)
                                    .padding(.bottom)
                            } else if disappearanceAnimation == .random {
                                Text("Время исчезновения одного элемента (мс): \(Int(disappearanceElementTime))")
                                Slider(value: $disappearanceElementTime, in: 0...1000, step: 10)
                                    .padding(.bottom)
                                Text("Общее время исчезновения (мс): \(Int(disappearanceTotalTime))")
                                Slider(value: $disappearanceTotalTime, in: 0...5000, step: 100)
                                    .padding(.bottom)
                            }
                            
                            // Range Input
                            TextField("Диапазоны (напр. 1-1,5-18,22-34)", text: $disappearanceRange)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom)
                                .focused($focusedField)
                        }
                    }
                    
                    // Position
                    Group {
                        Text("Позиция и размер:")
                            .font(.headline)
                        HStack {
                            Text("X:")
                            TextField("X", value: $positionX, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField)
                            Text("Y:")
                            TextField("Y", value: $positionY, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField)
                        }
                        HStack {
                            Text("Ширина:")
                            TextField("Ширина", value: $positionWidth, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField)
                            Text("Высота:")
                            TextField("Высота", value: $positionHeight, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField)
                        }
                        .padding(.bottom)
                    }
                    
                    // Actions
                    HStack {
                        Button(action: {
                            hideKeyboard()
                            let jsonString = generateJSON()
                            UIPasteboard.general.string = jsonString
                            alertMessage = "JSON скопирован в буфер обмена."
                            showAlert = true
                        }) {
                            Text("Скопировать JSON")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: {
                            hideKeyboard()
                            showJSONInput = true
                        }) {
                            Text("Вставить JSON")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom)
                    
                    Button(action: {
                        hideKeyboard()
                        let jsonString = generateJSON()
                        if let config = parseJSON(jsonString) {
                            configuration = config
                            showAnimatedText = true
                        } else {
                            alertMessage = "Не удалось сгенерировать анимацию."
                            showAlert = true
                        }
                    }) {
                        Text("Тестировать анимацию")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            if showAnimatedText {
                                showAnimatedText = false
                            }
                        }
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Сообщение"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showJSONInput) {
                VStack {
                    Text("Вставить JSON")
                        .font(.headline)
                    TextEditor(text: $jsonInput)
                        .border(Color.gray)
                        .frame(height: 300)
                    HStack {
                        Button("Отмена") {
                            showJSONInput = false
                        }
                        .padding()
                        Spacer()
                        Button("Применить") {
                            if let config = parseJSON(jsonInput) {
                                applyConfiguration(config)
                                showJSONInput = false
                            } else {
                                alertMessage = "Неверный формат JSON."
                                showAlert = true
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            
            // AnimatedTextView
            if showAnimatedText, let config = configuration {
                AnimatedTextView(configuration: config)
                    .frame(width: config.position.width, height: config.position.height)
                    .border(Color.red, width: 2)
                    .position(x: config.position.x + config.position.width / 2, y: config.position.y + config.position.height / 2)
                    .onTapGesture {
                        // Do nothing to prevent hiding when tapping inside AnimatedTextView
                    }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func animationDisplayName(_ animation: MainAnimationType) -> String {
        switch animation {
        case .none:
            return "Нет"
        case .cyclicMovement:
            return "Циклическое движение"
        case .jumping:
            return "Скакание"
        case .wave:
            return "Волна"
        }
    }
    
    func generateJSON() -> String {
        let configuration = TextAnimationConfiguration(
            text: inputText,
            properties: TextProperties(
                font: FontProperties(
                    name: selectedFontName,
                    size: fontSize,
                    style: fontStyle.rawValue
                ),
                alignment: AlignmentProperties(
                    horizontal: textAlignment.rawValue
                ),
                color: ColorProperties(
                    type: colorType,
                    defaultColor: colorType == "singleColor" ? defaultColor : nil,
                    colors: colorType == "patternColor" ? colorPattern.split(separator: ",").map { String($0) } : nil
                )
            ),
            animations: AnimationsConfiguration(
                appearance: AnimationSettings(
                    type: appearanceAnimation.rawValue,
                    unit: appearanceAnimation != .allAtOnce ? appearanceAnimationUnit.rawValue : nil,
                    interval: appearanceAnimation == .sequentially ? appearanceInterval : nil,
                    elementTime: appearanceAnimation == .random ? appearanceElementTime : nil,
                    totalTime: appearanceAnimation == .random ? appearanceTotalTime : nil,
                    range: appearanceRange.isEmpty ? nil : appearanceRange
                ),
                main: AnimationSettings(
                    type: mainAnimation.rawValue,
                    unit: mainAnimation != .none ? mainAnimationUnit.rawValue : nil,
                    range: mainAnimationRange.isEmpty ? nil : mainAnimationRange,
                    deviationIntensity: mainAnimation == .cyclicMovement ? cyclicDeviationIntensity : nil,
                    cycleDuration: mainAnimation == .cyclicMovement ? cyclicCycleDuration : nil,
                    jumpIntensity: mainAnimation == .jumping ? jumpingIntensity : nil,
                    changeStepDuration: mainAnimation == .jumping ? jumpingStepDuration : nil,
                    rotationDegree: mainAnimation == .jumping ? jumpingRotationDegree : nil,
                    verticalJumpIntensity: mainAnimation == .wave ? waveVerticalIntensity : nil,
                    waveCycleDuration: mainAnimation == .wave ? waveCycleDuration : nil,
                    waveLength: mainAnimation == .wave ? Int(waveLength) : nil
                ),
                disappearance: AnimationSettings(
                    type: disappearanceAnimation.rawValue,
                    unit: disappearanceAnimation != .allAtOnce ? disappearanceAnimationUnit.rawValue : nil,
                    interval: disappearanceAnimation == .sequentially ? disappearanceInterval : nil,
                    elementTime: disappearanceAnimation == .random ? disappearanceElementTime : nil,
                    totalTime: disappearanceAnimation == .random ? disappearanceTotalTime : nil,
                    range: disappearanceRange.isEmpty ? nil : disappearanceRange
                )
            ),
            position: Position(
                x: positionX,
                y: positionY,
                width: positionWidth,
                height: positionHeight
            )
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(configuration) {
            return String(data: data, encoding: .utf8) ?? ""
        } else {
            return ""
        }
    }
    
    func parseJSON(_ jsonString: String) -> TextAnimationConfiguration? {
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8) {
            return try? decoder.decode(TextAnimationConfiguration.self, from: data)
        }
        return nil
    }
    
    func applyConfiguration(_ config: TextAnimationConfiguration) {
        inputText = config.text
        selectedFontName = config.properties.font.name
        fontSize = config.properties.font.size
        fontStyle = FontStyle(rawValue: config.properties.font.style) ?? .regular
        textAlignment = TextAlignmentOption(rawValue: config.properties.alignment.horizontal) ?? .left
        colorType = config.properties.color.type
        defaultColor = config.properties.color.defaultColor ?? "#000000"
        colorPattern = config.properties.color.colors?.joined(separator: ",") ?? ""
        
        // Appearance Animation
        appearanceAnimation = AppearanceAnimationType(rawValue: config.animations.appearance.type) ?? .allAtOnce
        appearanceAnimationUnit = UnitType(rawValue: config.animations.appearance.unit ?? "letters") ?? .letters
        appearanceInterval = config.animations.appearance.interval ?? 100.0
        appearanceElementTime = config.animations.appearance.elementTime ?? 100.0
        appearanceTotalTime = config.animations.appearance.totalTime ?? 1000.0
        appearanceRange = config.animations.appearance.range ?? ""
        
        // Main Animation
        mainAnimation = MainAnimationType(rawValue: config.animations.main.type) ?? .none
        mainAnimationUnit = UnitType(rawValue: config.animations.main.unit ?? "letters") ?? .letters
        mainAnimationRange = config.animations.main.range ?? ""
        cyclicDeviationIntensity = config.animations.main.deviationIntensity ?? 10.0
        cyclicCycleDuration = config.animations.main.cycleDuration ?? 1.0
        jumpingIntensity = config.animations.main.jumpIntensity ?? 10.0
        jumpingStepDuration = config.animations.main.changeStepDuration ?? 0.2
        jumpingRotationDegree = config.animations.main.rotationDegree ?? 15.0
        waveVerticalIntensity = config.animations.main.verticalJumpIntensity ?? 10.0
        waveCycleDuration = config.animations.main.waveCycleDuration ?? 2.0
        waveLength = Double(config.animations.main.waveLength ?? 5)
        
        // Disappearance Animation
        disappearanceAnimation = DisappearanceAnimationType(rawValue: config.animations.disappearance.type) ?? .allAtOnce
        disappearanceAnimationUnit = UnitType(rawValue: config.animations.disappearance.unit ?? "letters") ?? .letters
        disappearanceInterval = config.animations.disappearance.interval ?? 100.0
        disappearanceElementTime = config.animations.disappearance.elementTime ?? 100.0
        disappearanceTotalTime = config.animations.disappearance.totalTime ?? 1000.0
        disappearanceRange = config.animations.disappearance.range ?? ""
        
        // Position
        positionX = config.position.x
        positionY = config.position.y
        positionWidth = config.position.width
        positionHeight = config.position.height
    }
    
    func hideKeyboard() {
        focusedField = false
    }
}




