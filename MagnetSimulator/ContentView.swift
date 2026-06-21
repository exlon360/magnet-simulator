import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var store = MagnetSimulatorStore()
    @State private var advancedControlsOpen = false

    var body: some View {
        ZStack {
            MagnetSceneView(snapshot: store.snapshot)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topToolbar
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    if advancedControlsOpen {
                        advancedControls
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    toolShelf

                    motionControls
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .background(Color.black)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: advancedControlsOpen)
        .animation(.spring(response: 0.25, dampingFraction: 0.88), value: store.selectedObjectID)
        .animation(.spring(response: 0.25, dampingFraction: 0.88), value: store.objects)
    }

    private var topToolbar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "circle.hexagongrid.circle.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.magnetCyan)
                    .frame(width: 42, height: 42)
                    .background(.black.opacity(0.36), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Magnet Lab")
                        .font(.headline.weight(.black))
                        .lineLimit(1)
                    Text(store.selectedObject?.kind.rawValue ?? "\(store.objects.count) objects")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Spacer()

            HStack(spacing: 8) {
                TopIconButton(symbolName: "chevron.left", tint: .magnetCyan) {
                    store.selectPrevious()
                }
                .disabled(store.objects.isEmpty)

                TopIconButton(symbolName: "chevron.right", tint: .magnetCyan) {
                    store.selectNext()
                }
                .disabled(store.objects.isEmpty)

                TopIconButton(symbolName: store.showFieldLines ? "point.3.connected.trianglepath.dotted" : "point.3.filled.connected.trianglepath.dotted", tint: .magnetCyan) {
                    store.showFieldLines.toggle()
                }

                TopIconButton(symbolName: store.showCompasses ? "safari.fill" : "safari", tint: .magnetGold) {
                    store.showCompasses.toggle()
                }

                TopIconButton(symbolName: store.showForces ? "arrow.up.right.circle.fill" : "arrow.up.right.circle", tint: .magnetGreen) {
                    store.showForces.toggle()
                }

                TopIconButton(symbolName: "slider.horizontal.3", tint: .magnetViolet) {
                    advancedControlsOpen.toggle()
                }

                TopIconButton(symbolName: "trash.fill", tint: .magnetRose) {
                    store.deleteSelected()
                }
                .disabled(store.selectedObject == nil)

                TopIconButton(symbolName: "xmark.bin.fill", tint: .magnetRose) {
                    store.clearCanvas()
                }
                .disabled(store.objects.isEmpty)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var toolShelf: some View {
        VStack(spacing: 8) {
            Picker("Shelf", selection: $store.selectedCategory) {
                ForEach(LabCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .tint(.magnetCyan)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.toolList) { tool in
                        ToolTile(
                            tool: tool,
                            isSelected: store.selectedTool == tool,
                            action: { store.selectTool(tool) }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var motionControls: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    MotionModeButton(mode: .still, selectedMode: store.motionMode) {
                        store.motionMode = .still
                    }
                    MotionModeButton(mode: .wiggle, selectedMode: store.motionMode) {
                        store.motionMode = .wiggle
                    }
                    MotionModeButton(mode: .spin, selectedMode: store.motionMode) {
                        store.motionMode = .spin
                    }
                    MotionModeButton(mode: .float, selectedMode: store.motionMode) {
                        store.motionMode = .float
                    }
                }

                HStack(spacing: 8) {
                    BigActionButton(symbolName: "arrow.counterclockwise", tint: .magnetGold) {
                        store.rotateSelected(-.pi / 10.0)
                    }

                    VStack(spacing: 8) {
                        BigActionButton(symbolName: "arrow.up", tint: .magnetCyan) {
                            store.nudgeSelected(dx: 0.0, dz: -0.32)
                        }

                        HStack(spacing: 8) {
                            BigActionButton(symbolName: "arrow.left", tint: .magnetCyan) {
                                store.nudgeSelected(dx: -0.32, dz: 0.0)
                            }

                            BigActionButton(symbolName: "circle.fill", tint: store.selectedObject == nil ? .secondary : store.selectedObject!.kind.toolTint) {
                                store.pulseField()
                            }

                            BigActionButton(symbolName: "arrow.right", tint: .magnetCyan) {
                                store.nudgeSelected(dx: 0.32, dz: 0.0)
                            }
                        }

                        BigActionButton(symbolName: "arrow.down", tint: .magnetCyan) {
                            store.nudgeSelected(dx: 0.0, dz: 0.32)
                        }
                    }

                    BigActionButton(symbolName: "arrow.clockwise", tint: .magnetGold) {
                        store.rotateSelected(.pi / 10.0)
                    }
                }
            }
            .disabled(store.selectedObject == nil)
            .opacity(store.selectedObject == nil ? 0.42 : 1.0)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    BigActionButton(symbolName: "minus.magnifyingglass", tint: .magnetViolet) {
                        store.scaleSelected(-0.12)
                    }

                    BigActionButton(symbolName: "plus.magnifyingglass", tint: .magnetViolet) {
                        store.scaleSelected(0.12)
                    }
                }

                HStack(spacing: 8) {
                    BigActionButton(symbolName: "arrow.left.arrow.right", tint: .magnetRose) {
                        store.reversePolarity()
                    }
                    .disabled(store.selectedObject?.kind.canFlipPolarity == false || store.selectedObject == nil)

                    BigActionButton(symbolName: store.isPaused ? "play.fill" : "pause.fill", tint: .magnetGreen) {
                        store.isPaused.toggle()
                    }
                }

                Button {
                    store.resetControls()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(LabButtonStyle(tint: .magnetCyan))
            }
            .frame(width: 148)
        }
    }

    private var advancedControls: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 8) {
            GridRow {
                LabSlider(title: "Power", value: $store.strength, range: 0.2...2.5, tint: .magnetRose)
                LabSlider(title: "Current", value: $store.current, range: 0.0...1.0, tint: .magnetGold)
            }

            GridRow {
                LabSlider(title: "Gel", value: $store.gelViscosity, range: 0.0...1.0, tint: .magnetGreen)
                LabSlider(title: "Speed", value: $store.animationSpeed, range: 0.0...1.0, tint: .magnetViolet)
            }

            GridRow {
                LabSlider(title: "Field", value: $store.fieldDensity, range: 0.0...1.0, tint: .magnetCyan)

                Toggle(isOn: $store.showGel) {
                    Label("Gel", systemImage: "drop.fill")
                        .font(.caption.weight(.black))
                }
                .toggleStyle(.button)
                .buttonStyle(LabButtonStyle(tint: .magnetGreen))
            }
        }
        .padding(10)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ToolTile: View {
    let tool: MagnetKind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tool.symbolName)
                    .font(.title2.weight(.black))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 52, height: 42)
                    .foregroundStyle(isSelected ? .black : tool.toolTint)
                    .background(isSelected ? tool.toolTint : tool.toolTint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(tool.rawValue)
                    .font(.caption2.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(.primary)
            }
            .frame(width: 78, height: 74)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.white.opacity(isSelected ? 0.13 : 0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isSelected ? tool.toolTint.opacity(0.85) : .white.opacity(0.11), lineWidth: isSelected ? 2 : 1)
        }
    }
}

