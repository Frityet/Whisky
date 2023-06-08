//
//  BottleSettings.swift
//  Whisky
//
//  Created by Isaac Marovitz on 31/03/2023.
//

import Foundation

struct BottleSettingsData: Codable {
    var wineVersion: String = "7.7"
    var windowsVersion: WinVersion = .win10
    var metalHud: Bool = false
    var metalTrace: Bool = false
    var esync: Bool = false
}

class BottleSettings {
    var settings: BottleSettingsData {
        didSet {
            encode()
        }
    }

    var wineVersion: String {
        get {
            return settings.wineVersion
        }
        set {
            settings.wineVersion = newValue
        }
    }

    var windowsVersion: WinVersion {
        get {
            return settings.windowsVersion
        }
        set {
            settings.windowsVersion = newValue
        }
    }

    var metalHud: Bool {
        get {
            return settings.metalHud
        }
        set {
            settings.metalHud = newValue
        }
    }

    var metalTrace: Bool {
        get {
            return settings.metalTrace
        }
        set {
            settings.metalTrace = newValue
        }
    }

    var esync: Bool {
        get {
            return settings.esync
        }
        set {
            settings.esync = newValue
        }
    }

    let settingsUrl: URL

    init(bottleUrl: URL, name: String) {
        self.settingsUrl = bottleUrl.appendingPathComponent(name)
                                    .appendingPathExtension("plist")

        settings = BottleSettingsData()
        if !decode() {
            encode()
        }
    }

    @discardableResult
    public func decode() -> Bool {
        do {
            let data = try Data(contentsOf: settingsUrl)
            settings = try PropertyListDecoder().decode(BottleSettingsData.self, from: data)
            if settings.wineVersion != BottleSettingsData().wineVersion {
                print("Bottle has a different wine version!")
                settings.wineVersion = BottleSettingsData().wineVersion
            }
            return true
        } catch {
            print(error)
            return false
        }
    }

    @discardableResult
    public func encode() -> Bool {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(settings)
            try data.write(to: settingsUrl)
            return true
        } catch {
            print(error)
            return false
        }
    }

    func environmentVariables(environment: inout [String: String]) {
        if esync {
            environment.updateValue("1", forKey: "WINEESYNC")
        }

        if metalHud {
            environment.updateValue("1", forKey: "MTL_HUD_ENABLED")
        }

        if metalTrace {
            environment.updateValue("1", forKey: "METAL_CAPTURE_ENABLED")
            // Might not be needed
            environment.updateValue("2", forKey: "MVK_CONFIG_AUTO_GPU_CAPTURE_SCOPE")
        }
    }
}
