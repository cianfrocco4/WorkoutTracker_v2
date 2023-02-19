//
//  ExerciseDropDownTableView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI

struct ExerciseDropDownTableView: View {
    
    @State var workout  : Workout
    @State var exercise : Exercise
    
    @StateObject private var viewModel = ExerciseDropDownViewModel()
    
    @EnvironmentObject var dbMgr : DbManager
    
    @Binding var repsArr : [TextBindingManager]
    @Binding var weightArr : [TextBindingManager]
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    // set
                    VStack {
                        Text("Set")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($viewModel.entries, id: \.self) { $entry in
                            Text(entry.setString)
                        }
                        .frame(height: 34)
                    }
                    
                    // Prev Wgt
                    VStack {
                        Text("Prev")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($viewModel.entries, id: \.self) { $entry in
                            Text((entry.prevWgtLbs != nil) ? entry.prevWgtLbsString : "-")
                        }
                        .frame(height: 34)
                    }
                    
                    // Wgt (lbs)
                    VStack {
                        Text("lbs")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($viewModel.entries, id: \.self) { $entry in
                            TextField("Wgt", value: $entry.wgtLbs, format: .number)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                        }
                        .frame(height: 34)
                    }
                    
                    // Reps
                    VStack {
                        Text("Reps")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($viewModel.entries, id: \.self) { $entry in
                            TextField("Reps", value: $entry.reps, format: .number)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                        }
                        .frame(minHeight: 34)
                    }
                    
                    // Save
                    VStack {
                        Text("Save")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($viewModel.entries, id: \.self) { $entry in
                            Button {
                                viewModel.save(workout: workout,
                                               exercise: exercise,
                                               set: entry.set)
                            } label: {
                                Image(systemName: entry.saved ?
                                      "checkmark.rectangle.portrait.fill" :
                                        "checkmark.rectangle.portrait")
                                .foregroundColor(entry.saved ? .green : .primary)
                            }
                            .buttonStyle(.bordered)
                            .background(Color(UIColor.tertiarySystemBackground))
                            
                        }
                        .frame(height: 34)
                    }
                }
                .padding(.bottom, 10)
                
                Button {
                    viewModel.saveAll(workout: workout,
                                      exercise: exercise)
                } label: {
                    Text("Save All")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 260, height: 30)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .buttonStyle(.bordered)
                .background(Color(UIColor.tertiarySystemBackground))
            }
        }
        .padding()
        .frame(width: .infinity, height: .infinity)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
            )
        .onAppear {
            self.viewModel.setup(self.dbMgr)
            for set in 0..<exercise.sets {
                let prevWgt = viewModel.getPrev(exerciseName: exercise.name,
                                                set: set+1)
                viewModel.entries.append(ExerciseEntry(set: set,
                                                       prevWgtLbs: prevWgt,
                                                       wgtLbs: nil,
                                                       reps: Int(repsArr[set].text) ?? 0,
                                                       saved: false))
            }
        }
    }
}

struct ExerciseDropDownTableView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExerciseDropDownTableView(workout: MockData.sampleWorkout1,
                                 exercise: MockData.sampleExercises[0],
                                 repsArr: .constant(MockData.sampleRepsWeightArr),
                                 weightArr: .constant(MockData.sampleRepsWeightArr))
            .environmentObject(dbMgr)
    }
}

struct ExerciseEntry : Identifiable, Hashable {
    let set : Int
    let prevWgtLbs : Float?
    var wgtLbs : Float?
    var reps : Int
    var saved : Bool
    let id = UUID()
    
    var setString: String {
        String(set+1)
    }
    
    var prevWgtLbsString: String {
        String(prevWgtLbs!)
    }
    
    var wgtLbsString: String {
        String(wgtLbs!)
    }
}
