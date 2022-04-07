//
//  ContentView.swift
//  PushGame
//
//  Created by Сердюков Евгений on 06.04.2022.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTime: Time = .sec5
    @State var cowIsAnimated = false

    var body: some View {
        VStack() {
            Image("classic-cow-1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: cowIsAnimated ? -80 : 0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(), value: cowIsAnimated)

            Text("Choose a time")
                .font(.title)

            Picker("Choose a time", selection: $selectedTime) {
                ForEach(Time.allCases, id: \.self) {
                    Text($0.textValue)
                }
            }.pickerStyle(.segmented)

            Button {
                PushController.registerPush(with: selectedTime)
            } label: {
                Text("Have a fun")
            }
            .buttonStyle(CapsuleButtonStyle())
            .padding(10)
        }
        .onAppear {
            cowIsAnimated = true
        }
        .padding(16)
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
