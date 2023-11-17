//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI
import UserNotifications

struct WorkoutView: View {
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @StateObject private var viewModel = WorkoutViewModel()
    
    @Binding var selectedWkout : Workout
    
    @State private var restTime : UInt = 60
    @State private var restTimerRunning = false
    @State private var restTimeRemaining : UInt = 60
    @State private var isRestTimerOn : Bool = false
    
    var body: some View {
        VStack {
            if workoutModel.isWorkoutSelected() &&
                workoutModel.getSelectedWorkout() != nil {
                WorkoutControlsView(
                    selectedWkout: $selectedWkout,
                    restTimerRunning: $restTimerRunning,
                    isRestTimerOn: $isRestTimerOn)
                
                ExercisesView(
                    selectedWkout: $selectedWkout,
                    restTimeRemaining: $restTimeRemaining,
                    restTimeRunning: $restTimerRunning,
                    isRestTimerOn: isRestTimerOn)
            }
            else {
                Text("Error: no workout is selected.")
            }
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
            
            restTime = workoutModel.getSelectedWorkout()?.restTimeSec ?? 60
            isRestTimerOn = DbManager.shared.getRestTimerEnabled() ?? false
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static let wkout = MockData.sampleWorkout1
    static var previews: some View {
        WorkoutView(selectedWkout: .constant(MockData.sampleWorkout1))
    }
}
