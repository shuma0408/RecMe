//
//  ScriptManager.swift
//  scriptCam
//
//  Created by Apple on 2026/01/24.
//

import Foundation
import Combine

class ScriptManager: ObservableObject {
    @Published var scripts: [Script] = []
    @Published var selectedScript: Script?
    
    private let scriptsKey = "saved_scripts"
    
    init() {
        loadScripts()
    }
    
    func addScript(_ script: Script) {
        scripts.append(script)
        saveScripts()
    }
    
    func updateScript(_ script: Script) {
        if let index = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[index] = script
            saveScripts()
        }
    }
    
    func deleteScript(_ script: Script) {
        scripts.removeAll { $0.id == script.id }
        if selectedScript?.id == script.id {
            selectedScript = nil
        }
        saveScripts()
    }
    
    func selectScript(_ script: Script) {
        selectedScript = script
    }
    
    private func saveScripts() {
        if let encoded = try? JSONEncoder().encode(scripts) {
            UserDefaults.standard.set(encoded, forKey: scriptsKey)
        }
    }
    
    private func loadScripts() {
        if let data = UserDefaults.standard.data(forKey: scriptsKey),
           let decoded = try? JSONDecoder().decode([Script].self, from: data) {
            scripts = decoded
        }
    }
}
