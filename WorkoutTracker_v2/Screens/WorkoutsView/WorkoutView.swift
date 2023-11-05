//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI
import UserNotifications

struct WorkoutView: View {
    @EnvironmentObject private var selectedWkout : Workout
    
    @StateObject private var viewModel = WorkoutViewModel()
        
    @State private var restTime : UInt = 60
    @State private var restTimerRunning = false
    @State private var restTimeRemaining : UInt = 60
    @State private var workoutTime : Double = 0
    @State private var workoutTimerRunning : Bool = false
    @State private var isRestTimerOn : Bool = false
    
    var body: some View {
        VStack {
            WorkoutControlsView(restTimerRunning: $restTimerRunning,
                                workoutTime: $workoutTime,
                                workoutTimerRunning: $workoutTimerRunning,
                                isRestTimerOn: $isRestTimerOn)
            
            ExercisesView(exercises: selectedWkout.exercises,
                          restTime : restTime,
                          restTimeRemaining: $restTimeRemaining,
                          restTimeRunning: $restTimerRunning,
                          isRestTimerOn: isRestTimerOn,
                          isWorkoutTimerRunning: workoutTimerRunning)
        }
        .padding(.top)
        .onAppear() {
            let startTime = DbManager.shared.getLastSavedRestTimerStartTime()
            
            // Check if rest timer is running
            if(startTime != nil) {
                let timeRemaining = Int(startTime!.timeIntervalSince(Date.now))
                
                if timeRemaining > 0 {
                    restTimerRunning = true
                }
            }
            
            restTime = selectedWkout.restTimeSec
            isRestTimerOn = DbManager.shared.getRestTimerEnabled() ?? false
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static let wkout = MockData.sampleWorkout1
    static var previews: some View {
        WorkoutView()
            .environmentObject(wkout)
    }
}
