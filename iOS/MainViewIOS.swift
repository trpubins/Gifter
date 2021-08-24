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
    
    /// The gift exchange user settings provided by a parent View
    @EnvironmentObject var giftExchangeSettings: UserSettings
    
    /// The gift exchange current selection provided by a parent View
    @EnvironmentObject var selectedGiftExchange: GiftExchange
    
    /// Local state to trigger a sheet for adding a new gift exchange
    @Binding var isAddGiftExchangeFormShowing: Bool
    
    /// Local state to trigger a sheet for editing an existing gift exchange
    @Binding var isEditGiftExchangeFormShowing: Bool
    
    /// A state variable to capture the current tab selection
    @State private var selectedTab = 1
    
    /// An array of dictionaries holding data relevant to the MainViews
    let mainViewTabs: [MainViewData]
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            ForEach(mainViewTabs, id: \.labelText) { tab in
                getTabView(tabData: tab)
                    .sheet(isPresented: $isAddGiftExchangeFormShowing) {
                        getFormView(formType: FormType.Add)
                    }
                    .sheet(isPresented: $isEditGiftExchangeFormShowing) {
                        getFormView(formType: FormType.Edit)
                    }
            }

        }
        .onAppear{ logAppear(title: "MainViewIOS") }
        
    }
    
    /**
     Generates a NavigationView that depends on the selected tab and the specified properties. The NavigationView also holds a toolbar menu.
     
     This function keeps our MainViewIOS source code DRY. In particular, it saves us from having several
     conditionals in the MainViewIOS body property to only slightly change the systemImage from generic to
     'filled' when a tab is selected.
     
     - Parameters:
        - tabData: The data associated with a main view tab
     
     - Returns: A NavigationView where the specified tab's image is 'filled' when it is selected. The view also includes an interactive Menu in the toolbar.
     */
    func getTabView(tabData: MainViewData) -> some View {
        var labelImg: String
        
        // opt for 'filled' image when the tab is selected
        if (selectedTab == tabData.tabNum) {
            labelImg = tabData.imgName + ".fill"
        } else {
            labelImg = tabData.imgName
        }
        
        return {
            NavigationView {
                tabData.dest
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            ToolbarMenuView(
                                isAddGiftExchangeFormShowing: $isAddGiftExchangeFormShowing,
                                isEditGiftExchangeFormShowing: $isEditGiftExchangeFormShowing
                            )
                                .environmentObject(giftExchangeSettings)
                                .environmentObject(selectedGiftExchange)
                        }
                    }
                    .environmentObject(selectedGiftExchange)
            }
            .tabItem { Label(tabData.labelText, systemImage: labelImg) }
            .tag(tabData.tabNum)
        }()
    }
    
    /**
     Returns a form view that is configured with the provided formType.
     
     - Parameters:
     - formType: Describes the type of form to generate
     
     - Returns: A configured GiftExchangeFormView.
     */
    func getFormView(formType: FormType) -> some View {
        NavigationView {
            if formType == .Add {
                GiftExchangeFormView(formType: FormType.Add)
            } else if formType == .Edit {
                GiftExchangeFormView(formType: FormType.Edit, data: GiftExchangeFormData(giftExchange: selectedGiftExchange))
            }
        }
    }
    
}

#if os(iOS)
struct MainViewIOS_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    
    static var previews: some View {
        PreviewWrapper()
    }
    
    // we create a wrapper around the preview to pass @Binding objects
    struct PreviewWrapper: View {
        @State(initialValue: false) var isAddFormShowing: Bool
        @State(initialValue: false) var isEditFormShowing: Bool
        
        var body: some View {
            MainViewIOS(
                isAddGiftExchangeFormShowing: $isAddFormShowing,
                isEditGiftExchangeFormShowing: $isEditFormShowing,
                mainViewTabs: getMainViewData()
            )
                .environmentObject(previewUserSettings)
                .environmentObject(previewGiftExchange)
        }
    }
    
}
#endif
