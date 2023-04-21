//
//  UIApplication+Ext.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/14/23.
//

import SwiftUI

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var appBuildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
