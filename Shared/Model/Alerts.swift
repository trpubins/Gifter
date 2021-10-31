//
//  Alerts.swift
//  Shared (Model)
//
//  Created by Tanner on 8/27/21.
//

import SwiftUI


/**
 An enumeration for describing alert information.
 
 Enumerations include: .GiftExchangeCompleted, .GiftExchangeMatching, .DeleteGiftExchange, .DeleteGifter,
 .AddGifterInvalidatesMatching, .DeleteGifterInvalidatesMatching, & .OtherGifterChanges
 */
enum AlertType {
    case GiftExchangeCompleted
    case GiftExchangeMatching
    case DeleteGiftExchange
    case DeleteGifter
    case AddGifterInvalidatesMatching
    case DeleteGifterInvalidatesMatching
    case OtherGifterChanges
}


/// An identifiable item that captures alert information.
struct AlertInfo: Identifiable {
    
    /// The alert type serving as the structure's unique id
    let id: AlertType
    
    /// A fully assembled alert
    let alert: Alert
}


/// A struct that supports building alerts.
struct Alerts {

    
    // MARK: Static Functions
    
    /**
     Generates an alert and subsequent action if the specified gift exchange has finished.
     
     - Parameters:
        - completedGiftExchange: The gift exchange that has completed
     
     - Returns: A populated alert that updates the provided gift exchange to the same date for the upcoming year.
     */
    static func giftExchangeCompletedAlert(_ completedGiftExchange: GiftExchange) -> Alert {
        return Alert(
            title: Text("Gift exchange completed!"),
            message: Text("The gift exchange date will remain the same for the upcoming year"),
            dismissButton: .cancel(Text("OK")) {
                logFilter("updated gift exchange year")
                completedGiftExchange.updateNextYear()
                PersistenceController.shared.saveContext()
            }
        )
    }
    
    /**
     Generates an alert based on if the specified gift exchange matching was successful or not.
     
     - Parameters:
        - matchingSuccess: `true` if the gift exchange matching was successful, `false` otherwise
     
     - Returns: A populated alert that makes a statement or recommendation to the user based on the matching outcome.
     */
    static func giftExchangeMatchingAlert(matchingSuccess: Bool) -> Alert {
        if matchingSuccess {
            return Alert(
                title: Text("Successfully matched gifters!"),
                message: Text("Send emails to notify all the participants who they are gifting"),
                dismissButton: .cancel(Text("OK")) {
                    logFilter("alerting user that matching successful")
                }
            )
        } else {
            return Alert(
                title: Text("Failed to match gifters!"),
                message: Text("Recommend easing restrictions to support gifters matching"),
                dismissButton: .cancel(Text("OK")) {
                    logFilter("alerting user that matching unsuccessful")
                }
            )
        }
    }
    
    /**
     Generates an alert and subsequent action if the user intends to delete the selected gift exchange.
     
     - Parameters:
        - giftExchange: The gift exchange to be deleted
        - giftExchangeSettings: The gift exchange user settings
        - mode: The presentation mode binding to indicate whether a view is currently presented by another view; nil by default
     
     - Returns: A populated alert that deletes the selected gift exchange if the user presses the Delete button.
     */
    static func giftExchangeDeleteAlert(giftExchange: GiftExchange, giftExchangeSettings: UserSettings, mode: Binding<PresentationMode>? = nil) -> Alert {
        return Alert(
            title: Text("Are you sure you want to delete this gift exchange?"),
            message: Text("This action cannot be undone"),
            primaryButton: .destructive(Text("Delete")) {
                
                logFilter("deleted gift exchange \(giftExchange.toString())...")
                
                // first, delete the object from CoreData
                GiftExchange.delete(giftExchange)
                
                // second, remove the gift exchange id from the user config data
                giftExchangeSettings.removeSelectedGiftExchangeId()
                
                // dismiss the view if a presentation mode was provided
                guard let presentationMode = mode else {
                    return
                }
                presentationMode.wrappedValue.dismiss()
                
            },
            secondaryButton: .cancel() {
                logFilter("cancelled deleting gift exchange")
            }
        )
    }

