require 'pry'

namespace :fake_data do

  def fake_range
    #test / beta project
    (1..1000)
    #(1..200000)
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
    (1..5000)
    #very large set of users
    # (1..10_000)
  end

  def fake_seen_fake_user_ids(num)
    fake_user_range.to_a.sample(num)
  end

  def fake_seen_fake_subject_ids(num)
    fake_range.to_a.sample(num)
  end

  def number_of_seen_subjects
    fake_range.to_a.sample
  end

  # would a valid retirement happen around 30 classifications?
  #   depending on the rules possibly.
  def retirement_range
    (1..10)
    #large simulation
    # (1..30)
  end

  def update_seen_subject_ids(user_id, subject_ids)
    formatted_ids = '{"' << subject_ids.join('","') << '"}'
    ActiveRecord::Base.connection.execute("UPDATE \"users\" SET \"seen_subject_ids\" = '#{formatted_ids}' WHERE \"id\" = #{user_id};")
  end

  def users_without_seen_subjects
    User.where("seen_subject_ids = '{}' OR seen_subject_ids IS NULL")
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

  desc 'fake the active subjects for a project'
  task :create_fake_active_subjects => :environment do
    SubjectsToClassify.delete_all
    SubjectsToClassify.create(subject_ids: fake_range.to_a)
  end

  desc 'fake a bunch of users'
  task :create_fake_users => :environment do
    users = []
    fake_user_range.each do |user_number|
      users << User.new(email: "user_#{user_number}@fake.com")
    end
    User.import users
  end

  desc 'reset seen subject ids for all users'
  task :reset_user_seen_subject_ids => :environment do
    User.update_all(seen_subject_ids: [])
  end

  desc 'add some seen subjects to a sample of the user data'
  task :fake_user_seen_subjects => :environment do
    user_sample_size = fake_user_range.last / 2
    users_without_subject_ids = users_without_seen_subjects.map(&:id)
    fake_seen_fake_user_ids(user_sample_size).each do |user_id|
      if users_without_subject_ids.include?(user_id)
        update_seen_subject_ids(user_id, fake_seen_fake_subject_ids(number_of_seen_subjects))
      end
    end
  end

  desc 'set a subset of project subjects to inactive'
  task :setup_inactive_project_subject_set => :environment do
    sample_size = fake_range.last / 4
    random_ids = fake_range.to_a.sample(sample_size)
    ProjectSubject.where(id: random_ids).update_all(active: false)
  end
end
