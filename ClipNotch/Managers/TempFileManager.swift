//
//  TempFileManager.swift
//  ClipNotch
//
//  Created by Utsav Gautam on 29/08/25.
//


import Foundation

class TempFileManager {
    static let shared = TempFileManager()
    let tempFolder: URL
    
    private init() {
        // Create a unique folder for this app session
        let base = FileManager.default.temporaryDirectory
        tempFolder = base.appendingPathComponent("ClipNotchTemp_\(UUID().uuidString)")
        
        try? FileManager.default.createDirectory(at: tempFolder, 
                                                 withIntermediateDirectories: true, 
                                                 attributes: nil)
    }
    
    // Copy a file to temp
    func copyToTemp(fileURL: URL) -> URL? {
        let dest = tempFolder.appendingPathComponent(fileURL.lastPathComponent)
        do {
            try FileManager.default.copyItem(at: fileURL, to: dest)
            return dest
        } catch {
            print("Error copying file: \(error)")
            return nil
        }
    }
    
    // Move file back to original location (for Cut)
    func moveFileFromTemp(tempURL: URL, to destination: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: tempURL, to: destination)
            return true
        } catch {
            print("Error moving file: \(error)")
            return false
        }
    }
    
    // Clear temp folder if needed
    func clearTemp() {
        try? FileManager.default.removeItem(at: tempFolder)
    }
}
