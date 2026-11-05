# AmperoPad

An iPad-first SwiftUI app for editing Hotone Ampero II Stomp presets. The initial interface takes its layout cues from the supplied Ampero editor screenshot, with the goal of bringing the Stage editor's workflows to the Stomp.

## Current scope

- Stage-style preset browser, signal-chain overview, effect browser, and parameter controls.
- Core MIDI endpoint discovery and connection status for USB MIDI devices.
- The displayed preset/effect data is sample UI content. No editor SysEx or preset-writing commands are implemented yet.

## Build

Install XcodeGen, then run `xcodegen generate` in this directory and open `AmperoPad.xcodeproj` in Xcode. Set an iPad simulator or a connected iPad as the run destination. This repository is currently source-only; signing and App Store distribution have not been configured.

## Compatibility findings

Hotone documents USB MIDI input/output on the Ampero II Stomp, and its desktop editor connects over USB. A separate Stomp compatibility project reports verified live preset reads and effect-parameter writes, but it accesses the device through Hotone's installed Windows editor library. That does not establish that the proprietary editor protocol is available through the iPad-visible MIDI endpoint. The next hardware check is to connect the Stomp to an iPad, confirm that Core MIDI discovers its MIDI source and destination, then capture and reproduce a harmless read-only editor request/response before implementing writes.

The project needs to be built in Xcode on a Mac; this Windows workspace cannot compile or run an iPad app.
