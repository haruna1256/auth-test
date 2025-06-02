//
//  ContentView.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationView {
                //            loginページに飛ばす
                LoginView()
            }
            
        }
    }
}

#Preview {
    ContentView()
}

