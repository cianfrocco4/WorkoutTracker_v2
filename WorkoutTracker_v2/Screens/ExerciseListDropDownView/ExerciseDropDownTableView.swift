//
//  ExerciseDropDownTableView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/4/23.
//

import SwiftUI

struct ExerciseDropDownTableView: View {
    
    @State var workout  : Workout?
    @State var exercise : Exercise
    @State var restTime : UInt
        
    @StateObject private var viewModel = ExerciseDropDownViewModel()
    
    @EnvironmentObject var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    @Binding var repsArr : [TextBindingManager]
    @Binding var weightArr : [TextBindingManager]
    @Binding var entries : [ExerciseEntry]
    @Binding var notes : String
    @Binding var restTimeRemainingSec : UInt
    @Binding var restTimeRunning : Bool
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            VStack {
                TextField("Notes", text: $notes)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    // set
                    VStack {
                        Text("Set")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($entries, id: \.self) { $entry in
                            Text(entry.setString)
                        }
                        .frame(height: 34)
                    }
                    
                    // Prev Wgt
                    VStack {
                        Text("Prev")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach($entries, id: \.self) { $entry in
                            Text((entry.prevWgtLbs != nil) ? entry.prevWgtLbsString : "-")
                        }
                        .frame(height: 34)
                    }
                    
                    // Wgt (lbs)
                    VStack {
                        Text("lbs")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            TextField("Wgt", value: $entries[index].wgtLbs, format: .number)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                                .keyboardType(.numberPad)
                        }
                        .frame(height: 34)
                    }
                    
                    // Reps
                    VStack {
                        Text("Reps")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            TextField("Reps", value: $entries[index].reps, format: .number)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.tertiarySystemBackground)))
                                .keyboardType(.numberPad)
                        }
                        .frame(minHeight: 34)
                    }
                    
                    // Save
                    VStack {
                        Text("Save")
                            .fontWeight(.semibold)
                        Divider()
                        ForEach(entries.indices, id: \.self) { index in
                            Button {
                                if entries[index].saved {
                                    viewModel.unsave(workout: selectedWkout,//workout: workout,
                                                     exercise: exercise,
                                                     set: entries[index].set)
                                }
                                else {
                                    viewModel.save(workout: selectedWkout, //workout,
                                                   exercise: exercise,
                                                   set: entries[index].set,
                                                   entries: entries,
                                                   notes: notes)
                                    
                                    restTimeRemainingSec = selectedWkout.restTimeSec //workout.restTimeSec
                                    restTimeRunning = true  // start the rest time timer
                                }
                                
                                entries[index].saved = !(entries[index].saved)
                                hideKeyboard()

                            } label: {
                                Image(systemName: entries[index].saved ?
                                      "checkmark.rectangle.portrait.fill" :
                                        "checkmark.rectangle.portrait")
                                .imageScale(.medium)
                                .foregroundColor(entries[index].saved ? .green : .primary)
                            }
                            .buttonStyle(.bordered)
                            .background(Color.buttonBackground)
                            
                        }
                        .frame(height: 34)
                    }
                }
                .padding(.bottom, 10)
                
                Button {
                    viewModel.saveAll(workout: selectedWkout, //workout,
                                      exercise: exercise,
                                      entries: entries,
                                      exerciseNotes: notes)
                    hideKeyboard()
                    
                    for set in 0..<entries.count {
                        // Update all entries to be saved
                        entries[set].saved = true
                    }
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
                .background(Color.buttonBackground)
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
//            for set in 0..<exercise.sets {
//                let prevWgt = viewModel.getPrev(exerciseName: exercise.name,
//                                                set: set)
//                entries.append(ExerciseEntry(set: set,
//                                             prevWgtLbs: prevWgt,
//                                             wgtLbs: nil,
//                                             reps: Int(repsArr[set].text) ?? 0,
//                                             saved: false))
//            }
        }
    }
}

struct ExerciseDropDownTableView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        ExerciseDropDownTableView(workout: MockData.sampleWorkout1,
                                  exercise: MockData.sampleExercises[0],
                                  restTime: 60,
                                  repsArr: .constant(MockData.sampleRepsWeightArr),
                                  weightArr: .constant(MockData.sampleRepsWeightArr),
                                  entries: .constant(MockData.sampleEntries),
                                  notes: .constant(""),
                                  restTimeRemainingSec: .constant(60),
                                  restTimeRunning: .constant(false))
            .environmentObject(dbMgr)
            .environmentObject(MockData.sampleWorkout1)
    }
}

// Textfield that will not trigger a re-draw of the Nav View when inputting a character
struct CustomTextField: View {
    @Binding var owner : Int
    @State var label : String
    @State var value = "" // updates only local view

    var body: some View {
        let text = Binding(get: { self.value }, set: {
            self.value = $0; self.owner = Int($0) ?? 0;  // transfer the value
        })
        return TextField(label, text: text)
    }
}
