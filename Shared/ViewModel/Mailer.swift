//
//  Mailer.swift
//  Shared (Model)
//
//  Created by Tanner on 8/6/21.
//

import Foundation
import SwiftSMTP


/// The Simple Mail Transfer Protocol (SMTP) object all mail will be sent from
private let smtp = SMTP(
    hostname: "smtp.gmail.com",                     // SMTP server address
    email: "secret.santa.gifter.app@gmail.com",     // username to login
    password: "hblnnazgfdwnnies"                    // google app password
)

/// The Secret Santa mailbox emails shall be sent from
private let santa = Mail.User(name: "Secret Santa", email: "secret.santa.gifter.app@gmail.com")

/**
 Sends an email from the secret santa mailbox to each gifter in the exchange.
 
 - Parameters:
    - allGifters: `true` if emails shall be sent to all gifters regardless of email status, `false` otherwise - by default, `false`
    - giftExchange: The gift exchange  to send emails out to
    - alertController: For sending alert information at the app level
 */
public func sendMail(toAll allGifters: Bool = false,
                     inExchange giftExchange: GiftExchange,
                     withController alertController: AlertController) {
    
    /// An array of emails to deliver
    var emails: [Mail] = []
    
    /// A dictionary to map Mail id's to gifters
    var mailIds: [String:Gifter] = [:]
    
    // reusable stylesheet
    let css = getCss()
    
    // construct a personalized email for each gifter
    for gifter in giftExchange.gifters {
        
        // check to see if an email should be sent to this gifter
        if !allGifters && gifter.email.state == .Sent {
            // move to next gifter if an email has already been sent to this gifter
            continue
        }
        
        // generate the personalized body message
        var recipientName = "Unknown"
        var wishLists: [String] = []
        if let recipientId = gifter.recipientId {
            if let recipient = Gifter.get(withId: recipientId) {
                recipientName = recipient.name
                wishLists = recipient.wishLists
            }
        }
        let html = genEmailHtml(for: gifter.name, in: giftExchange.name, inYear: giftExchange.date.year,
                                to: recipientName, with: wishLists, style: css)
        
        // construct the Mail object
        let mail = Mail(
            from: santa,
            to: [Mail.User(name: gifter.name, email: gifter.email.address)],
            subject: giftExchange.toString() + " Gift Exchange",
            attachments: [Attachment(htmlContent: html)]
        )
        
        // add to the email array and the mail id dictionary
        emails.append(mail)
        mailIds[mail.uuid] = gifter
    }
    
    // send the emails
    smtp.send(
        emails,
        // This optional callback gets called after each `Mail` is sent.
        // `mail` is the attempted `Mail`, `error` is the error if one occured.
        progress: { (mail, error) in
            let gifter = mailIds[mail.uuid]
            if error != nil {
                logFilter("mail error")
                gifter?.resetEmailState()
                // report error
            } else {
                logFilter("mailed gifter \(gifter?.name ?? "unknown")")
                gifter?.advanceEmailState()
                logFilter("gifter email state: \(gifter?.email.state.rawValue ?? "unknown")")
            }
            // for each mailed item, notify that the gift exchange has changed so the
            // UI will update the email statuses
            // changes made to UI must be performed on the main thread
            DispatchQueue.main.async {
                giftExchange.objectWillChange.send()
            }
        },  // end progress callback
        // This optional callback gets called after all the mails have been sent.
        // `sent` is an array of the successfully sent `Mail`s.
        // `failed` is an array of (Mail, Error)--the failed `Mail`s and their corresponding errors.
        completion: { (sent, failed) in
            // persist the changes here since this callback occurs in a separate thread from the main thread
            // (called once after all emails are sent)
            PersistenceController.shared.saveContext()
            
            // alert the user of the completion results
            if !failed.isEmpty {
                logFilter("failed: \(failed)")
                var giftersUnsent: [Gifter] = []
                for fail in failed {
                    if let affectedGifter = mailIds[fail.0.uuid] {
                        giftersUnsent.append(affectedGifter)
                    }
                }
                
                // changes made to UI must be performed on the main thread
                DispatchQueue.main.async {
                    alertController.info = AlertInfo(
                        id: .EmailsSent,
                        alert: Alerts.emailsSentAlert(giftersUnsent)
                    )
                }
            } else {
                logFilter("completed: \(sent)")
                
                // changes made to UI must be performed on the main thread
                DispatchQueue.main.async {
                    alertController.info = AlertInfo(
                        id: .EmailsSent,
                        alert: Alerts.emailsSentAlert()
                    )
                }
            }
            
        }  // end completion callback
    )
    
}
