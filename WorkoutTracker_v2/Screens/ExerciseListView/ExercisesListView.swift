//
//  ExercisesListView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/12/23.
//

import SwiftUI

struct ExercisesListView: View {
    @EnvironmentObject var dbMgr : DbManager
    
    @StateObject private var viewModel = ExerciseListViewModel()

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(viewModel.exercises, id: \.self) { exercise in
                            Text(exercise)
                        }
                    }
                }
                .navigationTitle("Exercises 🏋️")
            }
        }
        .onAppear {
          self.viewModel.setup(self.dbMgr)
        }
    }
}

struct ExercisesListView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExercisesListView()
            .environmentObject(dbMgr)
    }
}
