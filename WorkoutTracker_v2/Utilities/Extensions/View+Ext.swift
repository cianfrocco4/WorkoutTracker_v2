//
//  View+Ext.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/19/23.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
