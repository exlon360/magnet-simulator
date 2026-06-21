import Combine
import Foundation

enum LabCategory: String, CaseIterable, Identifiable {
    case magnets = "Magnets"
    case objects = "Objects"

    var id: String { rawValue }
}

enum MotionMode: String, CaseIterable, Identifiable {
    case still = "Still"
    case wiggle = "Wiggle"
    case spin = "Spin"
    case float = "Float"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .still:
            return "pause.fill"
        case .wiggle:
            return "waveform.path"
        case .spin:
            return "arrow.triangle.2.circlepath"
        case .float:
            return "arrow.up.and.down"
        }
    }
}

enum MagnetKind: String, CaseIterable, Identifiable {
    case bar = "Bar"
    case horseshoe = "Horseshoe"
    case ring = "Ring"
    case disk = "Disk"
    case cube = "Cube"
    case sphere = "Sphere"
    case neodymiumBlock = "Neodymium"
    case solenoid = "Solenoid"
    case electromagnet = "Electromagnet"
    case halbachArray = "Halbach"
    case fridgeSheet = "Sheet"
    case compassNeedle = "Compass"
    case ferrofluid = "Ferrofluid"
    case magneticGel = "Magnetic Gel"
    case woodStick = "Stick"
    case woodBox = "Wood Box"
    case steelBox = "Steel Box"
    case plasticBall = "Ball"
    case ramp = "Ramp"
    case paperClip = "Clip"

    var id: String { rawValue }

    static var magnets: [MagnetKind] {
        [
            .bar,
            .horseshoe,
            .ring,
            .disk,
            .cube,
            .sphere,
            .neodymiumBlock,
            .solenoid,
            .electromagnet,
            .halbachArray,
            .fridgeSheet,
            .compassNeedle,
            .ferrofluid,
            .magneticGel
        ]
    }

    static var objects: [MagnetKind] {
        [.woodStick, .woodBox, .steelBox, .plasticBall, .ramp, .paperClip]
    }

    var category: LabCategory {
        MagnetKind.magnets.contains(self) ? .magnets : .objects
    }

    var isFieldSource: Bool {
        switch self {
        case .compassNeedle, .ferrofluid, .magneticGel, .woodStick, .woodBox, .steelBox, .plasticBall, .ramp, .paperClip:
            return false
        default:
            return true
        }
    }

    var canFlipPolarity: Bool {
        switch self {
        case .woodStick, .woodBox, .steelBox, .plasticBall, .ramp, .paperClip, .ferrofluid, .magneticGel:
            return false
        default:
            return true
        }
    }

    var symbolName: String {
        switch self {
        case .bar:
            return "minus.rectangle.fill"
        case .horseshoe:
            return "u.square.fill"
        case .ring:
            return "circle.circle.fill"
        case .disk:
            return "record.circle.fill"
        case .cube:
            return "cube.fill"
        case .sphere:
            return "circle.fill"
        case .neodymiumBlock:
            return "shippingbox.fill"
        case .solenoid:
            return "scribble.variable"
        case .electromagnet:
            return "bolt.circle.fill"
        case .halbachArray:
            return "arrow.triangle.2.circlepath"
        case .fridgeSheet:
            return "rectangle.grid.1x2.fill"
        case .compassNeedle:
            return "safari.fill"
        case .ferrofluid:
            return "drop.triangle.fill"
        case .magneticGel:
            return "drop.fill"
        case .woodStick:
            return "line.diagonal"
        case .woodBox:
            return "cube.transparent.fill"
        case .steelBox:
            return "archivebox.fill"
        case .plasticBall:
            return "circle.hexagongrid.fill"
        case .ramp:
            return "triangle.fill"
        case .paperClip:
            return "paperclip"
        }
    }

    var baseStrength: Double {
        switch self {
        case .neodymiumBlock:
            return 1.55
        case .electromagnet:
            return 1.3
        case .bar:
            return 1.1
        case .horseshoe, .halbachArray:
            return 1.05
        case .solenoid:
            return 0.95
        case .ring, .disk, .cube:
            return 0.78
        case .sphere:
            return 0.66
        case .fridgeSheet:
            return 0.45
        case .compassNeedle:
            return 0.25
        default:
            return 0.0
        }
    }
}

struct LabObject: Identifiable, Equatable {
    let id: UUID
    var kind: MagnetKind
    var x: Double
    var z: Double
    var yaw: Double
    var scale: Double
    var polarity: Double

    init(
        id: UUID = UUID(),
        kind: MagnetKind,
        x: Double,
        z: Double,
        yaw: Double = 0.0,
        scale: Double = 1.0,
        polarity: Double = 1.0
    ) {
        self.id = id
        self.kind = kind
        self.x = x
        self.z = z
        self.yaw = yaw
        self.scale = scale
        self.polarity = polarity
    }
}