private struct MotionModeButton: View {
    let mode: MotionMode
    let selectedMode: MotionMode
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mode.symbolName)
                    .font(.headline.weight(.black))
                Text(mode.rawValue)
                    .font(.caption2.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(LabButtonStyle(tint: selectedMode == mode ? .magnetGreen : .magnetViolet))
    }
}

private struct BigActionButton: View {
    let symbolName: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.title2.weight(.black))
                .frame(width: 52, height: 52)
        }
        .buttonStyle(LabIconButtonStyle(tint: tint))
    }
}

private struct TopIconButton: View {
    let symbolName: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.headline.weight(.black))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(LabIconButtonStyle(tint: tint))
    }
}

private struct LabSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption.weight(.black))
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range)
                .tint(tint)
        }
    }
}

private struct LabButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .black : tint)
            .padding(.horizontal, 10)
            .background(configuration.isPressed ? tint : tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(tint.opacity(0.28), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

private struct LabIconButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .black : tint)
            .background(configuration.isPressed ? tint : tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(tint.opacity(0.3), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

private extension MagnetKind {
    var toolTint: Color {
        switch self {
        case .bar, .horseshoe, .neodymiumBlock, .electromagnet:
            return .magnetRose
        case .ring, .disk, .cube, .sphere, .halbachArray:
            return .magnetCyan
        case .solenoid, .fridgeSheet:
            return .magnetGold
        case .compassNeedle:
            return .magnetGreen
        case .ferrofluid, .magneticGel:
            return .magnetViolet
        case .woodStick, .woodBox, .ramp:
            return .labWood
        case .steelBox, .paperClip:
            return .labSteel
        case .plasticBall:
            return .labPlastic
        }
    }
}

private extension Color {
    static let magnetCyan = Color(red: 0.32, green: 0.88, blue: 1.0)
    static let magnetGold = Color(red: 1.0, green: 0.78, blue: 0.28)
    static let magnetGreen = Color(red: 0.42, green: 0.94, blue: 0.55)
    static let magnetRose = Color(red: 1.0, green: 0.32, blue: 0.45)
    static let magnetViolet = Color(red: 0.74, green: 0.54, blue: 1.0)
    static let labWood = Color(red: 0.9, green: 0.58, blue: 0.28)
    static let labSteel = Color(red: 0.74, green: 0.8, blue: 0.86)
    static let labPlastic = Color(red: 0.66, green: 0.96, blue: 0.36)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
