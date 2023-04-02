//
//  RoundedButton.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/19/23.
//

import SwiftUI

struct RoundedButton: View {
    @State var text : String
    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.body)
            .fontWeight(.semibold)
            .frame(width: 130, height: 30)
            .foregroundColor(.primary)
            .cornerRadius(10)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(text: "Save")
    }
}
