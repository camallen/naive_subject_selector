# Array difference using integer arrays
# select (select subject_ids FROM subjects_to_classify LIMIT 1) - (SELECT seen_subject_ids FROM users where id = 4993)

#TODO: build a query profile to find the set difference on each user
id_times = {}
User.all.each do |user|
  id_times[user.id] = Benchmark.measure {
    user.unseen_subjects_to_classify
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }
