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
    
    var body: some View {
        TabView (selection: $selectedTab){
            WorkoutStatisticsView()
//                .onTapGesture {
//                    selectedTab = "Statistics"
//                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Statistics")
                }
                .tag("Statistics")
                .environmentObject(dbMgr)
            WorkoutsView()
//                .onTapGesture {
//                    selectedTab = "Workouts"
//                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Workouts")
                }
                .tag("Workouts")
                .environmentObject(dbMgr)
            
            ExercisesListView(selectedExercise: .constant(""))
//                .onTapGesture {
//                    selectedTab = "Exercises"
//                }
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Exercises")
                }
                .tag("Exercises")
                .environmentObject(dbMgr)
            
            SettingsView()
//                .onTapGesture {
//                    selectedTab = "Settings"
//                }
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
        WorkoutTrackerTabView()
    }
}
