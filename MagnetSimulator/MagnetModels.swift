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

    var isMagneticResponder: Bool {
        switch self {
        case .woodStick, .woodBox, .plasticBall, .ramp:
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
            return "circle.fill"
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
        applyMagnetPhysics(anchorID: object.id)
    }

    func selectTool(_ kind: MagnetKind) {
        add(kind)
    }

    func selectObject(_ id: UUID) {
        guard objects.contains(where: { $0.id == id }) else {
            return
        }

        selectedObjectID = id
    }

    func dragObject(id: UUID, x: Double, z: Double) {
        guard let index = objects.firstIndex(where: { $0.id == id }) else {
            return
        }

        selectedObjectID = id
        objects[index].x = clampedX(x)
        objects[index].z = clampedZ(z)
        applyMagnetPhysics(anchorID: id)
    }

    func finishDragObject(id: UUID) {
        guard objects.contains(where: { $0.id == id }) else {
            return
        }

        selectedObjectID = id
        applyMagnetPhysics(anchorID: nil)
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
        let anchorID = selectedObjectID
        updateSelected { object in
            object.x = clampedX(object.x + dx)
            object.z = clampedZ(object.z + dz)
        }
        applyMagnetPhysics(anchorID: anchorID)
    }

    func rotateSelected(_ delta: Double) {
        let anchorID = selectedObjectID
        updateSelected { object in
            object.yaw += delta
        }
        applyMagnetPhysics(anchorID: anchorID)
    }

    func scaleSelected(_ delta: Double) {
        let anchorID = selectedObjectID
        updateSelected { object in
            object.scale = min(1.9, max(0.55, object.scale + delta))
        }
        applyMagnetPhysics(anchorID: anchorID)
    }

    func reversePolarity() {
        let anchorID = selectedObjectID
        updateSelected { object in
            if object.kind.canFlipPolarity {
                object.polarity *= -1.0
            }
        }
        applyMagnetPhysics(anchorID: anchorID)
    }

    func pulseField() {
        strength = min(2.5, strength + 0.35)
        current = min(1.0, current + 0.2)
        animationSpeed = min(1.0, animationSpeed + 0.1)
        applyMagnetPhysics(anchorID: selectedObjectID)
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

    private func applyMagnetPhysics(anchorID: UUID?) {
        guard objects.count > 1 else {
            return
        }

        for _ in 0..<3 {
            resolveMagneticStep(anchorID: anchorID)
        }
    }

    private func resolveMagneticStep(anchorID: UUID?) {
        let sources = objects.filter { $0.kind.isFieldSource }
        guard sources.isEmpty == false else {
            return
        }

        for source in sources {
            for targetIndex in objects.indices {
                let target = objects[targetIndex]
                guard target.id != source.id, target.id != anchorID, target.kind.isMagneticResponder else {
                    continue
                }

                let dx = target.x - source.x
                let dz = target.z - source.z
                let distance = max(0.08, sqrt(dx * dx + dz * dz))
                guard distance < 3.0 else {
                    continue
                }

                let unitX = distance > 0.1 ? dx / distance : cos(source.yaw)
                let unitZ = distance > 0.1 ? dz / distance : -sin(source.yaw)
                let interaction = interactionBetween(source: source, target: target, unitX: unitX, unitZ: unitZ)
                guard interaction.direction != 0.0 else {
                    continue
                }

                let falloff = pow(max(0.0, (3.0 - distance) / 3.0), 1.65)
                let sourcePower = max(0.15, source.kind.baseStrength * strength)
                let isPoweredSource = source.kind == .solenoid || source.kind == .electromagnet
                let currentBoost = isPoweredSource ? max(0.12, current) : 1.0
                let movement = min(0.34, (0.035 + falloff * 0.32) * sourcePower * currentBoost * interaction.intensity)

                objects[targetIndex].x = clampedX(target.x + unitX * movement * interaction.direction)
                objects[targetIndex].z = clampedZ(target.z + unitZ * movement * interaction.direction)

                let contactDistance = collisionRadius(for: source) + collisionRadius(for: target) + 0.04
                if interaction.direction < 0.0, distance < contactDistance + 0.36 {
                    snapObject(at: targetIndex, to: source, unitX: unitX, unitZ: unitZ, contactDistance: contactDistance)
                } else if interaction.direction > 0.0, distance < contactDistance + 0.2 {
                    objects[targetIndex].x = clampedX(source.x + unitX * (contactDistance + 0.22))
                    objects[targetIndex].z = clampedZ(source.z + unitZ * (contactDistance + 0.22))
                }
            }
        }
    }

    private func interactionBetween(
        source: LabObject,
        target: LabObject,
        unitX: Double,
        unitZ: Double
    ) -> (direction: Double, intensity: Double) {
        if target.kind.isFieldSource {
            let sourcePole = magneticMoment(for: source).x * unitX + magneticMoment(for: source).z * unitZ
            let targetPole = magneticMoment(for: target).x * -unitX + magneticMoment(for: target).z * -unitZ
            let repels = sourcePole * targetPole > 0.0
            return (repels ? 1.0 : -1.0, 1.0)
        }

        switch target.kind {
        case .paperClip:
            return (-1.0, 1.35)
        case .steelBox:
            return (-1.0, 1.05)
        case .ferrofluid:
            return (-1.0, 0.95)
        case .magneticGel:
            return (-1.0, 0.72)
        case .compassNeedle:
            return (-1.0, 0.62)
        default:
            return (0.0, 0.0)
        }
    }

    private func snapObject(
        at index: Int,
        to source: LabObject,
        unitX: Double,
        unitZ: Double,
        contactDistance: Double
    ) {
        objects[index].x = clampedX(source.x + unitX * contactDistance)
        objects[index].z = clampedZ(source.z + unitZ * contactDistance)

        if objects[index].kind.isFieldSource {
            objects[index].yaw = source.yaw
        } else {
            objects[index].yaw = atan2(-unitZ, unitX)
        }
    }

    private func magneticMoment(for object: LabObject) -> (x: Double, z: Double) {
        (
            x: cos(object.yaw) * object.polarity,
            z: -sin(object.yaw) * object.polarity
        )
    }

    private func collisionRadius(for object: LabObject) -> Double {
        let baseRadius: Double
        switch object.kind {
        case .woodStick:
            baseRadius = 0.68
        case .fridgeSheet:
            baseRadius = 0.78
        case .horseshoe, .halbachArray:
            baseRadius = 0.72
        case .bar, .solenoid, .electromagnet, .neodymiumBlock, .ramp:
            baseRadius = 0.64
        case .paperClip:
            baseRadius = 0.38
        case .ferrofluid, .magneticGel:
            baseRadius = 0.58
        default:
            baseRadius = 0.5
        }

        return baseRadius * object.scale
    }

    private func clampedX(_ x: Double) -> Double {
        min(5.4, max(-5.4, x))
    }

    private func clampedZ(_ z: Double) -> Double {
        min(3.6, max(-3.6, z))
    }
}
