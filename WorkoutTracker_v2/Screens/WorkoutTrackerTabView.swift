//
//  ContentView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI

struct WorkoutTrackerTabView: View {
    @StateObject private var dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    
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
                .environmentObject(dbMgr)
            WorkoutsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Workouts")
                }
                .tag("Workouts")
                .environmentObject(dbMgr)
            
            ExercisesListView(selectedExercise: .constant(""))
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Exercises")
                }
                .tag("Exercises")
                .environmentObject(dbMgr)
            
            SettingsView(useSystemBackgroundColor: $useSystemBackgroundColor,
                         colorSelection: $colorSelection)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag("Settings")
                .environmentObject(dbMgr)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTrackerTabView(useSystemBackgroundColor: .constant(true),
                              colorSelection: .constant(.dark))
    }
}
