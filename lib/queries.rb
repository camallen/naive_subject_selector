#query times for each user -
id_times = {}
User.all.each do |user|
  id_times[user.id] = Benchmark.measure {
    user.random_unseen_subjects
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }
sorted = sorted_id_times.map { |times| times[1] }
min = sorted.min
max = sorted.max
len = sorted_id_times.length
ave = sorted.inject(&:+) / len
median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2

counts = {}
User.all.each do |user|
  counts[user.id] = UserSeenSubject.where(user_id: user.id).count
end
counts.sort_by { |k,v| v }

#### POWER USERS #######

id_times = {}
[ "1", "10", "20", "30", "45" ].each do |power_user_id|
  user = User.find(power_user_id)
  id_times[user.id] = Benchmark.measure {
    user.random_unseen_subjects
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }
sorted = sorted_id_times.map { |times| times[1] }
min = sorted.min
max = sorted.max
len = sorted_id_times.length
ave = sorted.inject(&:+) / len
median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2

counts = {}
[ "1", "10", "20", "30", "45" ].each do |power_user_id|
  user = User.find(power_user_id)
  counts[user.id] = UserSeenSubject.where(user_id: user.id).count
end
counts.sort_by { |k,v| v }

### Query plans ###
power_user_id = 1
query = "NOT EXISTS (SELECT subject_id FROM user_seen_subjects USS where user_id = #{power_user_id} AND id = USS.subject_id)"
query = "id NOT IN (SELECT subject_id FROM user_seen_subjects where user_id = #{power_user_id})"
ProjectSubject.where(active: true).where(query).limit(100).explain
ProjectSubject.where(query).limit(100).explain
