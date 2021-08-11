//
//  MainView_macOS.swift
//  macOS (View)
//  https://thehappyprogrammer.com/detect-os-in-swiftui/
//
//  Created by Tanner on 8/10/21.
//

import SwiftUI

/// The primary view for the macOS application -- uses a sidebar list view as the means of navigation.
struct MainViewMacOS: View {

    var body: some View {
        
        NavigationView {
            
            List(mainViewTabs, id: \.labelText) { tab in
                NavigationLink(destination: tab.dest) {
                    Label(tab.labelText, systemImage: "\(tab.imgName).fill")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 150)
            
        }
        .navigationTitle("Gifter")
        .frame(minWidth: 600, maxWidth: 800, minHeight: 300, maxHeight: 500)
        
    }
    
}

#if os(macOS)
struct MainViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        let giftExchangeSettings = UserSettings()
        
        MainViewMacOS()
            .environmentObject(giftExchangeSettings)
    }
}
#endif
