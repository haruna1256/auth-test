//
//  ContentView.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
               NavigationLink {
                LoginView()
            } label: {
                Text("next testAview")
            }
            
        }.task {
            do {
                print("fetch info")
                print(await try fetchInfo())
            } catch {
            }
        }
    }
}

#Preview {
    ContentView()
}

