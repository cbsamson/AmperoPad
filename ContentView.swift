import SwiftUI

private struct Preset: Identifiable {
    let id: String
    let name: String
}

private struct EffectBlock: Identifiable {
    let id: String
    let color: Color
    var active = true
}

private struct EffectCategory: Identifiable {
    let id: String
    let symbol: String
}

struct ContentView: View {
    @StateObject private var midi = USBMIDIConnection()
    @State private var selectedPreset = "A82-1"
    @State private var selectedEffect = "Prince of Drive"
    @State private var gain = 25.0
    @State private var tone = 40.0
    @State private var volume = 45.0

    private let gold = Color(red: 1, green: 0.69, blue: 0.12)
    private let panel = Color(red: 0.09, green: 0.09, blue: 0.10)
    private let presets = [
        Preset(id: "A77-3", name: "Empty"), Preset(id: "A78-1", name: "Empty"),
        Preset(id: "A79-2", name: "PLINI CLEAN"), Preset(id: "A79-3", name: "Plini Drive"),
        Preset(id: "A80-1", name: "Plini Lead"), Preset(id: "A80-2", name: "gp5 drv test"),
        Preset(id: "A81-1", name: "BASS DREF"), Preset(id: "A81-2", name: "DJENT KUNO"),
        Preset(id: "A81-3", name: "Zen Base Exp"), Preset(id: "A82-1", name: "Practice Patch"),
        Preset(id: "A82-2", name: "NewNameWritten"), Preset(id: "A82-3", name: "GlrsJBPTnm"),
        Preset(id: "A83-1", name: "YourPromises"), Preset(id: "A83-2", name: "Mellow Prince")
    ]
    private let effects = ["Prince of Drive", "Noble Drive", "Big Pie", "Face Fuzz", "Bend Fuzz", "Plustortion", "Smooth Dist", "Black Tail"]
    private let categories = [
        EffectCategory(id: "DYN", symbol: "waveform"), EffectCategory(id: "FREQ", symbol: "waveform.path"),
        EffectCategory(id: "WAH", symbol: "pianokeys"), EffectCategory(id: "DRV", symbol: "waveform"),
        EffectCategory(id: "AMP", symbol: "rectangle.stack"), EffectCategory(id: "CAB", symbol: "cabinet"),
        EffectCategory(id: "EQ", symbol: "slider.horizontal.3"), EffectCategory(id: "MOD", symbol: "waveform.path")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            HStack(spacing: 8) {
                presetSidebar.frame(width: 245)
                VStack(spacing: 8) {
                    chainPanel.frame(height: 240)
                    editorPanel
                }
            }.padding(8)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 0) {
                Text("AMPERO II STOMP").font(.system(size: 18, weight: .black, design: .rounded)).tracking(2).foregroundStyle(gold)
                Text("CDCM HD Gen 2 Amp Modeler / Effects Processor").font(.system(size: 8)).foregroundStyle(gold.opacity(0.8))
            }.padding(.leading, 14)
            Text("Edit").foregroundStyle(gold).font(.headline)
            Text("Global Settings").font(.headline)
            Text("Community").font(.headline)
            Spacer()
            Button { midi.refreshDevices() } label: {
                Label(midi.status, systemImage: "cable.connector").font(.caption).lineLimit(1)
            }.buttonStyle(.bordered).tint(gold).frame(maxWidth: 320)
            Button("Connect USB") { midi.connectToFirstAmpero() }.buttonStyle(.borderedProminent).tint(gold).foregroundStyle(.black)
        }
        .padding(.horizontal, 12).frame(height: 72).background(Color(red: 0.12, green: 0.12, blue: 0.13))
    }

    private var presetSidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Text("All").foregroundStyle(gold); Spacer(); Text("Style").foregroundStyle(.gray) }.font(.subheadline).padding(10)
            Label("Search presets", systemImage: "magnifyingglass").font(.caption).foregroundStyle(.gray).padding(9).background(panel).clipShape(RoundedRectangle(cornerRadius: 6))
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(presets) { preset in
                        Button { selectedPreset = preset.id } label: {
                            HStack(spacing: 8) {
                                Text(preset.id).frame(width: 52, alignment: .leading).foregroundStyle(.gray)
                                Text(preset.name).lineLimit(1).foregroundStyle(selectedPreset == preset.id ? gold : .white)
                                Spacer(minLength: 0)
                                Image(systemName: "line.3.horizontal").foregroundStyle(.gray)
                            }.font(.system(size: 12)).padding(.vertical, 7).padding(.horizontal, 6)
                                .background(selectedPreset == preset.id ? Color.white.opacity(0.10) : .clear)
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(10).background(panel).overlay(Rectangle().stroke(Color.white.opacity(0.12)))
    }

    private var chainPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Practice Patch").padding(8).background(Color.white.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 5))
                Image(systemName: "chevron.left"); Image(systemName: "chevron.right")
                Spacer()
                Label("136", systemImage: "metronome").foregroundStyle(gold)
                Image(systemName: "speaker.wave.2.fill").foregroundStyle(.gray)
                Text("10").foregroundStyle(gold)
                Image(systemName: "square.stack.3d.up").padding(.horizontal, 8)
                Image(systemName: "square.and.arrow.down")
            }.font(.caption)
            HStack(spacing: 8) {
                Text("❯").font(.title).foregroundStyle(.gray)
                ForEach([
                    EffectBlock(id: "DRV", color: .red), EffectBlock(id: "DYN", color: .cyan),
                    EffectBlock(id: "MOD", color: .gray, active: false), EffectBlock(id: "PRE AMP", color: .green),
                    EffectBlock(id: "AMP", color: .blue), EffectBlock(id: "CAB", color: gold)
                ]) { item in block(item) }
                Text("○").foregroundStyle(gold).font(.title)
            }
            Rectangle().fill(gold.opacity(0.4)).frame(height: 2).padding(.horizontal, 25)
            HStack(spacing: 12) {
                Text("+").font(.largeTitle).foregroundStyle(.gray).frame(width: 54, height: 58).overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                ForEach([EffectBlock(id: "DLY1", color: .pink), EffectBlock(id: "DLY2", color: .gray, active: false), EffectBlock(id: "RVB1", color: .gray, active: false), EffectBlock(id: "RVB2", color: .yellow), EffectBlock(id: "RVB3", color: .gray, active: false)]) { block($0) }
                Text("❯").font(.title).foregroundStyle(.gray)
            }
        }
        .padding(14).background(panel).overlay(Rectangle().stroke(Color.white.opacity(0.12)))
    }

    private func block(_ effect: EffectBlock) -> some View {
        VStack(spacing: 3) {
            Text(String(effect.id.prefix(3))).font(.system(size: 9, weight: .bold)).foregroundStyle(effect.active ? .white : .gray)
            Image(systemName: effect.id == "CAB" ? "speaker.wave.3" : "waveform.path").font(.title2).foregroundStyle(effect.active ? .white : .gray)
            Image(systemName: "power").font(.caption2).foregroundStyle(effect.color)
        }.frame(width: 58, height: 62).background(Color.black.opacity(0.45)).overlay(RoundedRectangle(cornerRadius: 5).stroke(effect.color, lineWidth: 2))
    }

    private var editorPanel: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(categories) { category in
                    Label(category.id, systemImage: category.symbol).font(.caption).foregroundStyle(category.id == "DRV" ? gold : .white)
                }
            }.frame(width: 105, alignment: .leading).padding(12)
            Divider()
            VStack(alignment: .leading, spacing: 7) {
                Text("All effects").font(.caption).foregroundStyle(.gray).padding(.bottom, 4)
                ForEach(effects, id: \.self) { effect in
                    Button { selectedEffect = effect } label: {
                        Text(effect).font(.caption).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 3)
                            .foregroundStyle(selectedEffect == effect ? gold : .white)
                    }.buttonStyle(.plain)
                }
            }.frame(width: 165, alignment: .leading).padding(12)
            Divider()
            VStack(spacing: 18) {
                HStack(spacing: 24) {
                    knob("Gain", value: $gain)
                    knob("Tone", value: $tone)
                    knob("Volume", value: $volume)
                }
                HStack(spacing: 28) {
                    Text("Mode  ·  OD").font(.caption).foregroundStyle(gold)
                    knob("HF Trim", value: .constant(0))
                }
            }.frame(maxWidth: .infinity).padding(18)
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "guitars").font(.largeTitle).foregroundStyle(gold)
                Text(selectedEffect).font(.caption).foregroundStyle(gold)
                Text("Effect description and parameter help will appear here.").font(.caption2).foregroundStyle(.gray)
                Spacer()
                Text("Preview UI · device editing is not connected yet").font(.caption2).foregroundStyle(.orange)
            }.frame(width: 150, alignment: .leading).padding(14)
        }
        .background(panel).overlay(Rectangle().stroke(Color.white.opacity(0.12)))
    }

    private func knob(_ title: String, value: Binding<Double>) -> some View {
        VStack(spacing: 7) {
            Text(title).font(.caption).foregroundStyle(.red)
            Slider(value: value, in: 0...100).tint(.red).frame(width: 130)
            Text("\(Int(value.wrappedValue))").font(.caption2).foregroundStyle(.red)
        }
    }
}
