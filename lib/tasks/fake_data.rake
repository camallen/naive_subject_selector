require 'pry'

namespace :fake_data do

  def fake_range
    #test / beta project
    #(1..1000)
    (1..200_000)
    #very large project
    # (1..5_000_000)
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
    #(1..5000)
    #very large set of users
    (1..10_000)
  end

  def fake_seen_fake_user_ids(num)
    fake_user_range.to_a.sample(num)
  end

  def power_user_ids
    #large simulation
    [ "1", "10", "20", "30", "45" ]
  end

  def number_of_seen_users
    retirement_range.to_a.sample
  end

  # would a valid retirement happen around 30 classifications?
  #   depending on the rules possibly.
  def retirement_range
    #large simulation
    (1..30)
  end

  def add_user_seen_subjects(subject_user_ids)
    subject_user_ids.each_slice(25_000) do |id_pairs|
      uss = []
      id_pairs.each do |id_pair|
        uss << UserSeenSubject.new(user_id: id_pair.user_id, subject_id: id_pair.subject_id)
      end
      UserSeenSubject.import uss
    end
  end

  def unseen_project_subjects
    ProjectSubject.select(:id).map(&:id) - UserSeenSubject.select(:subject_id).map(&:subject_id)
  end

  IdPair = Struct.new(:user_id, :subject_id)

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
    seen_subject_user_ids = []
    puts "#{DateTime.now} - Constructing a set of UserSeenSubjects"
    fake_range.to_a.sample(sample_size).each do |subject_id|
      unless UserSeenSubject.exists?(subject_id: subject_id)
        seen_subject_user_ids << IdPair.new(fake_seen_fake_user_ids(1).first, subject_id)
      end
    end
    puts "#{DateTime.now} - Go ahead and import them"
    add_user_seen_subjects(seen_subject_user_ids)
  end

  desc 'even out distribution of seen subjects'
  task :even_out_fake_seen_subjects_distribution => :environment do
    unseen_project_subjects.each_slice(10_000) do |unseen_subject_ids|
      uss = []
      unseen_subject_ids.each do |unseen_subject_id|
        uss << UserSeenSubject.new(user_id: fake_seen_fake_user_ids(1).first, subject_id: unseen_subject_id)
      end
      UserSeenSubject.import uss
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
    completed_subject_ids = fake_range.to_a.sample(percent_complete)
    completed_subject_ids.each_slice(2000) do |batch_of_subject_ids|
      uss = []
      batch_of_subject_ids.each do |subject_id|
        power_user_ids.each do |power_user_id|
          uss << UserSeenSubject.new(user_id: power_user_id, subject_id: subject_id)
        end
      end
      UserSeenSubject.import uss
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
