//
//  MainView.swift
//  iOS (View)
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI

/// The primary view for the iOS application -- uses a tab view as the means of navigation.
/// We track the selected tab and use it to change the system images for each tab.
struct MainViewIOS: View {
    
    /// A state variable to capture the current tab selection
    @State private var selectedTab = 1
    
    /// An array of dictionaries holding data relevant to the MainViews
    let mainViewTabs: [MainViewData]
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            ForEach(mainViewTabs, id: \.labelText) { tab in
                getView(tabData: tab)
            }

        }
        .accentColor(.red)
        .onAppear{ logAppear(title: "MainViewIOS") }
        
    }
    
    /**
     Generates a View that depends on the selected tab and the specified properties.
     
     This function keeps our MainViewIOS source code DRY. In particular, it saves us from having several
     conditionals in the MainViewIOS body property to only slightly change the systemImage from generic to
     'filled' when a tab is selected.
     
     - Parameters:
        - tabData: The data associated with a main view tab
     
     - Returns: A View where the specified tab's image is 'filled' when it is selected.
     */
    func getView(tabData: MainViewData) -> some View {
        var labelImg: String
        
        // opt for 'filled' image when the tab is selected
        if (selectedTab == tabData.tabNum) {
            labelImg = tabData.imgName + ".fill"
        } else {
            labelImg = tabData.imgName
        }
        
        return {
             tabData.dest
                .tabItem { Label(tabData.labelText, systemImage: labelImg) }
                .tag(tabData.tabNum)
        }()
    }
    
}

#if os(iOS)
struct MainViewIOS_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()

    static var previews: some View {
        MainViewIOS(mainViewTabs: getMainViewData(previewUserSettings))
            .environmentObject(previewUserSettings)
    }
    
}
#endif
