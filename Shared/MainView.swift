//
//  MainView.swift
//  Shared (View)
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI

/// The primary view for the application -- uses a tab view as the means of navigation.
/// We track the selected tab and use it to change the system images for each tab.
struct MainView: View {
    /// A state variable to capture the current tab selection
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            navView(dest: ExchangeTabView(), tabNum: 1, labelText: "Gift Exchange", imgName: "gift")
            
            navView(dest: GiftersTabView(), tabNum: 2, labelText: "Gifters", imgName: "person.2")
            
            navView(dest: PreferencesTabView(), tabNum: 3, labelText: "Preferences", imgName: "gearshape")
            
        }
    }
    
    /**
     Generates a NavigationView that depends on the selected tab and the specified properties.
     
     This function keeps our MainView source code DRY. In particular, it saves us from having several
     conditionals in the MainView body property to only slightly change the systemImage from generic to
     'filled' when a tab is selected.
     
     - Parameters:
        - dest: The destination view, which the generated NavigationView links to
        - tabNum: The tab number -- used for the NavigationView's tag property
        - labelText: The tab label's text content
        - imgName: The tab label's generic system image name
     
     - Returns: A NavigationView where the specified tab's image is 'filled' when it is selected.
     */
    func navView<T: View>(dest: T, tabNum: Int, labelText: String, imgName: String) -> some View {
        var labelImg: String
        
        // opt for 'filled' image when the tab is selected
        if (selectedTab == tabNum) {
            labelImg = imgName + ".fill"
        } else {
            labelImg = imgName
        }
        
        return {
            NavigationView { dest }
                .tabItem { Label(labelText, systemImage: labelImg) }
                .tag(tabNum)
        }()
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
