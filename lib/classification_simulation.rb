class ClassificationSimulation

  def self.reset_subjects_to_clean_slate
    ProjectSubject.update_all active: true
    User.update_all seen_subject_ids: []
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
        #under no load my laptop can do ~ 100 in 0.246012 secs, so ~0.0025 sec / update
        #attempt to rate limit the input of classifications (using the above then these limits will roughly work)
        # (0.0025) = 400/s 24000/min -> no sleep just run as fast as it can
        # (0.01)   = 100/s 6000/min
        # (0.02)   = 50/s  3000/min
        # (0.05)   = 20/s  1200/min
        # (0.067)  = 15/s  900/min
        # (0.1)    = 10/s  600/min
        # (0.17)   = 6/s   360/min
        # (0.67)   = 1.5/s 90/min
        # sleep(0.01)
        classify_subject(user_id)
      end
    end
    puts "Finished classifying the set of users: #{@active_user_set} - total classified: #{@number_classified}"
  end

  private

    def classify_subject(user_id)
      subject_id = pick_subject_to_classify(user_id)
      update_sql = "UPDATE \"project_subjects\" SET \"seen_user_ids\" = array_append(seen_user_ids, '#{user_id}'), active = (CASE WHEN array_length(seen_user_ids, 1)+1 >= #{@retire_num} THEN false ELSE active END) WHERE \"id\" = #{subject_id};"
      ActiveRecord::Base.connection.execute(update_sql)
      @number_classified += 1
    end

    def pick_subject_to_classify(user_id)
      query = "NOT (seen_user_ids @> '{#{user_id}}') AND (array_length(seen_user_ids, 1) IS NULL OR array_length(seen_user_ids, 1) < #{@retire_num})"
      ProjectSubject.where(active: true).where(query).limit(100).pluck(:id).sample(10).first
    end

    def median_query_time
      len = @query_times.length
      sorted = @query_times.sort
      len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
    end
end
