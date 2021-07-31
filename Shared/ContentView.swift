//
//  ContentView.swift
//  Shared
//
//  Created by Tanner on 7/16/21.
//

import SwiftUI
import CoreData
import SwiftSMTP

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let smtp = SMTP(
        hostname: "smtp.mail.com",     // SMTP server address
        email: "secret-santa-app@email.com",        // username to login
        password: "pIfhe2-durjud-hovwib"            // password to login
    )
    
    let santa = Mail.User(name: "Secret Santa", email: "secret-santa-app@email.com")
    let tanner = Mail.User(name: "Tan Man", email: "t.pubins@icloud.com")
    let tannerSchool = Mail.User(name: "Tan Man", email: "trpubins@asu.edu")

    var body: some View {
        Button(action: sendMail) {
            Label("Send Mail", systemImage: "mail")
        }
        
    }

    private func sendMail() {
        let mail = Mail(
            from: santa,
            to: [tanner],
            subject: "Number 1",
            text: "This is a personal email."
        )
        
        let mail1 = Mail(
            from: santa,
            to: [tannerSchool],
            subject: "Number 2",
            text: "This is a school email."
        )
        
        smtp.send([mail, mail1],
          // This optional callback gets called after each `Mail` is sent.
          // `mail` is the attempted `Mail`, `error` is the error if one occured.
          progress: { (mail, error) in
            print("sent")
          },
          
          // This optional callback gets called after all the mails have been sent.
          // `sent` is an array of the successfully sent `Mail`s.
          // `failed` is an array of (Mail, Error)--the failed `Mail`s and their corresponding errors.
          completion: { (sent, failed) in
            print("completed: \(sent)")
            print("failed: \(failed)")
          }
        )
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
