#!/bin/bash

bin/rails runner "ClassificationSimulation.reset_subjects_to_clean_slate"

classifying_id_file="benchmarks/classifying.txt"
touch ${classifying_id_file}
#100 a reasonable set of active users on a project - based on active users for condor
# so create 10 processes for 10 users each
for i in `seq 0 10 199`;
do
  bin/rails runner "c_sim = ClassificationSimulation.new($i) and c_sim.run" &
done
#wait for the last classifiction sim to finish
wait $!
rm -f ${classifying_id_file}
