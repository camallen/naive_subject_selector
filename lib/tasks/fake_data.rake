require 'pry'

namespace :fake_data do

  def fake_range
    #simulation of distribution test
    # (1..100)
    # #test / beta project
    # (1..1000)
    # #very large project
    (1..5_000_000)
  end

  def fake_project_subject_id(id)
    ProjectSubject.zooniverse_id_prefix id
  end

  def fake_group_subject_id
    (1..10).to_a.sample
  end

  def fake_seen_user_ids(num)
    User.order("RANDOM()").limit(num).map(&:id)
  end

  def fake_user_range
    #distribution simulation
    # (1..20)
    # #very large set of users
    (1..10_000)
  end

  def fake_seen_fake_user_ids(num)
    fake_user_range.to_a.sample(num)
  end

  def power_user_ids
    #distribution simulation
    [ "1", "5", "12", "15", "19" ]
    #large simulation
    # [ "1", "10", "20", "30", "45" ]
  end

  def number_of_seen_users
    retirement_range.to_a.sample
  end

  # would a valid retirement happen around 30 classifications?
  #   depending on the rules possibly.
  def retirement_range
    #distribution simulation
    (1..15)
    #large simulation
    # (1..30)
  end

  def update_seen_user_ids(ps_id, user_ids)
    formatted_user_ids = '{"' << user_ids.join('","') << '"}'
    ActiveRecord::Base.connection.execute("UPDATE \"project_subjects\" SET \"seen_user_ids\" = '#{formatted_user_ids}' WHERE \"project_subjects\".\"id\" = #{ps_id};")
  end

  def unseen_project_subjects
    ProjectSubject.where("seen_user_ids = '{}' OR seen_user_ids IS NULL")
  end

  desc 'fake a bunch of project subjects'
  task :create_fake_project_subjects => :environment do
    counter = 1
    total_pss = fake_range.last
    while counter < total_pss
      fake_range.each_slice(25_000) do |ids|
        pss = []
        ids.each do |id|
          zoo_id = fake_project_subject_id id
          pss << ProjectSubject.new(zooniverse_id: zoo_id, priority: id, group_id: fake_group_subject_id)
          counter += 1
        end
        ProjectSubject.import pss
      end
    end
  end

  desc 'fake a bunch of users'
  task :create_fake_users => :environment do
    users = []
    fake_user_range.each do |user_number|
      users << User.new(email: "user_#{user_number}@fake.com")
    end
    User.import users
  end

  desc 'add some seen users to a sample of the data'
  task :fake_user_seen_subjects => :environment do
    sample_size = fake_range.last / 2
    unseen_subject_ids = unseen_project_subjects.map(&:id)
    fake_range.to_a.sample(sample_size).each do |id|
      if unseen_subject_ids.include?(id)
        update_seen_user_ids(id, fake_seen_fake_user_ids(number_of_seen_users))
      end
      # @note: attempted to output to a file (redirection) and then import...(no metrics but it didn't feel any quicker)
      # pg_seen_user_ids_array_string = '{"' << fake_seen_fake_user_ids(number_of_seen_users).join('","') << '"}'
      # puts "UPDATE \"project_subjects\" SET \"seen_user_ids\" = '#{pg_seen_user_ids_array_string}' WHERE \"project_subjects\".\"id\" = #{id};"
    end
  end

  desc 'even out distribution of seen users to the rest of the subjects'
  task :even_out_fake_seen_subjects_distribution => :environment do
    unseen_project_subjects.find_each(batch_size: 10_000) do |ps|
      ps.update_column 'seen_user_ids', fake_seen_fake_user_ids(number_of_seen_users)
    end
  end

  desc 'set a subset of project subjects to inactive'
  task :setup_inactive_project_subject_set => :environment do
    sample_size = fake_range.last / 4
    random_ids = fake_range.to_a.sample(sample_size)
    ProjectSubject.where(id: random_ids).update_all(active: false)
  end

  desc 'simulate power users and the long tail'
  task :fake_power_users => :environment do
    percent_complete = (fake_range.last * 0.85).to_i
    fake_range.to_a.sample(percent_complete).each do |id|
      fake_users_and_power_users = fake_seen_fake_user_ids(number_of_seen_users) | power_user_ids
      update_seen_user_ids(id, fake_users_and_power_users)
    end
  end

  desc 'create a simulation to get the shape of a the count size query distribution'
  task :run_psuedo_random_selection_simulation => :environment do
    ProjectSubject.update_all seen_user_ids: []
    (1..25).each do |classification_num|
      #select a random user among the 20
      (1..20).each do |user_num|
        #the crux of it here...randomly sample a set from a possible limit (would look for just ID's in reality as well)
        #this is linear progression through the empty set of unseen subjects on a sliding window
        query_str = "'#{user_num}' != ALL (seen_user_ids) AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
        if ps = ProjectSubject.where(query_str).limit(100).sample(1).first
          # ps = ProjectSubject.where(query_str).limit(1).first
          ps.update_column 'seen_user_ids', ps.seen_user_ids << user_num
        else
          raise Exception.new("ERROR IN SELECTION -> NEED TO FIND AT LEAST ONE SUBJECT TO SERVE!")
        end
      end
    end
  end
end

# retirement_range = (1..15)
# pwid = 10000
# query = "'#{pwid}' != ALL (seen_user_ids) AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
# ProjectSubject.where(active: true).where(query).limit(100).sample(10)
# ProjectSubject.where(query).limit(100).sample(10)

#Query to simulate the long tails of some power users
# power_user_ids = [ "1", "10", "20", "30", "45" ]
# id_times = {}
# power_user_ids.each do |pwid|
#   id_times[pwid] = Benchmark.measure {
#     ProjectSubject.where("'#{pwid}' != ALL (seen_user_ids) AND array_length(seen_user_ids, 1) < #{retirement_range.last}").limit(100).sample(10)
#   }.real
# end
# sorted_id_times = id_times.sort_by{ |k,v| v }
#
#get the counts of each power user
# user_counts = {}
# power_user_ids.each do |pwid|
#   user_counts[pwid] = ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
#   # ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count
# end
# puts user_counts
#
#get the counts of each user
# user_counts = {}
# fake_user_range.to_a.sample(10_000).each do |pwid|
#   user_counts[pwid] = ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
#   # ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count
# end
# puts user_counts
#
#Time each user's query for the next 10 subjects they haven't seen
# id_times = {}
# fake_user_range.to_a.sample(10_000).each do |pwid|
#   id_times[pwid] = Benchmark.measure {
#     query = "'#{pwid}' != ALL (seen_user_ids) AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{retirement_range.last})"
#     ProjectSubject.where(active: true).where(query).limit(100).sample(10)
#   }.real
# end
# sorted_id_times = id_times.sort_by{ |k,v| v }
#
#Count all subjects a user has seen
# ProjectSubject.where("'#{pwid}' = ANY (seen_user_ids)" ).order(priority: :desc).count
#Count subjects that only this user has seen
# ProjectSubject.where("'#{pwid}' = ALL (seen_user_ids)" ).order(priority: :desc).count
#
#
#TODO: compare the index use with the active column and why this won't work...?
# I.e. simulate michaels query and can we use the Gin index instead?

# READ ABOUT COMPOUND KEYS ON THE GIN INDEX
# and how we can avoid / use it
