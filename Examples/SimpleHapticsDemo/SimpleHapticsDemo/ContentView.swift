//
//  ContentView.swift
//  SimpleHaptics
//
//  Copyright (c) 2026 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - ContentView

/// Plays every haptic type and shows each SimpleHaptics feature. Run it on an iPhone: Simulator plays
/// nothing.
struct ContentView: View {
  @AppStorage("hapticsEnabled") private var hapticsEnabled = true
  @State private var usesCustomIntensity = false
  @State private var intensity = 0.5
  @State private var segment = 0
  @State private var count = 0
  @State private var isLoaded = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Toggle("Haptics", isOn: $hapticsEnabled)
          LabeledContent("Device supports haptics", value: SimpleHaptics.isSupported ? "Yes" : "No")
        } footer: {
          Text("Turn off Haptics to check that every button and modifier below stays silent.")
        }

        Section("Notification") {
          playButton(.success)
          playButton(.warning)
          playButton(.error)
        }

        Section("Selection") {
          playButton(.selection)
        }

        Section {
          playButton(.light)
          playButton(.medium)
          playButton(.heavy)
          playButton(.soft)
          playButton(.rigid)
          Toggle("Custom intensity", isOn: $usesCustomIntensity)
          if usesCustomIntensity {
            LabeledContent("Intensity \(intensity, format: .number.precision(.fractionLength(2)))") {
              Slider(value: $intensity, in: 0 ... 1)
            }
          }
        } header: {
          Text("Impact")
        } footer: {
          Text("Custom intensity changes the impact buttons only.")
        }

        Section {
          PrepareRow()
        } header: {
          Text("Prepare")
        } footer: {
          Text("Touching down calls prepare(.rigid). Lifting your finger plays .rigid.")
        }

        Section {
          Picker("Segment", selection: $segment) {
            Text("One").tag(0)
            Text("Two").tag(1)
            Text("Three").tag(2)
          }
          .pickerStyle(.segmented)
          .haptic(.selection, trigger: segment)

          Stepper("Count: \(count)", value: $count)
            .haptic(.light, trigger: count)

          Button(isLoaded ? "Reset" : "Finish loading") {
            isLoaded.toggle()
          }
          .haptic(.success, trigger: isLoaded) { _, newValue in
            newValue
          }
        } header: {
          Text(".haptic(_:trigger:) modifier")
        } footer: {
          Text("Finish loading plays .success. Reset plays nothing, because the condition is false.")
        }
      }
      .navigationTitle("SimpleHaptics")
    }
    .onAppear {
      SimpleHaptics.isEnabled = hapticsEnabled
    }
    .onChange(of: hapticsEnabled) { _, isOn in
      SimpleHaptics.isEnabled = isOn
    }
  }

  // MARK: Private

  private func playButton(_ type: SimpleHaptics.HapticType) -> some View {
    Button(".\(String(describing: type))") {
      if usesCustomIntensity {
        SimpleHaptics.play(type, intensity: intensity)
      }
      else {
        SimpleHaptics.play(type)
      }
    }
  }
}

// MARK: - PrepareRow

/// Prepares the haptic hardware on touch down and plays on touch up.
private struct PrepareRow: View {
  @State private var isPressing = false

  var body: some View {
    Text(isPressing ? "Release to play" : "Press and hold")
      .frame(maxWidth: .infinity, minHeight: 44)
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            guard !isPressing else { return }
            isPressing = true
            SimpleHaptics.prepare(.rigid)
          }
          .onEnded { _ in
            isPressing = false
            SimpleHaptics.play(.rigid)
          })
  }
}

#Preview {
  ContentView()
}
