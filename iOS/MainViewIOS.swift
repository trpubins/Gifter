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
    
    /// Object encapsulating various state variables provided by a parent View
    @EnvironmentObject var triggers: StateTriggers
    
    /// A state variable to capture the current tab selection
    @State private var selectedTab = 1
    
    /// An array of dictionaries holding data relevant to the MainViews
    let mainViewTabs: [MainViewData]
    
    var body: some View {
        
        // For reference:
        //  tab 1 = Exchange Tab
        //  tab 2 = Gifters Tab
        //  tab 3 = Preferences Tab
        TabView(selection: $selectedTab) {
            
            ForEach(mainViewTabs, id: \.labelText) { tab in
                getTabView(tabData: tab)
                    .tabItem { Label(tab.labelText, systemImage: getLabelImg(tabData: tab)) }
                    .tag(tab.tabNum)
            }

        }
        .onAppear{ logAppear(title: "MainViewIOS") }
        .sheet(isPresented: .init(
            get: { triggers.isAddGiftExchangeFormShowing },
            set: { triggers.isAddGiftExchangeFormShowing = $0 }
               )) {
                   getFormView(formType: FormType.Add)
        }
        .sheet(isPresented: .init(
                get: { triggers.isEditGiftExchangeFormShowing },
                set: { triggers.isEditGiftExchangeFormShowing = $0 }
               )) {
                   getFormView(formType: FormType.Edit)
        }
        .alert(isPresented: .init(
                get: { triggers.isDeleteGiftExchangeAlertShowing },
                set: { triggers.isDeleteGiftExchangeAlertShowing = $0 }
               )) {
                   DeleteAlert.giftExchangeAlert(selectedGiftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings)
               }
    }
    
    /**
     Returns a 'filled' image name when the provided tab is the selected tab. In iOS 15, tab label images are always filled whether
     or not the filled version is specified.
     
     This function keeps our MainViewIOS source code DRY. In particular, it saves us from having several
     conditionals in the MainViewIOS body property to only slightly change the systemImage from generic to
     'filled' when a tab is selected.
     
     - Parameters:
        - tabData: The data associated with a main view tab
     
     - Returns: The system image name, generic or 'filled' version based on the tab selection.

     */
    func getLabelImg(tabData: MainViewData) -> String {
        // opt for 'filled' image when the tab is selected
        if (self.selectedTab == tabData.tabNum) {
            return tabData.imgName + ".fill"
        } else {
            return tabData.imgName
        }
    }
    
    /**
     Generates a NavigationView with the specified tab data. The NavigationView also holds a toolbar menu.
     
     - Parameters:
        - tabData: The data associated with a main view tab
     
     - Returns: A NavigationView that includes an interactive Menu in the toolbar.
     */
    func getTabView(tabData: MainViewData) -> some View {
        return {
            NavigationView {
                tabData.dest
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { logFilter("add gifter") }) {
                                Image(systemName: "person.badge.plus")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { logFilter("email gifters") }) {
                                Image(systemName: "envelope")
                            }
                            // MARK: TODO
                            // need to change this condition to be based on gift exchange
                            // matching Bool
                            .disabled(true)
                        }
                        ToolbarItem(placement: .principal) {
                            ToolbarMenuView(unselectedIds: giftExchangeSettings.unselectedIdList)
                                .environmentObject(giftExchangeSettings)
                                .environmentObject(selectedGiftExchange)
                                .environmentObject(triggers)
                        }
                    }
                    .environmentObject(selectedGiftExchange)
            }
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
                GiftExchangeFormView(
                    formType: FormType.Edit,
                    data: GiftExchangeFormData(giftExchange: selectedGiftExchange)
                )
            }
        }
    }
    
}

#if os(iOS)
struct MainViewIOS_Previews: PreviewProvider {
    
    static let previewUserSettings: UserSettings = getPreviewUserSettings()
    static let previewGiftExchange: GiftExchange = GiftExchange(context: PersistenceController.shared.context)
    static let previewTriggers: StateTriggers = StateTriggers()
    
    static var previews: some View {
        MainViewIOS(mainViewTabs: getMainViewData())
            .environmentObject(previewUserSettings)
            .environmentObject(previewGiftExchange)
            .environmentObject(previewTriggers)
    }
    
}
#endif
