import Foundation
import Combine
import CoreMIDI

/// Discovers USB MIDI endpoints exposed to iPadOS. This does not yet speak
/// Hotone's editor protocol; endpoint visibility is the first hardware gate.
@MainActor
final class USBMIDIConnection: ObservableObject {
    @Published private(set) var deviceNames: [String] = []
    @Published private(set) var status = "Searching for MIDI devices"

    private var client = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var outputPort = MIDIPortRef()
    private var connectedSource: MIDIEndpointRef?
    private var connectedDestination: MIDIEndpointRef?

    init() {
        let clientStatus = MIDIClientCreateWithBlock("AmperoPad" as CFString, &client) { [weak self] _ in
            Task { @MainActor in self?.refreshDevices() }
        }
        guard clientStatus == noErr else {
            status = "Core MIDI unavailable (\(clientStatus))"
            return
        }

        MIDIInputPortCreateWithBlock(client, "AmperoPad Input" as CFString, &inputPort) { _, _ in }
        MIDIOutputPortCreate(client, "AmperoPad Output" as CFString, &outputPort)
        refreshDevices()
    }

    func refreshDevices() {
        var names: [String] = []
        let sourceCount = MIDIGetNumberOfSources()
        let destinationCount = MIDIGetNumberOfDestinations()
        for index in 0..<max(sourceCount, destinationCount) {
            if index < sourceCount {
                let endpoint = MIDIGetSource(index)
                if let name = endpointName(endpoint), !names.contains(name) { names.append(name) }
            }
            if index < destinationCount {
                let endpoint = MIDIGetDestination(index)
                if let name = endpointName(endpoint), !names.contains(name) { names.append(name) }
            }
        }
        deviceNames = names
        if names.isEmpty { status = "No MIDI device detected" }
        else if connectedSource == nil { status = "MIDI device found · editor protocol not verified" }
    }

    func connectToFirstAmpero() {
        let source = findEndpoint(direction: .source)
        let destination = findEndpoint(direction: .destination)
        guard let source, let destination else {
            status = "Ampero USB MIDI ports not found"
            return
        }
        let inputStatus = MIDIInputPortConnectSource(inputPort, source, nil)
        guard inputStatus == noErr else {
            status = "Could not open MIDI input (\(inputStatus))"
            return
        }
        connectedSource = source
        connectedDestination = destination
        status = "USB MIDI connected · command protocol pending"
    }

    private enum Direction { case source, destination }

    private func findEndpoint(direction: Direction) -> MIDIEndpointRef? {
        let count = direction == .source ? MIDIGetNumberOfSources() : MIDIGetNumberOfDestinations()
        for index in 0..<count {
            let endpoint = direction == .source ? MIDIGetSource(index) : MIDIGetDestination(index)
            guard let name = endpointName(endpoint)?.lowercased(), name.contains("ampero") else { continue }
            return endpoint
        }
        return nil
    }

    private func endpointName(_ endpoint: MIDIEndpointRef) -> String? {
        var name: Unmanaged<CFString>?
        guard MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name) == noErr else { return nil }
        return name?.takeRetainedValue() as String?
    }
}
