PRAGMA foreign_keys = ON;
delete from Exercise;
.import --csv --skip 1 /Users/anthony/Documents/Projects/WorkoutTracker_v2/WorkoutTracker_v2/databases/data/ExerciseData.csv Exercise
