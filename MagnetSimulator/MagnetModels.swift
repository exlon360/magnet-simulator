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

    var isRollingBody: Bool {
        switch self {
        case .sphere, .plasticBall, .disk, .ring:
            return true
        default:
            return false
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
    var y: Double
    var z: Double
    var yaw: Double
    var scale: Double
    var polarity: Double
    var vx: Double
    var vy: Double
    var vz: Double
    var rollX: Double
    var rollZ: Double

    init(
        id: UUID = UUID(),
        kind: MagnetKind,
        x: Double,
        y: Double = 0.0,
        z: Double,
        yaw: Double = 0.0,
        scale: Double = 1.0,
        polarity: Double = 1.0,
        vx: Double = 0.0,
        vy: Double = 0.0,
        vz: Double = 0.0,
        rollX: Double = 0.0,
        rollZ: Double = 0.0
    ) {
        self.id = id
        self.kind = kind
        self.x = x
        self.y = y
        self.z = z
        self.yaw = yaw
        self.scale = scale
        self.polarity = polarity
        self.vx = vx
        self.vy = vy
        self.vz = vz
        self.rollX = rollX
        self.rollZ = rollZ
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

    private var draggedObjectID: UUID?
    private let physicsTimeStep = 1.0 / 30.0

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

        let nextX = clampedX(x)
        let nextZ = clampedZ(z)
        let dx = nextX - objects[index].x
        let dz = nextZ - objects[index].z

        draggedObjectID = id
        selectedObjectID = id
        objects[index].x = nextX
        objects[index].y = 0.0
        objects[index].z = nextZ
        objects[index].vx = clampedVelocity(dx * 22.0)
        objects[index].vy = 0.0
        objects[index].vz = clampedVelocity(dz * 22.0)
        rollObject(at: index, dx: dx, dz: dz)
        applyMagnetPhysics(anchorID: id)
        resolveCollisions(anchorID: id)
    }

    func finishDragObject(id: UUID) {
        guard let index = objects.firstIndex(where: { $0.id == id }) else {
            return
        }

        draggedObjectID = nil
        selectedObjectID = id
        applyFlickLaunch(at: index)
        applyMagnetPhysics(anchorID: nil)
        resolveCollisions(anchorID: nil)
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
            object.vx = clampedVelocity(object.vx + dx * 7.5)
            object.vz = clampedVelocity(object.vz + dz * 7.5)
        }
        if let anchorID = anchorID, let index = objects.firstIndex(where: { $0.id == anchorID }) {
            rollObject(at: index, dx: dx, dz: dz)
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
        applyPulseKick()
        applyMagnetPhysics(anchorID: selectedObjectID)
    }

    func tickPhysics() {
        guard isPaused == false, physicsNeedsTick() else {
            return
        }

        let previousObjects = objects
        var nextObjects = previousObjects
        let dt = physicsTimeStep

        for index in nextObjects.indices {
            let object = previousObjects[index]
            guard object.id != draggedObjectID else {
                continue
            }

            if object.kind == .ramp {
                nextObjects[index].y = 0.0
                nextObjects[index].vx = 0.0
                nextObjects[index].vy = 0.0
                nextObjects[index].vz = 0.0
                continue
            }

            let acceleration = physicsAcceleration(for: object, in: previousObjects)
            let wasAirborne = object.y > 0.001 || abs(object.vy) > 0.001
            let damping = wasAirborne ? airDampingFactor(for: object) : dampingFactor(for: object)
            var nextVX = clampedVelocity((object.vx + acceleration.x * dt) * damping)
            var nextVY = clampedVerticalVelocity(object.vy + verticalAcceleration(for: object, in: previousObjects) * dt)
            var nextVZ = clampedVelocity((object.vz + acceleration.z * dt) * damping)

            if object.y <= 0.02 {
                nextVY = max(nextVY, rampLaunchVelocity(for: object, in: previousObjects))
            }

            if abs(nextVX) < 0.012 { nextVX = 0.0 }
            if abs(nextVY) < 0.012 { nextVY = 0.0 }
            if abs(nextVZ) < 0.012 { nextVZ = 0.0 }

            let unclampedX = object.x + nextVX * dt
            let unclampedY = object.y + nextVY * dt
            let unclampedZ = object.z + nextVZ * dt
            let nextX = clampedX(unclampedX)
            var nextY = max(0.0, min(3.2, unclampedY))
            let nextZ = clampedZ(unclampedZ)

            if nextX != unclampedX {
                nextVX *= -boundaryRestitution(for: object)
            }
            if unclampedY <= 0.0 {
                let bounce = boundaryRestitution(for: object)
                if abs(nextVY) > 0.72 {
                    nextVY = -nextVY * bounce
                } else {
                    nextVY = 0.0
                }
                nextY = 0.0
            } else if unclampedY > 3.2 {
                nextVY = min(0.0, -abs(nextVY) * 0.2)
            }
            if nextZ != unclampedZ {
                nextVZ *= -boundaryRestitution(for: object)
            }

            nextObjects[index].x = nextX
            nextObjects[index].y = nextY
            nextObjects[index].z = nextZ
            nextObjects[index].vx = nextVX
            nextObjects[index].vy = nextVY
            nextObjects[index].vz = nextVZ

            if object.kind.isRollingBody {
                let radius = max(0.18, collisionRadius(for: object) * 0.72)
                nextObjects[index].rollX = wrappedAngle(object.rollX + nextVZ * dt / radius)
                nextObjects[index].rollZ = wrappedAngle(object.rollZ - nextVX * dt / radius)
            }
        }

        objects = nextObjects
        resolveCollisions(anchorID: draggedObjectID)
        alignRespondersToField()
    }

    func deleteSelected() {
        guard let selectedObjectID = selectedObjectID else {
            return
        }

        objects.removeAll { $0.id == selectedObjectID }
        if draggedObjectID == selectedObjectID {
            draggedObjectID = nil
        }
        self.selectedObjectID = objects.last?.id
    }

    func clearCanvas() {
        objects.removeAll()
        selectedObjectID = nil
        draggedObjectID = nil
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

                let nextX = clampedX(target.x + unitX * movement * interaction.direction)
                let nextZ = clampedZ(target.z + unitZ * movement * interaction.direction)
                objects[targetIndex].x = nextX
                objects[targetIndex].z = nextZ
                let contactDistance = collisionRadius(for: source) + collisionRadius(for: target) + 0.04
                objects[targetIndex].vx = clampedVelocity(objects[targetIndex].vx + (nextX - target.x) * 5.0)
                objects[targetIndex].vz = clampedVelocity(objects[targetIndex].vz + (nextZ - target.z) * 5.0)
                if interaction.direction > 0.0, distance < contactDistance + 0.42 {
                    objects[targetIndex].vy = max(objects[targetIndex].vy, min(3.8, movement * 8.0))
                }
                rollObject(at: targetIndex, dx: nextX - target.x, dz: nextZ - target.z)

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
        objects[index].y = max(0.0, objects[index].y)
        objects[index].z = clampedZ(source.z + unitZ * contactDistance)
        objects[index].vx *= 0.35
        objects[index].vy *= 0.55
        objects[index].vz *= 0.35

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

    private func physicsNeedsTick() -> Bool {
        if objects.contains(where: { abs($0.vx) > 0.012 || abs($0.vy) > 0.012 || abs($0.vz) > 0.012 || $0.y > 0.001 }) {
            return true
        }

        if hasMagneticPairInRange() || hasObjectOverlap() || hasRollingBodyOnRamp() {
            return true
        }

        return false
    }

    private func hasMagneticPairInRange() -> Bool {
        let sources = objects.filter { $0.kind.isFieldSource }
        guard sources.isEmpty == false else {
            return false
        }

        for source in sources {
            for target in objects where target.id != source.id && target.kind.isMagneticResponder {
                let distance = hypot(target.x - source.x, target.z - source.z)
                let contactDistance = collisionRadius(for: source) + collisionRadius(for: target) + 0.08
                if distance > contactDistance * 0.96, distance < 3.2 {
                    return true
                }
            }
        }

        return false
    }

    private func hasObjectOverlap() -> Bool {
        guard objects.count > 1 else {
            return false
        }

        for firstIndex in 0..<(objects.count - 1) {
            for secondIndex in (firstIndex + 1)..<objects.count {
                let first = objects[firstIndex]
                let second = objects[secondIndex]
                let distance = hypot(second.x - first.x, second.z - first.z)
                if distance < collisionRadius(for: first) + collisionRadius(for: second) {
                    return true
                }
            }
        }

        return false
    }

    private func hasRollingBodyOnRamp() -> Bool {
        for object in objects where object.kind.isRollingBody {
            let rampAcceleration = rampAcceleration(for: object, in: objects)
            if abs(rampAcceleration.x) > 0.001 || abs(rampAcceleration.z) > 0.001 {
                return true
            }
        }

        return false
    }

    private func physicsAcceleration(for object: LabObject, in allObjects: [LabObject]) -> (x: Double, z: Double) {
        var acceleration = (x: 0.0, z: 0.0)

        for source in allObjects where source.id != object.id && source.kind.isFieldSource {
            let magnetic = magneticAcceleration(from: source, to: object)
            acceleration.x += magnetic.x
            acceleration.z += magnetic.z
        }

        let ramp = rampAcceleration(for: object, in: allObjects)
        acceleration.x += ramp.x
        acceleration.z += ramp.z

        return acceleration
    }

    private func verticalAcceleration(for object: LabObject, in allObjects: [LabObject]) -> Double {
        guard object.kind != .ramp else {
            return 0.0
        }

        var acceleration = -9.6

        if object.kind.isMagneticResponder || object.kind.isFieldSource {
            let sources = allObjects.filter { $0.kind.isFieldSource && $0.id != object.id }
            for source in sources {
                let dx = object.x - source.x
                let dz = object.z - source.z
                let distance = max(0.2, hypot(dx, dz))
                guard distance < 2.6 else { continue }

                let unitX = dx / distance
                let unitZ = dz / distance
                let interaction = interactionBetween(source: source, target: object, unitX: unitX, unitZ: unitZ)
                if interaction.direction > 0.0 {
                    acceleration += min(8.0, 2.4 * strength * interaction.intensity / max(0.22, distance))
                } else if object.kind == .paperClip || object.kind == .steelBox {
                    acceleration += min(2.4, 0.6 * strength / max(0.28, distance))
                }
            }
        }

        return acceleration
    }

    private func magneticAcceleration(from source: LabObject, to target: LabObject) -> (x: Double, z: Double) {
        guard target.kind.isFieldSource || target.kind.isMagneticResponder else {
            return (x: 0.0, z: 0.0)
        }

        let dx = target.x - source.x
        let dz = target.z - source.z
        let distance = max(0.16, hypot(dx, dz))
        guard distance < 4.2 else {
            return (x: 0.0, z: 0.0)
        }

        let unitX = dx / distance
        let unitZ = dz / distance
        let interaction = interactionBetween(source: source, target: target, unitX: unitX, unitZ: unitZ)
        guard interaction.direction != 0.0 else {
            return (x: 0.0, z: 0.0)
        }

        let isPoweredSource = source.kind == .solenoid || source.kind == .electromagnet
        let currentBoost = isPoweredSource ? max(0.12, current) : 1.0
        let sourcePower = max(0.1, source.kind.baseStrength * strength * currentBoost)
        let falloff = 1.0 / max(0.28, distance * distance)
        let acceleration = min(7.0, 4.2 * sourcePower * interaction.intensity * falloff / mass(for: target))

        return (
            x: unitX * acceleration * interaction.direction,
            z: unitZ * acceleration * interaction.direction
        )
    }

    private func rampAcceleration(for object: LabObject, in allObjects: [LabObject]) -> (x: Double, z: Double) {
        guard object.kind.isRollingBody else {
            return (x: 0.0, z: 0.0)
        }

        for ramp in allObjects where ramp.kind == .ramp {
            let local = localOffset(from: ramp, to: object)
            let rampScale = max(0.55, ramp.scale)
            guard abs(local.x) < 0.86 * rampScale, local.z > -0.66 * rampScale, local.z < 0.78 * rampScale else {
                continue
            }

            let downX = sin(ramp.yaw)
            let downZ = -cos(ramp.yaw)
            let rollBoost = 2.6 + (1.0 - min(1.0, abs(local.x) / max(0.1, rampScale))) * 0.8
            return (x: downX * rollBoost, z: downZ * rollBoost)
        }

        return (x: 0.0, z: 0.0)
    }

    private func rampLaunchVelocity(for object: LabObject, in allObjects: [LabObject]) -> Double {
        guard object.kind.isRollingBody else {
            return 0.0
        }

        let planarSpeed = hypot(object.vx, object.vz)
        guard planarSpeed > 1.0 else {
            return 0.0
        }

        for ramp in allObjects where ramp.kind == .ramp {
            let local = localOffset(from: ramp, to: object)
            let rampScale = max(0.55, ramp.scale)
            let isNearLip = abs(local.x) < 0.66 * rampScale && local.z < -0.34 * rampScale && local.z > -0.82 * rampScale
            guard isNearLip else {
                continue
            }

            return min(3.6, 0.72 + planarSpeed * 0.34)
        }

        return 0.0
    }

    private func resolveCollisions(anchorID: UUID?) {
        guard objects.count > 1 else {
            return
        }

        for _ in 0..<2 {
            for firstIndex in 0..<(objects.count - 1) {
                for secondIndex in (firstIndex + 1)..<objects.count {
                    let first = objects[firstIndex]
                    let second = objects[secondIndex]
                    let verticalGap = abs(second.y - first.y)
                    let collisionHeight = max(0.38, min(collisionRadius(for: first), collisionRadius(for: second)) * 1.15)
                    guard verticalGap < collisionHeight else {
                        continue
                    }

                    let dx = second.x - first.x
                    let dz = second.z - first.z
                    let distance = max(0.001, hypot(dx, dz))
                    let minimumDistance = collisionRadius(for: first) + collisionRadius(for: second)
                    guard distance < minimumDistance else {
                        continue
                    }

                    let normalX = dx / distance
                    let normalZ = dz / distance
                    let overlap = minimumDistance - distance
                    let firstAnchored = first.id == anchorID || first.kind == .ramp
                    let secondAnchored = second.id == anchorID || second.kind == .ramp
                    let firstInverseMass = firstAnchored ? 0.0 : 1.0 / mass(for: first)
                    let secondInverseMass = secondAnchored ? 0.0 : 1.0 / mass(for: second)
                    let totalInverseMass = firstInverseMass + secondInverseMass
                    guard totalInverseMass > 0.0 else {
                        continue
                    }

                    if firstAnchored == false {
                        let correction = overlap * firstInverseMass / totalInverseMass
                        objects[firstIndex].x = clampedX(objects[firstIndex].x - normalX * correction)
                        objects[firstIndex].z = clampedZ(objects[firstIndex].z - normalZ * correction)
                    }

                    if secondAnchored == false {
                        let correction = overlap * secondInverseMass / totalInverseMass
                        objects[secondIndex].x = clampedX(objects[secondIndex].x + normalX * correction)
                        objects[secondIndex].z = clampedZ(objects[secondIndex].z + normalZ * correction)
                    }

                    let relativeVX = objects[secondIndex].vx - objects[firstIndex].vx
                    let relativeVZ = objects[secondIndex].vz - objects[firstIndex].vz
                    let normalVelocity = relativeVX * normalX + relativeVZ * normalZ
                    guard normalVelocity < 0.0 else {
                        continue
                    }

                    let restitution = min(boundaryRestitution(for: first), boundaryRestitution(for: second))
                    let impulse = -(1.0 + restitution) * normalVelocity / totalInverseMass

                    if firstAnchored == false {
                        objects[firstIndex].vx = clampedVelocity(objects[firstIndex].vx - impulse * normalX * firstInverseMass)
                        objects[firstIndex].vy = max(objects[firstIndex].vy, impactLift(impulse: impulse, object: first))
                        objects[firstIndex].vz = clampedVelocity(objects[firstIndex].vz - impulse * normalZ * firstInverseMass)
                    }

                    if secondAnchored == false {
                        objects[secondIndex].vx = clampedVelocity(objects[secondIndex].vx + impulse * normalX * secondInverseMass)
                        objects[secondIndex].vy = max(objects[secondIndex].vy, impactLift(impulse: impulse, object: second))
                        objects[secondIndex].vz = clampedVelocity(objects[secondIndex].vz + impulse * normalZ * secondInverseMass)
                    }
                }
            }
        }
    }

    private func alignRespondersToField() {
        let sources = objects.filter { $0.kind.isFieldSource }
        guard sources.isEmpty == false else {
            return
        }

        for index in objects.indices {
            let object = objects[index]
            guard object.kind.isMagneticResponder, object.kind.isFieldSource == false else {
                continue
            }

            let field = fieldVector2D(at: object, sources: sources)
            let magnitude = hypot(field.x, field.z)
            guard magnitude > 0.02 else {
                continue
            }

            let targetYaw = atan2(-field.z, field.x)
            let turnRate: Double
            switch object.kind {
            case .compassNeedle:
                turnRate = 0.34
            case .paperClip:
                turnRate = 0.22
            case .magneticGel, .ferrofluid:
                turnRate = 0.12
            default:
                turnRate = 0.08
            }
            objects[index].yaw = blendedAngle(from: object.yaw, to: targetYaw, amount: turnRate)
        }
    }

    private func applyPulseKick() {
        let sources = objects.filter { $0.kind.isFieldSource }
        guard sources.isEmpty == false else {
            return
        }

        let previousObjects = objects
        for index in objects.indices {
            let target = previousObjects[index]
            guard target.kind.isMagneticResponder, target.id != selectedObjectID else {
                continue
            }

            var kick = (x: 0.0, z: 0.0)
            for source in sources where source.id != target.id {
                let acceleration = magneticAcceleration(from: source, to: target)
                kick.x += acceleration.x
                kick.z += acceleration.z
            }

            objects[index].vx = clampedVelocity(objects[index].vx + kick.x * 0.16)
            objects[index].vy = max(objects[index].vy, min(3.6, hypot(kick.x, kick.z) * 0.08))
            objects[index].vz = clampedVelocity(objects[index].vz + kick.z * 0.16)
        }
    }

    private func fieldVector2D(at target: LabObject, sources: [LabObject]) -> (x: Double, z: Double) {
        var field = (x: 0.0, z: 0.0)

        for source in sources where source.id != target.id {
            let dx = target.x - source.x
            let dz = target.z - source.z
            let distance = max(0.2, hypot(dx, dz))
            let unitX = dx / distance
            let unitZ = dz / distance
            let moment = magneticMoment(for: source)
            let dot = moment.x * unitX + moment.z * unitZ
            let scale = source.kind.baseStrength * strength / max(0.2, distance * distance * distance)
            field.x += (3.0 * dot * unitX - moment.x) * scale
            field.z += (3.0 * dot * unitZ - moment.z) * scale
        }

        return field
    }

    private func rollObject(at index: Int, dx: Double, dz: Double) {
        guard objects[index].kind.isRollingBody else {
            return
        }

        let radius = max(0.18, collisionRadius(for: objects[index]) * 0.72)
        objects[index].rollX = wrappedAngle(objects[index].rollX + dz / radius)
        objects[index].rollZ = wrappedAngle(objects[index].rollZ - dx / radius)
    }

    private func localOffset(from origin: LabObject, to target: LabObject) -> (x: Double, z: Double) {
        let dx = target.x - origin.x
        let dz = target.z - origin.z
        let cosine = cos(origin.yaw)
        let sine = sin(origin.yaw)
        return (
            x: dx * cosine + dz * sine,
            z: -dx * sine + dz * cosine
        )
    }

    private func mass(for object: LabObject) -> Double {
        let baseMass: Double
        switch object.kind {
        case .neodymiumBlock, .steelBox:
            baseMass = 3.2
        case .electromagnet, .solenoid:
            baseMass = 2.8
        case .woodBox, .ramp:
            baseMass = 2.2
        case .woodStick, .plasticBall:
            baseMass = 0.75
        case .paperClip, .compassNeedle:
            baseMass = 0.28
        case .ferrofluid, .magneticGel:
            baseMass = 0.55 + gelViscosity
        default:
            baseMass = 1.5
        }

        return max(0.18, baseMass * object.scale * object.scale)
    }

    private func dampingFactor(for object: LabObject) -> Double {
        switch object.kind {
        case .plasticBall:
            return 0.992
        case .sphere, .ring, .disk:
            return 0.982
        case .paperClip, .compassNeedle:
            return 0.94
        case .ferrofluid:
            return max(0.76, 0.92 - gelViscosity * 0.1)
        case .magneticGel:
            return max(0.68, 0.9 - gelViscosity * 0.18)
        case .woodStick, .woodBox:
            return 0.86
        case .steelBox:
            return 0.9
        default:
            return 0.94
        }
    }

    private func airDampingFactor(for object: LabObject) -> Double {
        switch object.kind {
        case .paperClip, .compassNeedle:
            return 0.986
        case .magneticGel, .ferrofluid:
            return 0.945
        default:
            return 0.996
        }
    }

    private func boundaryRestitution(for object: LabObject) -> Double {
        switch object.kind {
        case .plasticBall, .sphere:
            return 0.62
        case .ring, .disk:
            return 0.42
        case .magneticGel, .ferrofluid:
            return 0.08
        default:
            return 0.24
        }
    }

    private func applyFlickLaunch(at index: Int) {
        guard objects[index].kind != .ramp else {
            return
        }

        let speed = hypot(objects[index].vx, objects[index].vz)
        guard speed > 1.8 else {
            return
        }

        let liftScale: Double
        switch objects[index].kind {
        case .plasticBall, .sphere:
            liftScale = 0.52
        case .paperClip, .compassNeedle:
            liftScale = 0.38
        case .magneticGel, .ferrofluid:
            liftScale = 0.22
        case .woodBox, .steelBox:
            liftScale = 0.24
        default:
            liftScale = 0.34
        }

        objects[index].vy = max(objects[index].vy, min(5.2, (speed - 1.2) * liftScale))
    }

    private func impactLift(impulse: Double, object: LabObject) -> Double {
        guard object.kind != .ramp else {
            return 0.0
        }

        let lift = impulse / max(0.25, mass(for: object)) * 0.18
        return min(2.4, max(0.0, lift))
    }

    private func clampedX(_ x: Double) -> Double {
        min(5.4, max(-5.4, x))
    }

    private func clampedZ(_ z: Double) -> Double {
        min(3.6, max(-3.6, z))
    }

    private func clampedVelocity(_ value: Double) -> Double {
        min(8.0, max(-8.0, value))
    }

    private func clampedVerticalVelocity(_ value: Double) -> Double {
        min(6.5, max(-9.0, value))
    }

    private func wrappedAngle(_ value: Double) -> Double {
        atan2(sin(value), cos(value))
    }

    private func blendedAngle(from current: Double, to target: Double, amount: Double) -> Double {
        let delta = atan2(sin(target - current), cos(target - current))
        return current + delta * amount
    }
}
