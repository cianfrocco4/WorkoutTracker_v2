//
//  DecrementingTimerView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 6/4/23.
//

import SwiftUI

struct DecrementingTimerView : View {
    @EnvironmentObject private var dbMgr : DbManager

    @Binding var timerRunning : Bool
    @State var startTimeRemaining : UInt
    var isRestTimerOn : Bool
    @State private var timeRemaining : Int = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var startTime : Date?
    
    var body: some View {
        VStack {
            Button {
                // Stop the timer if pressed
                timerRunning = false
                timeRemaining = 0
            } label: {
                Text("\(timeRemaining)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 40)
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                    .keyboardType(.numberPad)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .onReceive(timer) { _ in
                        if isRestTimerOn && timerRunning {
                            guard let startTime = dbMgr.getLastSavedRestTimerStartTime() else { return }
                            timeRemaining = Int(startTime.timeIntervalSince(Date.now))
                            
                            if timeRemaining <= 0 {
                                timeRemaining = 0
                                timerRunning = false
                            }
                        }
                        else {
                            timeRemaining = 0
                        }
                    }
            }
        }
        .onAppear() {
            if !timerRunning {
                timeRemaining = 0
            }
        }
    }
}


struct DecrementingTimerView_Previews: PreviewProvider {
    
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")

    static var previews: some View {
        DecrementingTimerView(timerRunning: .constant(true),
                              startTimeRemaining: 10,
                              isRestTimerOn: true)
        .environmentObject(dbMgr)
    }
}
