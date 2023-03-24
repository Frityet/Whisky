//
//  BottleView.swift
//  Whisky
//
//  Created by Isaac Marovitz on 23/03/2023.
//

import SwiftUI

struct BottleView: View {
    @Binding var bottle: Bottle
    @State var wineVersion: String = ""
    @State var windowsVersion: WinVersion?
    @State var showBottleCreation: Bool = false
    @State var newBottleName: String = ""
    @State var newBottleVersion: WinVersion = .win7

    var body: some View {
        VStack {
            HStack {
                Toggle("DXVK", isOn: $bottle.dxvk)
                    .toggleStyle(.switch)
                Toggle("Winetricks", isOn: $bottle.winetricks)
                    .toggleStyle(.switch)
                Spacer()
            }
            Divider()
            HStack {
                Text("Path: \(bottle.path.path)")
                Spacer()
            }
            HStack {
                if wineVersion.isEmpty {
                    Text("Wine Version: ")
                    ProgressView()
                } else {
                    Text("Wine Version: ") + Text(wineVersion)
                }
                Spacer()
            }
            HStack {
                if let windowsVersion = windowsVersion {
                    Text("Windows Version: ") + Text(windowsVersion.pretty())
                } else {
                    Text("Windows Version: ")
                    ProgressView()
                }
                Spacer()
            }
            HStack {
                Button("Open Wine Configuration") {
                    Task(priority: .userInitiated) {
                        do {
                            try await Wine.cfg(bottle: bottle)
                        } catch {
                            print("Failed to launch winecfg")
                        }
                    }
                }
                Button("Open C Drive") {
                    bottle.openCDrive()
                }
                Spacer()
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showBottleCreation.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .padding()
        .navigationTitle(bottle.name)
        .onAppear {
            Task(priority: .background) {
                do {
                    try await wineVersion = Wine.wineVersion()
                } catch {
                    wineVersion = "Failed"
                }
            }

            Task(priority: .background) {
                do {
                    try await windowsVersion = Wine.winVersion()
                } catch {
                    print("Failed")
                }
            }
        }
        .sheet(isPresented: $showBottleCreation) {
            VStack {
                HStack {
                    Text("Create a new bottle")
                        .bold()
                    Spacer()
                }
                Divider()
                HStack {
                    Text("Bottle Name:")
                    TextField("", text: $newBottleName)
                    Spacer()
                }
                HStack {
                    Picker("Windows Version:", selection: $newBottleVersion) {
                        ForEach(WinVersion.allCases, id: \.self) {
                            Text($0.pretty())
                        }
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button("Create") {
                        BottleVM.shared.createNewBottle(bottleName: newBottleName,
                        winVersion: newBottleVersion)
                        showBottleCreation.toggle()
                    }
                }
            }
            .padding()
            .frame(width: 350, height: 200)
        }
    }
}

struct BottleView_Previews: PreviewProvider {
    static var previews: some View {
        let bottle = Bottle()

        BottleView(bottle: .constant(bottle))
            .frame(width: 500, height: 300)
    }
}
