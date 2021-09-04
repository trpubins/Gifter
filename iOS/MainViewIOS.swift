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
    
    /// An array of dictionaries holding data relevant to the MainViews
    let mainViewTabs: [MainViewData]
    
    var body: some View {

        TabView(selection: .init(
            get: { triggers.selectedTab },
            set: { triggers.selectedTab = $0 }
        )) {
            
            ForEach(mainViewTabs, id: \.labelText) { tab in
                getTabView(tabData: tab)
                    .tabItem { Label(tab.labelText, systemImage: getLabelImg(tabData: tab)) }
                    .tag(tab.tabNum)
            }

        }
        .onAppear{ logAppear(title: "MainViewIOS") }
        // add gift exchange sheet
        .sheet(isPresented: .init(
            get: { triggers.isAddGiftExchangeFormShowing },
            set: { triggers.isAddGiftExchangeFormShowing = $0 }
        )) {
            getGiftExchangeFormView(formType: FormType.Add)
            
        }
        // edit gift exchange sheet
        .sheet(isPresented: .init(
            get: { triggers.isEditGiftExchangeFormShowing },
            set: { triggers.isEditGiftExchangeFormShowing = $0 }
        )) {
            getGiftExchangeFormView(formType: FormType.Edit)
        }
        // add gifter sheet
        .sheet(isPresented: .init(
            get: { triggers.isAddGifterFormShowing },
            set: { triggers.isAddGifterFormShowing = $0 }
        )) {
            getGifterFormView(formType: FormType.Add)
        }
        // delete gift exchange alert
        .alert(isPresented: .init(
            get: { triggers.isDeleteGiftExchangeAlertShowing },
            set: { triggers.isDeleteGiftExchangeAlertShowing = $0 }
        )) {
            Alerts.giftExchangeDeleteAlert(giftExchange: selectedGiftExchange, giftExchangeSettings: giftExchangeSettings)
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
        if (self.triggers.selectedTab == tabData.tabNum) {
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
                            Button(action: { addGifter() }) {
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
     Returns a GiftExchangeFormView that is configured with the provided formType.
     
     - Parameters:
        - formType: Describes the type of form to generate
     
     - Returns: A configured GiftExchangeFormView.
     */
    func getGiftExchangeFormView(formType: FormType) -> some View {
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
    
    /**
     Returns a GifterFormView that is configured with the provided formType.
     
     - Parameters:
        - formType: Describes the type of form to generate
     
     - Returns: A configured GifterFormView.
     */
    func getGifterFormView(formType: FormType) -> some View {
        NavigationView {
            if formType == .Add {
                GifterFormView(formType: FormType.Add)
            }
        }
    }
    
    /// Triggers a sheet for adding a new gifter and changes the tab selection to the Gifters Tab.
    func addGifter() {
        logFilter("add gifter")
        triggers.isAddGifterFormShowing = true
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
