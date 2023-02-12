CREATE TABLE WorkoutDetails ( workoutName STRING NOT NULL, 
                              exerciseName STRING NOT NULL,
                              numSets INTEGER NOT NULL, 
                              minReps INTEGER NOT NULL,
                              maxReps INTEGER NOT NULL,
                              PRIMARY KEY (workoutName, exerciseName),
                              FOREIGN KEY (workoutName) REFERENCES Workout (name),
                              FOREIGN KEY (exerciseName) REFERENCES Exercise (name) ); 
