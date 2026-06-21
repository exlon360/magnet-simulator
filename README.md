# Magnet Simulator

Magnet Simulator is a SwiftUI and SceneKit iOS app for exploring a 3D magnetic sandbox. It opens to an empty canvas, then lets you drop magnets and simple objects from an icon shelf.

## Included Magnet Types

- Bar magnet
- Horseshoe magnet
- Ring magnet
- Disk magnet
- Cube magnet
- Sphere magnet
- Neodymium block
- Solenoid
- Electromagnet
- Halbach array
- Flexible magnetic sheet
- Compass needle
- Ferrofluid
- Magnetic gel
- Wood stick
- Wood box
- Steel box
- Plastic ball
- Ramp
- Paper clip

## Controls

- Icon shelf with magnet and object tabs.
- Tap any tool to drop it on the canvas and select it.
- Tap or drag objects directly on the 3D canvas.
- Nearby magnets repel or attract each other, and steel objects, clips, ferrofluid, and magnetic gel pull toward active magnets.
- Attractive pairs snap to a contact distance when they get close.
- Continuous physics loop with momentum, friction, collision separation, rolling balls/sphere magnets, and ramp downhill motion.
- Magnetic gel stretches into tendrils and wraps around nearby magnets; ferrofluid spikes lean with the field.
- Big iPad-friendly move pad for arrows, rotate, size, polarity flip, pause, and pulse.
- Simple motion modes: Still, Wiggle, Spin, and Float.
- Optional advanced controls for strength, current, gel viscosity, field density, and speed.
- View menu for field lines, magnetic gel, compass grid, and force-arrow toggles.

## GitHub IPA Build

Run the `Build Magnet Simulator IPA` workflow on GitHub, or push a tag like:

```bash
git tag magnetsim-v0.1.0
git push origin magnetsim-v0.1.0
```

The workflow produces `MagnetSimulator-unsigned.ipa`.

Unsigned IPAs still need Apple signing before installing on a real iPhone.
