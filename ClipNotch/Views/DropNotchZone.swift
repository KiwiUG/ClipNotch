//
//  DropNotchZone.swift
//  ClipNotch
//
//  Created by Utsav Gautam on 31/08/25.
//


import SwiftUI
import UniformTypeIdentifiers

struct DropNotchZone: View {
    @State private var isHovering = false

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack {
                ZStack {
                    // Glass blur background
                    VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(width: 280, height: 80)
                        .shadow(radius: 12)

                    Text("📂 Drop Files Here")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
                .offset(y: isHovering ? 30 : -120) // hidden above notch
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovering)

                Spacer()
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isHovering, perform: { items in
            for item in items {
                if item.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    item.loadFileRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { url, error in
                        if let url = url {
                            print("📂 Dropped file: \(url.path)")
                            
                            // 👉 Example: Save it into Documents/MyAppDrops
                            let targetFolder = FileManager.default
                                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                .appendingPathComponent("MyAppDrops", isDirectory: true)
                            
                            try? FileManager.default.createDirectory(
                                at: targetFolder,
                                withIntermediateDirectories: true
                            )
                            
                            let targetURL = targetFolder.appendingPathComponent(url.lastPathComponent)
                            
                            do {
                                // Copy dropped file into MyAppDrops
                                if FileManager.default.fileExists(atPath: targetURL.path) {
                                    try FileManager.default.removeItem(at: targetURL)
                                }
                                try FileManager.default.copyItem(at: url, to: targetURL)
                                print("✅ Saved to: \(targetURL.path)")
                            } catch {
                                print("❌ Error saving file: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            return true
        })


    }
}

#Preview {
    DropNotchZone()
}
