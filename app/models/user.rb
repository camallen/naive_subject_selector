class User < ActiveRecord::Base

  def unseen_subjects_to_classify
    query = "select (select subject_ids FROM subjects_to_classify LIMIT 1) - (SELECT seen_subject_ids FROM users where id = #{self.id}) as ids"
    ActiveRecord::Base.connection.execute(query).to_a
  end
end
