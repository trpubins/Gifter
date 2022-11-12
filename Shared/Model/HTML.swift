//
//  HTML.swift
//  Shared (Model)
//
//  Created by Tanner on 11/12/22.
//

import Foundation

/**
 Generates the personalized HTML body for a gift exchange participant.
 
 - Parameters:
    - gifterName: The name of the gifter
    - groupName: The name of the gift exchange group
    - year: The year of the gift exchange
    - recipientName: The name of the recipient
    - wishLists: An array of wish list URLs
    - css: The stylesheet to use for the html
 
 - Returns: A personalized HTML message describing gift exchange specifics.
 */
public func genEmailHtml(for gifterName: String,
                         in groupName: String,
                         inYear year: Int,
                         to recipientName: String,
                         with wishLists: [String],
                         style css: String) -> String {
    let urlGiftIcon = "https://secret-santa-app.s3.us-west-1.amazonaws.com/gift-icon.png"
    let urlSantaImg = "https://secret-santa-app.s3.us-west-1.amazonaws.com/img-secret-santa.png"
    
    // convert wish list array into string
    var wishListStr = ""
    for wishList in wishLists {
        wishListStr += "<li>\n" +
        "<a href=\"\(wishList)\">\(wishList)</a>\n" +
        "</li>\n"
    }
    
    let htmlMsg = "<!DOCTYPE html>\n" +
    "<html lang=\"en\">\n" +
    "<head>\n" +
    "<meta charset=\"UTF-8\">\n" +
    "<meta content=\"width=device-width,initial-scale=1\" name=\"viewport\">\n" +
    "<meta content=\"description\" name=\"description\">\n" +
    "<meta name=\"google\" content=\"notranslate\" />\n" +
    "<meta name=\"msapplication-tap-highlight\" content=\"no\">\n" +
    "<title>Secret Santa</title>\n" +
    "</head>\n" +
    
    "<style>\n" +
    "\(css)\n" +
    "</style>\n" +
    
    "<body>\n" +
    "<header>\n" +
    "<nav class=\"navbar navbar-default active\">\n" +
    "<div class=\"container\">\n" +
    "<div class=\"navbar-header\">\n" +
    "<a class=\"navbar-brand\" title=\"\">\n" +
    "<img src=\"\(urlGiftIcon)\" class=\"navbar-logo-img\" alt=\"\">Secret Santa</a>\n" +
    "</div>\n" +
    "<div class=\"collapse navbar-collapse\" id=\"navbar-collapse\">\n" +
    "<ul class=\"nav navbar-nav navbar-right\"></ul>\n" +
    "</div>\n" +
    "</div>\n" +
    "</nav>\n" +
    "</header>\n" +
    
    "<div class=\"container\">\n" +
    "<div class=\"row\">\n" +
    "<div class=\"col-xs-12\">\n" +
    "<h1 class=\"text-center\">\(groupName.uppercased())<br>Secret Santa \(year)</h1>\n" +
    "<p>\n" +
    "<h5>\(gifterName.uppercased()),</h5>\n" +
    "The results are in and it looks like you are gifting <b>\(recipientName)</b> for the \(year) gift exchange!<br><br>\n" +
    "You can find their wish list(s) here:<br>\n" +
    "<ul>\n" +
    "\(wishListStr)" +
    "</ul>\n" +
    "<br>\n" +
    "</p>\n" +
    "</div>\n" +
    "</div>\n" +
    
    "<div class=\"row\">\n" +
    "<div class=\"col-xs-4\">\n" +
    "<img src=\"\(urlSantaImg)\" alt=\"\" class=\"img-responsive reveal-content\">\n" +
    "</div>\n" +
    "</div>\n" +
    "</div>\n" +
    
    "<footer class=\"footer-container white-text-container\">\n" +
    "<div class=\"container\">\n" +
    "<div class=\"row\">\n" +
    "<div class=\"text-center\">\n" +
    "<small>\n" +
    "<u>\n" +
    "<a>Unsubscribe</a>\n" +
    "</u>\n" +
    "</small>\n" +
    "</div>\n" +
    "</div>\n" +
    "<div class=\"row\">\n" +
    "<div class=\"col-xs-12\">\n" +
    "<h3>The Secret Santa Team</h3>\n" +
    "</div>\n" +
    "</div>\n" +
    "<div class=\"row\">\n" +
    "<div class=\"col-xs-7\">\n" +
    "<p>\n" +
    "<small>Keep spreading the good giving vibes.</small><br>\n" +
    "<small>Design supported by <a href=\"http://www.mashup-template.com/\">Mashup Template</a></small>\n" +
    "</p>\n" +
    "</div>\n" +
    "<div class=\"col-xs-5\">\n" +
    "<p class=\"text-right\" title=\"Copyright\">&copy;\(Date().year) Secret Santa, LLC. All rights reserved.</p>\n" +
    "</div>\n" +
    "</div>\n" +
    "</div>\n" +
    "</footer>\n" +
    
    "</body>\n" +
    "</html>\n"
        
    return htmlMsg
}

/**
 Retrieves the cascading style sheet (CSS) from the app bundle.
 
 - Returns: CSS as a string.
 */
public func getCss() -> String {
    let cssFilename: NSString = "main.css"  // Resources folder
    if let filepath = Bundle.main.url(forResource: cssFilename.deletingPathExtension,
                                      withExtension: cssFilename.pathExtension) {
        do {
            let contents = try String(contentsOf: filepath)
            return contents
        } catch {
            fatalError("Contents could not be loaded from \(cssFilename)")
        }
    } else {
        fatalError("File not found! Add \(cssFilename) to Resources folder")
    }
}
