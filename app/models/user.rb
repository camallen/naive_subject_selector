class User < ActiveRecord::Base

  SUBJET_SELECT_WINDOW_SIZE = 100

  def random_unseen_subjects(num_to_select=10)
    query = %{
      SELECT DISTINCT PS.id
      FROM project_subjects PS
      WHERE PS.active = 't'
      AND (NOT EXISTS (SELECT subject_id FROM user_seen_subjects USS where user_id = #{self.id} AND PS.id = USS.subject_id))
      LIMIT (#{SUBJET_SELECT_WINDOW_SIZE})
    }.gsub!("\n", "")
    ActiveRecord::Base.connection.select_values(query).sample(num_to_select)
  end

  #same query but maybe slightly different query paths - see query plans in explain
  # @ large volumes this is expensive!
  def random_unseen_subjects_option_2(num_to_select=10)
    query = "id NOT IN (SELECT subject_id FROM user_seen_subjects where user_id = #{power_user_id})"
    ProjectSubject.where(active: true).where(sub_query).limit(100)
  end
end
