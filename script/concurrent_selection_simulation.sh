#!/bin/bash

# #100 a reasonable set of active users on a project - based on active users for condor
# # so create 10 processes for 10 users each
# wait for the classifications to start rolling in

results_file="benchmarks/s_sim.csv"
echo "Min, Max, Ave, Median" > ${results_file}
classifying_id_file="benchmarks/classifying.txt"
#run a set of selections while the classifier is updating the GIN index in the background
while [ -f ${classifying_id_file} ]
do
  for i in `seq 0 10 199`;
  do
    bin/rails runner "s_sim = SelectionSimulation.new($i) and s_sim.run" >> ${results_file} &
    #use a sleep to offset the concurrent number of users - my laptop is CPU bound on large concurrent requests
    sleep 0.5
  done
  #done start the next set of subject selections till the the last lot have finished
  wait $!
done
