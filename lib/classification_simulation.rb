class ClassificationSimulation

  def self.reset_subjects_to_clean_slate
    ProjectSubject.update_all seen_user_ids: [], active: true
  end

  #run this as a concurrent set of user's from the 'concurrent_selection_simulation.sh' script
  def initialize(user_offset)
    @retire_num = 3
    # @active_user_set = User.limit(10).offset(user_offset).map(&:id)
    @active_user_set = (1..10).to_a.map { |n| user_offset + n }
    @number_classified = 0
    @classifiation_times = []
  end

  def run
    # @retire_num.times do
    3000.times do
      @active_user_set.each do |user_id|
        #under no load my workstation can do ~ 100 in 0.88 secs, so ~0.0088 sec / insert
        #@note: insert is a lot slower than the update for arrays and with more contention for the DB this will only bump!
        #attempt to rate limit the input of classifications (using the above then these limits will roughly work)
        # (0.0025) = 400/s 24000/min
        # -> no sleep just run as fast as it can
        # (0.01)   = 100/s 6000/min 
        # (0.02)   = 50/s  3000/min
        # (0.05)   = 20/s  1200/min
        # (0.067)  = 15/s  900/min
        # (0.1)    = 10/s  600/min
        # (0.17)   = 6/s   360/min
        # (0.67)   = 1.5/s 90/min
        sleep(0.01)
        classify_subject(user_id)
        #TODO: what about retiring a subject
        # post benchmark?
        # External to the service...?
      end
    end
    puts "Finished classifying the set of users: #{@active_user_set} - total classified: #{@number_classified}"
  end

  private

    def classify_subject(user_id)
      user = User.find(user_id)
      subject_id = user.random_unseen_subjects.first
      #insert_sql = "INSERT INTO user_seen_subjects (user_id, subject_id) VALUES (#{user_id}, #{subject_id});"
      #ActiveRecord::Base.connection.execute(insert_sql)
      UserSeenSubject.new(user_id: user_id, subject_id: subject_id).save(validate: false)
      @number_classified += 1
    end

    def median_query_time
      len = @query_times.length
      sorted = @query_times.sort
      len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
    end
end
