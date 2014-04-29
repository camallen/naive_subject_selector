#query times for each user -
id_times = {}
User.all.each do |user|
  id_times[user.id] = Benchmark.measure {
    user.random_unseen_subjects
    # user.ordered_unseen_subjects
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
median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / counts

2 = {}
[ "1", "10", "20", "30", "45" ].each do |power_user_id|
  user = User.find(power_user_id)
  counts[user.id] = UserSeenSubject.where(user_id: user.id).count
end
counts.sort_by { |k,v| v }

### Query plans ###
power_user_id = 1
raw_query = %{ SELECT DISTINCT PS.id
  FROM project_subjects PS
  WHERE PS.active = 't'
  AND (NOT EXISTS (SELECT subject_id FROM user_seen_subjects USS where user_id = #{power_user_id} AND PS.id = USS.subject_id))
  LIMIT (100)
}.gsub!("\n", "")
print ActiveRecord::Base.connection.explain(raw_query)

sub_query = "id NOT IN (SELECT subject_id FROM user_seen_subjects where user_id = #{power_user_id})"
ProjectSubject.where(active: true).where(sub_query).limit(100).explain

### PRIORITY QUERIES ####
priority_query = %{ SELECT PS.id
  FROM project_subjects PS
  WHERE PS.active = 't'
  AND (NOT EXISTS (SELECT subject_id FROM user_seen_subjects USS where user_id = #{power_user_id} AND PS.id = USS.subject_id))
  ORDER BY priority
  LIMIT 10
}.gsub!("\n", "")
print ActiveRecord::Base.connection.explain(priority_query)

## QUERY TIMES ###
ActiveRecord::Base.connection.select_values(raw_query)
ActiveRecord::Base.connection.select_values(priority_query)
ProjectSubject.where(active: true).where(sub_query).limit(100)


#### SUBJECT DISTRIBUTION ######
user = User.find(1)
user.random_unseen_subjects