    /**
     Generates an alert and subsequent action if the user intends to delete the specified gifter.
     
     - Parameters:
        - gifter: The gifter to be deleted
        - selectedGiftExchange: The gift exchange current selection
        - alertController: For sending alert information at the app level, as necessary
        - mode: The presentation mode binding to indicate whether a view is currently presented by another view; nil by default
     
     - Returns: A populated alert that deletes the specified gifter if the user presses the Delete button.
     */
    static func gifterDeleteAlert(
        gifter: Gifter,
        selectedGiftExchange: GiftExchange,
        alertController: AlertController,
        mode: Binding<PresentationMode>? = nil) -> Alert {
        
            // copy some variables locally before the data is potentially altered
            let gifterId = gifter.id
            let areGiftersMatched = selectedGiftExchange.areGiftersMatched
                        
            return Alert(
                title: Text("Are you sure you want to delete this gifter?"),
                message: Text("This action cannot be undone"),
                primaryButton: .destructive(Text("Delete")) {
                    
                    logFilter("deleting gifter \(gifter.name)...")
                                        
                    // first, delete the object from CoreData
                    Gifter.delete(gifter: gifter, selectedGiftExchange: selectedGiftExchange)
                    
                    // an array of gifters whose restrictions have been cleared
                    var giftersWithRestrictionsCleared: [Gifter] = []
                    
                    // then, clean up any connections to the deleted gifter
                    let otherGifters = selectedGiftExchange.gifters.filter( {$0.id != gifterId} )
                    for otherGifter in otherGifters {
                        // check if the deleted gifter is someone else's previous recipient
                        if otherGifter.previousRecipientId == gifterId {
                            otherGifter.previousRecipientId = nil
                        }
                        
                        // check if the deleted gifter is somone else's current recipient
                        if otherGifter.recipientId == gifterId {
                            otherGifter.recipientId = nil
                        }
                        
                        // filter out the gifter from the array of restricted ids
                        otherGifter.restrictedIds = otherGifter.restrictedIds.filter( {$0 != gifterId} )
                        
                        // check if deleting gifter invalidates restrictions on the other gifters
                        if otherGifter.restrictedIds.count >= (otherGifters.count - 1) {
                            // this otherGifter has too many restrictions so need to clear their restrictions
                            otherGifter.restrictedIds = []
                            giftersWithRestrictionsCleared.append(otherGifter)
                        }
                    }
                    
                    // save the app state
                    PersistenceController.shared.saveContext()
                    
                    // dismiss the view if a presentation mode was provided
                    if let presentationMode = mode {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    // NOTE: if both conditions below evaluate to true, then only
                    // the second Alert will be shown to the user
                    
                    // alert the user if deleting the specified gifter
                    // invalidated the gift exchange matching
                    if areGiftersMatched {
                        alertController.info = AlertInfo(
                            id: .DeleteGifterInvalidatesMatching,
                            alert: Alerts.matchingInvalidatedAlert(.DeleteGifterInvalidatesMatching)
                        )
                    }
                    
                    // alert the user if deleting the specified gifter
                    // caused changes to the other remaining gifters
                    if giftersWithRestrictionsCleared.count > 0 {
                        alertController.info = AlertInfo(
                            id: .OtherGifterChanges,
                            alert: Alerts.otherGifterChangesAlert(giftersWithRestrictionsCleared)
                        )
                    }
                    
                },
                secondaryButton: .cancel() {
                    logFilter("cancelled deleting gifter")
                }
            )  // end Alert
            
    }

    /**
     Generates an alert to inform the user that gift exchange matching has been invalidated.
     
     - Parameters:
        - alertType: Describes the type of alert
     
     - Returns: A populated alert that informs the user of what caused matching to be invalidated.
     */
    static func matchingInvalidatedAlert(_ alertType: AlertType) -> Alert {
        assert(alertType == .AddGifterInvalidatesMatching ||
               alertType == .DeleteGifterInvalidatesMatching)
        
        // build a string to specify what caused the matching to become invalid
        var invalidationCause = ""
        if alertType == .AddGifterInvalidatesMatching {
            invalidationCause = "Adding"
        } else if alertType == .DeleteGifterInvalidatesMatching {
            invalidationCause = "Deleting"
        }
        
        return Alert(
            title: Text("Matching is invalid!"),
            message: Text("\(invalidationCause) a gifter has invalidated the current gift exchange matching. " +
                         "Please match the new group of gifters."),
            dismissButton: .cancel(Text("OK")) {
                logFilter("alerting user that matching has been invalidated due to \(invalidationCause.lowercased()) a gifter")
            }
        )
    }
    
    /**
     Generates an alert to inform the user of changes made to the gifter data.
     
     - Parameters:
        - giftersWithRestrictionsCleared: An array of gifters whose restrictions have been cleared
     
     - Returns: A populated alert that informs the user of those gifters affected by the changes.
     */
    static func otherGifterChangesAlert(_ giftersWithRestrictionsCleared: [Gifter]) -> Alert {
        // build a string with the name(s) of the affected gifters
        let delimiter = ", "
        var names = ""
        for gifter in giftersWithRestrictionsCleared {
            names += gifter.name + delimiter
        }
        // drop the final delimiter substring
        names = String(names.dropLast(delimiter.count))
        
        return Alert(
            title: Text("Gifter data has been changed"),
            message: Text("Deleting a gifter has caused changes to the remaining gifter relationships. " +
                          "Restrictions have been cleared for the following gifter(s):\n\n\(names)"),
            dismissButton: .cancel(Text("OK")) {
                logFilter("alerting user that gifter restrictions have been cleared")
            }
        )
    }
    
}
