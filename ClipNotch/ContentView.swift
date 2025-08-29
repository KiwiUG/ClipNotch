//
//  ContentView.swift
//  ClipNotch
//
//  Created by Utsav Gautam on 28/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack(spacing: 40) {
            DropZoneView(title: "Copy Box")
            DropZoneView(title: "Cut Box")
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
    
}


#Preview {
    ContentView()
}
