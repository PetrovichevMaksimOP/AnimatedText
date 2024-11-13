//
//  AnimateText.swift
//  AnimateTextExample
//
//  Created by petrovichev maxim on 13.11.2024.
//

import SwiftUI

// MARK: - AnimateText

public struct AnimateText<E: ATTextAnimateEffect>: View {
    @Binding private var text: String
    var fontSize: CGFloat = 24
    var textAlignment: TextAlignment = .leading
    var userInfo: Any? = nil
    
    @State private var height: CGFloat = 0
    @State private var elements: [ElementInfo] = []
    @State private var value: Double = 0
    @State private var toggle: Bool = false
    @State private var isChanged: Bool = false
    @State private var size: CGSize = .zero
    @State private var assignedColors: [Color] = []
    
    struct ElementInfo {
        var element: String
        var index: Int
        var wordIndex: Int
    }
    
    public init(_ text: Binding<String>, fontSize: CGFloat, textAlignment: TextAlignment = .leading, userInfo: Any? = nil) {
        _text = text
        self.fontSize = fontSize
        self.textAlignment = textAlignment
        self.userInfo = userInfo
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if !isChanged {
                Text(text)
                    .takeSize($size)
                    .multilineTextAlignment(textAlignment)
            } else {
                GeometryReader { geometry in
                    VStack(alignment: horizontalAlignment(), spacing: 0) {
                        let lineElements = splitElements(containerWidth: geometry.size.width)
                        let lines = Array(lineElements.enumerated())

                        ForEach(lines, id: \.0) { lineIndex, elementsInLine in
                            HStack(spacing: 0) {
                                ForEach(elementsInLine, id: \.index) { elementInfo in
                                    let data = ATElementData(
                                        element: elementInfo.element,
                                        index: elementInfo.index,
                                        count: elements.count,
                                        value: value,
                                        size: size,
                                        wordIndex: elementInfo.wordIndex,
                                        color: .red
                                    )
                                    Text(elementInfo.element)
                                        .modifier(E(data, userInfo))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: horizontalAlignmentHStack())
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: horizontalAlignmentVStack())
                    .onAppear {
                        height = CGFloat(splitElements(containerWidth: geometry.size.width).count) * (fontSize + 4)
                    }
                    .onChange(of: geometry.size.width) { _ in
                        height = CGFloat(splitElements(containerWidth: geometry.size.width).count) * (fontSize + 4)
                    }
                }
                .frame(height: height)
            }
        }
        .onChange(of: text) { _ in
            withAnimation {
                value = 0
                getText(text)
                toggle.toggle()
            }
            self.isChanged = true
            DispatchQueue.main.async {
                value = 1
            }
        }
    }

    
    private func getText(_ text: String) {
        elements.removeAll()
        assignedColors.removeAll()
        var wordIndex = 0
        var elementIndex = 0
        var inWord = false
        var previousColor: Color? = nil
        var colorIndex = 0
        let colors = (userInfo as? EffectSettings)?.colors ?? [.black]
        let colorPatternType = (userInfo as? EffectSettings)?.colorPatternType ?? .singleColor

        for char in text {
            let strChar = String(char)
            if strChar == "\n" {
                elements.append(ElementInfo(element: "\n", index: elementIndex, wordIndex: wordIndex))
                elementIndex += 1
                inWord = false
                continue
            } else if strChar == " " {
                inWord = false
            } else {
                if !inWord {
                    inWord = true
                    wordIndex += 1
                }
            }
            elements.append(ElementInfo(element: strChar, index: elementIndex, wordIndex: wordIndex))
            
            // Assign color
            var color: Color
            switch colorPatternType {
            case .singleColor:
                color = colors.first ?? .black
            case .sequentialPattern:
                repeat {
                    color = colors[colorIndex % colors.count]
                    colorIndex += 1
                } while color == previousColor && colors.count > 1
                previousColor = color
            case .randomPattern:
                var availableColors = colors
                if let prevColor = previousColor {
                    availableColors.removeAll { $0 == prevColor }
                }
                color = availableColors.randomElement() ?? .black
                previousColor = color
            }
            assignedColors.append(color)
            
            elementIndex += 1
        }
    }
    
    func splitElements(containerWidth: CGFloat) -> [[ElementInfo]] {
        var lines: [[ElementInfo]] = [[]]
        var currentLineIndex = 0
        var remainingWidth: CGFloat = containerWidth

        for elementInfo in elements {
            if elementInfo.element == "\n" {
                // Start a new line
                currentLineIndex += 1
                lines.append([])
                remainingWidth = containerWidth
                continue
            }

            let elementWidth = elementInfo.element.width(withConstrainedHeight: 1000, font: .systemFont(ofSize: fontSize))

            if elementWidth > remainingWidth {
                currentLineIndex += 1
                lines.append([elementInfo])
                remainingWidth = containerWidth - elementWidth
            } else {
                lines[currentLineIndex].append(elementInfo)
                remainingWidth -= elementWidth
            }
        }

        return lines
    }
    
    private func horizontalAlignment() -> HorizontalAlignment {
        switch textAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
    
    private func horizontalAlignmentHStack() -> Alignment {
        switch textAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
    
    private func horizontalAlignmentVStack() -> Alignment {
        switch textAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin], attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

public protocol ATTextAnimateEffect: ViewModifier {
    init(_ data: ATElementData, _ userInfo: Any?)
}

public struct ATElementData {
    var element: String
    var index: Int
    var count: Int
    var value: Double
    var size: CGSize
    var wordIndex: Int
    var color: Color
}

extension Color {
    init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        guard hex.count == 6 else { return nil }
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue)
            return
        }
        return nil
    }
}

struct TextAnimationConfiguratorView_Previews: PreviewProvider {
    static var previews: some View {
        TextAnimationConfiguratorView()
    }
}
