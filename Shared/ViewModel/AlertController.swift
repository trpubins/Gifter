//
//  AlertController.swift
//  Shared (ViewModel)
//
//  Created by Tanner on 10/3/21.
//

import Foundation

/// An observable object that publishes alert information.
class AlertController: ObservableObject {
    
    /// A publisher for the latest alert information
    @Published var info: AlertInfo?
    
}
