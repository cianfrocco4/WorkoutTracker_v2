//
//  WorkoutHistoryDetailsView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/30/23.
//

import SwiftUI

struct WorkoutHistoryDetailsView: View {
    @State var wkoutHistory : Workout
    
    @Binding var isShowingWorkoutHistoryDetails : Bool
    
    var body: some View {
        VStack {
            Button {
                isShowingWorkoutHistoryDetails = false
            } label: {
                Text("Coming soon!")
                //            Text(wkoutHistory.name)
                //            ForEach(wkoutHistory.exercises) { e in
                //                Text("\(e.name)")
                //            }
            }
        }
    }
}

struct WorkoutHistoryDetailsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        WorkoutHistoryDetailsView(wkoutHistory: MockData.sampleWorkout1,
                                  isShowingWorkoutHistoryDetails: .constant(true))
            .environmentObject(dbMgr)
    }
}
