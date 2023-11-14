//
//  ContentView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI

struct WorkoutTrackerTabView: View {
    @StateObject private var workoutModel =
        WorkoutModel(
            workouts: DbManager.shared.getWorkouts(), 
            historicalWorkouts: DbManager.shared.getLastDaysPerformed(days: 30),
            selectedWorkoutName: {
                    guard let (name, _/*date*/, _/*timerOn*/) = DbManager.shared.getSelectedWorkout(forDate: Date()) else {
                        return nil
                    }
                    return name
                }(),
            runningWorkoutName: {
                    guard let wkout = DbManager.shared.getSelectedWorkout(forDate: Date()) else {
                        return nil
                    }
                    return wkout.2 ? wkout.0 : nil
                }(),
            runningWorkoutTimeSec: 0,
            runningWorkoutStartDate: {
                    guard let wkout = DbManager.shared.getSelectedWorkout(forDate: Date()) else {
                        return nil
                    }
                    return wkout.2 ? wkout.1 : nil
                }())
    
    // default to workouts tab
    @State private var selectedTab = "Workouts"
    
    @Binding var useSystemBackgroundColor : Bool
    @Binding var colorSelection : ColorScheme
    
    var body: some View {
        TabView (selection: $selectedTab){
            WorkoutStatisticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Statistics")
                }
                .tag("Statistics")
            WorkoutsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Workouts")
                }
                .tag("Workouts")
                .environmentObject(workoutModel)
            
            ExercisesListView(selectedExercise: .constant(""))
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Exercises")
                }
                .tag("Exercises")
            
            SettingsView(useSystemBackgroundColor: $useSystemBackgroundColor,
                         colorSelection: $colorSelection)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag("Settings")
        }
        .onAppear {
            workoutModel.setWorkouts(
                workouts: DbManager.shared.getWorkouts())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTrackerTabView(useSystemBackgroundColor: .constant(true),
                              colorSelection: .constant(.dark))
    }
}
