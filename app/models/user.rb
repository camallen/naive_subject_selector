class User < ActiveRecord::Base

  def random_unseen_subjects(num_to_select=10)
    query = "NOT EXISTS (SELECT subject_id FROM user_seen_subjects USS where user_id = #{self.id} AND id = USS.subject_id)"
    ProjectSubject.where(active: true).where(query).limit(100).sample(num_to_select)
  end
end
