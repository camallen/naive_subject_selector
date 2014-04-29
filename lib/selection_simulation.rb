class SelectionSimulation

  NUM_TO_ROUND = 5

  #run this as a concurrent set of user's from the 'concurrent_selection_simulation.sh' script
  def initialize(user_offset)
    @retire_num = 3
    # @active_user_set = User.limit(10).offset(user_offset).map(&:id)
    @active_user_set = (1..10).to_a.map { |n| user_offset + n }
    @query_times = []
  end

  def run
    #prime the DB connection
    ProjectSubject.first
    @active_user_set.each do |user_id|
      user = User.find(user_id)
      @query_times << Benchmark.measure { user.random_unseen_subjects }.real
      #don't saturate the machine - limit to 10 queries / second or so...
      sleep(0.1)
    end
    puts "#{@query_times.min}, #{@query_times.max}, #{ave_query_time}, #{median_query_time}, [ #{@query_times.join(" ")} ]"
  end

  private

  def query_times_length
    @qt_length ||= @query_times.length
  end

  def ave_query_time
    ave = @query_times.inject(&:+) / query_times_length
    ave.round(NUM_TO_ROUND)
  end

  def median_query_time
    len = query_times_length
    sorted = @query_times.sort
    median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
    median.round(NUM_TO_ROUND)
  end
end
