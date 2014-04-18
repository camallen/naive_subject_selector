retirement_range = (1..15)
pwid = 10000
query = "NOT (seen_user_ids @> '{#{pwid}}') AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
ProjectSubject.where(active: true).where(query).limit(100).sample(10)

#check the cost of the different query structures...seems the ALL is slightly more expensive..Use the NOT in @>
x = ProjectSubject.where("NOT (seen_user_ids @> '{#{pwid}}') AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})").limit(100).order(priority: :desc).map(&:id)
y = ProjectSubject.where("'#{pwid}' != ALL (seen_user_ids) AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})").limit(100).order(priority: :desc).map(&:id)

ProjectSubject.where("NOT (seen_user_ids @> '{#{pwid}}') AND id = '199964'").to_a
ProjectSubject.where("'#{pwid}' != ALL (seen_user_ids) AND id = '199964'").to_a

# Query to simulate the long tails of some power users
power_user_ids = [ "1", "10", "20", "30", "45" ]
id_times = {}
power_user_ids.each do |pwid|
  id_times[pwid] = Benchmark.measure {
    query = "NOT (seen_user_ids @> '{#{pwid}}') AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
    ProjectSubject.where(query).limit(100).sample(10)
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }

# get the counts of each power user
user_counts = {}
power_user_ids.each do |pwid|
  user_counts[pwid] = ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
  # ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count
end
puts user_counts

# get the counts of each user
user_counts = {}
fake_user_range.to_a.sample(10_000).each do |pwid|
  user_counts[pwid] = ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
  # ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count
end
puts user_counts

# Time each user's query for the next 10 subjects they haven't seen
fake_user_range = (1..200)
retirement_range = (1..15)
id_times = {}
fake_user_range.to_a.sample(10_000).each do |pwid|
  id_times[pwid] = Benchmark.measure {
    query = "NOT (seen_user_ids @> '{#{pwid}}') AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
    ProjectSubject.where(active: true).where(query).limit(100).sample(10)
  }.real
end
sorted_id_times = id_times.sort_by{ |k,v| v }
sorted = sorted_id_times.map { |times| times[1] }
min = sorted.min
max = sorted.max
len = sorted_id_times.length
ave = sorted.inject(&:+) / len
median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2

# Count all subjects a user has seen
ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
# Count subjects that only this user has seen
ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count


# TODO: compare the index use with the active column and why this won't work...?
# I.e. simulate michaels query and can we use the Gin index instead?

# READ ABOUT COMPOUND KEYS ON THE GIN INDEX
# and how we can avoid / use it
