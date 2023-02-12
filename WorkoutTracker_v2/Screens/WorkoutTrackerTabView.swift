//
//  ContentView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI

struct WorkoutTrackerTabView: View {
    @StateObject private var dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    
    var body: some View {
        TabView {
            WorkoutsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Workouts")
                }
                .environmentObject(dbMgr)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTrackerTabView()
    }
}
