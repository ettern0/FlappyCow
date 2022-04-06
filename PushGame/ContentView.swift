//
//  ContentView.swift
//  PushGame
//
//  Created by Сердюков Евгений on 06.04.2022.
//

import SwiftUI

struct ContentView: View {
    enum Schedule: CaseIterable {
        case sec5
        case min1
        case min5
        case random

        var textValue: String {
            switch self {
            case .sec5:
                return "5 sec."
            case .min1:
                return "1 min."
            case .min5:
                return "5 min."
            case .random:
                return "Random"
            }
        }
    }

    @State var selectedSchedule: Schedule = .sec5
    @State var cowIsAnimated = false

    var body: some View {
        VStack() {
            Image("classic-cow-1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: cowIsAnimated ? -100 : 0)
                .animation(Animation.linear(duration: 1).repeatForever(), value: cowIsAnimated)
            Text("Choose a time")
                .font(.title)
            Picker("Choose a time", selection: $selectedSchedule) {
                ForEach(Schedule.allCases, id: \.self) {
                    Text($0.textValue)
                }
            }.pickerStyle(.segmented)
            PushButton(labelText: "Have a fun")
                .padding(10)
        }
        .onAppear {
            cowIsAnimated = true
        }
        .padding(16)
    }

    private struct PushButton: View {
        let labelText: String
        var body: some View {
            Button {

            } label: {
                Text(labelText)
            }
            .buttonStyle(CapsuleButtonStyle())
        }
    }

}

private struct CapsuleButtonStyle: ButtonStyle {
    var active: Bool = true
    var capsuleFillColor: Color {
        return active ? .blue: Color(.blue).opacity(0.8)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 32))
            .foregroundColor(Color(.white).opacity(configuration.isPressed ? 0.7 : 1))
            .padding(.vertical, 6)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(capsuleFillColor)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
