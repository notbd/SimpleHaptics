//
//  ContentView.swift
//  SimpleHaptics
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - ContentView

/// Shows every SimpleHaptics feature. Each play button shows, in a monospaced font, the call that it makes.
struct ContentView: View {
  @AppStorage("hapticsEnabled") private var hapticsEnabled = true
  @State private var impact: SimpleHaptics.HapticType = .heavy
  @State private var intensity = 0.5
  @State private var segment = 0
  @State private var count = 0
  @State private var isLoaded = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Toggle(isOn: $hapticsEnabled) { Code("isEnabled") }
          LabeledContent {
            Code(String(SimpleHaptics.isSupported))
          } label: {
            Code("isSupported")
          }
        } footer: {
          Text(
            SimpleHaptics.isSupported
              ? "Turn off isEnabled, and every play button and modifier below stays silent."
              : "This device plays no haptics. Run the app on an iPhone to feel them.")
        }

        Section("Selection") {
          playButtons([.selection])
        }

        Section("Notification") {
          playButtons([.success, .warning, .error])
        }

        Section("Impact") {
          playButtons(SimpleHaptics.HapticType.impacts)
        }

        Section {
          Picker("Impact", selection: $impact) {
            ForEach(SimpleHaptics.HapticType.impacts, id: \.self) { type in
              Text(String(describing: type)).tag(type)
            }
          }
          .pickerStyle(.segmented)
          Slider(value: $intensity, in: 0 ... 1, step: 0.05) {
            Text("Intensity")
          }
          Button {
            SimpleHaptics.play(impact, intensity: intensity)
          } label: {
            // String(format:) ignores the locale, so the label stays valid Swift, such as 0.50 rather than 0,50.
            Code("play(.\(impact), intensity: \(String(format: "%.2f", intensity)))")
          }
        } header: {
          Text("Intensity")
        } footer: {
          Text("Intensity changes impact haptics only.")
        }

        Section {
          PrepareRow()
        } header: {
          Text("Prepare")
        } footer: {
          Text("Touching down calls prepare(.rigid). Lifting your finger calls play(.rigid).")
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
          Text("SwiftUI modifier")
        } footer: {
          Text(
            "The segments play .selection and the stepper plays .light. Finish loading plays .success. Reset plays "
              + "nothing, because the condition is false.")
        }
      }
      .navigationTitle("SimpleHaptics")
    }
    .onChange(of: hapticsEnabled, initial: true) {
      SimpleHaptics.isEnabled = hapticsEnabled
    }
  }

  // MARK: Private

  private func playButtons(_ types: [SimpleHaptics.HapticType]) -> some View {
    ForEach(types, id: \.self) { type in
      Button {
        SimpleHaptics.play(type)
      } label: {
        Code("play(.\(type))")
      }
    }
  }
}

// MARK: - Code

/// Text in a monospaced font, for API names and values.
private struct Code: View {
  let text: String

  init(_ text: String) {
    self.text = text
  }

  var body: some View {
    Text(text).font(.body.monospaced())
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

extension SimpleHaptics.HapticType {
  static fileprivate let impacts: [Self] = [.light, .medium, .heavy, .soft, .rigid]
}

#Preview {
  ContentView()
}
