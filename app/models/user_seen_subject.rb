class UserSeenSubject < ActiveRecord::Base

	def self.reset_user_seen_subjects
	  ActiveRecord::Base.connection.execute("TRUNCATE user_seen_subjects")
	end
end