struct MagnetSceneSnapshot: Equatable {
    var objects: [LabObject]
    var selectedObjectID: UUID?
    var motionMode: MotionMode
    var strength: Double
    var current: Double
    var gelViscosity: Double
    var fieldDensity: Double
    var showFieldLines: Bool
    var showGel: Bool
    var showCompasses: Bool
    var showForces: Bool
    var animationSpeed: Double
    var isPaused: Bool
}

final class MagnetSimulatorStore: ObservableObject {
    @Published var selectedCategory: LabCategory = .magnets
    @Published var selectedTool: MagnetKind = .bar
    @Published var objects: [LabObject] = []
    @Published var selectedObjectID: UUID?
    @Published var motionMode: MotionMode = .still
    @Published var strength: Double = 1.0
    @Published var current: Double = 0.65
    @Published var gelViscosity: Double = 0.45
    @Published var fieldDensity: Double = 0.58
    @Published var showFieldLines: Bool = true
    @Published var showGel: Bool = true
    @Published var showCompasses: Bool = false
    @Published var showForces: Bool = true
    @Published var animationSpeed: Double = 0.55
    @Published var isPaused: Bool = false

    var snapshot: MagnetSceneSnapshot {
        MagnetSceneSnapshot(
            objects: objects,
            selectedObjectID: selectedObjectID,
            motionMode: motionMode,
            strength: strength,
            current: current,
            gelViscosity: gelViscosity,
            fieldDensity: fieldDensity,
            showFieldLines: showFieldLines,
            showGel: showGel,
            showCompasses: showCompasses,
            showForces: showForces,
            animationSpeed: animationSpeed,
            isPaused: isPaused
        )
    }

    var selectedObject: LabObject? {
        guard let selectedObjectID = selectedObjectID else {
            return nil
        }
        return objects.first { $0.id == selectedObjectID }
    }

    var toolList: [MagnetKind] {
        selectedCategory == .magnets ? MagnetKind.magnets : MagnetKind.objects
    }

    func add(_ kind: MagnetKind) {
        selectedTool = kind
        selectedCategory = kind.category

        let index = objects.count
        let column = index % 5
        let row = (index / 5) % 3
        let x = Double(column - 2) * 1.05
        let z = Double(row - 1) * 0.9
        let object = LabObject(kind: kind, x: x, z: z, yaw: Double(index % 4) * 0.2)

        objects.append(object)
        selectedObjectID = object.id
        motionMode = .still
    }

    func selectTool(_ kind: MagnetKind) {
        add(kind)
    }

    func selectPrevious() {
        guard objects.isEmpty == false else {
            selectedObjectID = nil
            return
        }

        guard
            let currentID = selectedObjectID,
            let index = objects.firstIndex(where: { $0.id == currentID })
        else {
            selectedObjectID = objects.last?.id
            return
        }

        let nextIndex = index == 0 ? objects.count - 1 : index - 1
        selectedObjectID = objects[nextIndex].id
    }

    func selectNext() {
        guard objects.isEmpty == false else {
            selectedObjectID = nil
            return
        }

        guard
            let currentID = selectedObjectID,
            let index = objects.firstIndex(where: { $0.id == currentID })
        else {
            selectedObjectID = objects.first?.id
            return
        }

        selectedObjectID = objects[(index + 1) % objects.count].id
    }

    func nudgeSelected(dx: Double, dz: Double) {
        updateSelected { object in
            object.x = min(5.4, max(-5.4, object.x + dx))
            object.z = min(3.6, max(-3.6, object.z + dz))
        }
    }

    func rotateSelected(_ delta: Double) {
        updateSelected { object in
            object.yaw += delta
        }
    }

    func scaleSelected(_ delta: Double) {
        updateSelected { object in
            object.scale = min(1.9, max(0.55, object.scale + delta))
        }
    }

    func reversePolarity() {
        updateSelected { object in
            if object.kind.canFlipPolarity {
                object.polarity *= -1.0
            }
        }
    }

    func pulseField() {
        strength = min(2.5, strength + 0.35)
        current = min(1.0, current + 0.2)
        animationSpeed = min(1.0, animationSpeed + 0.1)
    }

    func deleteSelected() {
        guard let selectedObjectID = selectedObjectID else {
            return
        }

        objects.removeAll { $0.id == selectedObjectID }
        self.selectedObjectID = objects.last?.id
    }

    func clearCanvas() {
        objects.removeAll()
        selectedObjectID = nil
        motionMode = .still
    }

    func resetControls() {
        strength = 1.0
        current = 0.65
        gelViscosity = 0.45
        fieldDensity = 0.58
        showFieldLines = true
        showGel = true
        showCompasses = false
        showForces = true
        animationSpeed = 0.55
        isPaused = false
        motionMode = .still
    }

    private func updateSelected(_ update: (inout LabObject) -> Void) {
        guard
            let selectedObjectID,
            let index = objects.firstIndex(where: { $0.id == selectedObjectID })
        else {
            return
        }

        update(&objects[index])
    }
}
