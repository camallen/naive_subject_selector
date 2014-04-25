# Array difference using integer arrays
# select (select subject_ids FROM subjects_to_classify LIMIT 1) - (SELECT seen_subject_ids FROM users where id = 991)

#TODO: build a query profile to find the set difference on each user
id_times = {}
User.all.each do |user|
  id_times[user.id] = Benchmark.measure {
    user.unseen_subjects_to_classify
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }
sorted = sorted_id_times.map { |times| times[1] }
min = sorted.min
max = sorted.max
len = sorted_id_times.length
ave = sorted.inject(&:+) / len
median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2

#@note: this technique doesn't scale well - simple example with ~250 users with large seen subject arrays then the above returned
#       large query times for a fair majority. As this number grows then the power users would have fairly slow selection times,
#       especially under high loads. Also updates to large arrays take a fair amount of time / disk ops due to outgrowing the current row size.
