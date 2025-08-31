import SwiftUI

struct DropZoneView: View {
    let title: String
    @State private var files: [URL] = []
    @State private var isHovering = false
    @State private var showConfirmation = false
    @State private var showConfirmPaste = false
    @State private var pendingFiles: [URL] = [] // Files waiting for confirmation
    @State private var pasteDestination: URL! = nil


    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isHovering ? Color.blue : Color.gray.opacity(0.5),
                                  style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(20)
                    .frame(width: 220, height: 220)
                    .onDrop(of: ["public.file-url"], isTargeted: $isHovering) { providers in
                        handleDrop(providers: providers)
                        return true
                    }

                VStack(spacing: -20) {
                    ForEach(files, id: \.self) { file in
                        HStack {
                            Image(systemName: "doc.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            Text(file.lastPathComponent)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.8))
                                        .shadow(radius: 2))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .onDrag {
                // Stage files for confirmation (so Confirm Paste button appears)
                DispatchQueue.main.async {
                    if let firstFile = files.first {
                        stageFilesForPaste(filesToStage: files, destination: firstFile.deletingLastPathComponent())
                    }
                }

                // NSItemProvider needs one URL to start the drag
                return NSItemProvider(contentsOf: files.first!)!
            }



        }
        .animation(.spring(), value: files)
        
        if showConfirmPaste {
            Button("Confirm Paste") {
                for tempFile in pendingFiles {
                    let destURL = pasteDestination.appendingPathComponent(tempFile.lastPathComponent)
                    try? FileManager.default.copyItem(at: tempFile, to: destURL)
                }
                files.removeAll()
                pendingFiles.removeAll()
                showConfirmPaste = false
                showConfirmation = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showConfirmation = false
                }
            }
            .padding(.top, 10)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil),
                       let tempURL = TempFileManager.shared.copyToTemp(fileURL: url) {
                        files.append(tempURL)
                    }
                }
            }
        }
    }

    private func tempFilesForDrag() -> URL {
        // For simplicity, if multiple files, create a temporary folder and return its URL
        let dragFolder = TempFileManager.shared.tempFolder.appendingPathComponent("DragTemp_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dragFolder, withIntermediateDirectories: true)
        
        for file in files {
            let dest = dragFolder.appendingPathComponent(file.lastPathComponent)
            try? FileManager.default.copyItem(at: file, to: dest)
        }
        return dragFolder
        
        
    }
    
    private func pasteFiles() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let destination = panel.url {
            pendingFiles = files // Copy files into pending
            pasteDestination = destination
            showConfirmPaste = true // Show confirm button
        }
    }
    
    private func stageFilesForPaste(filesToStage: [URL], destination: URL) {
        pendingFiles = filesToStage   // keep original file URLs
        pasteDestination = destination
        showConfirmPaste = true
    }
    
}
