class ProjectSubject < ActiveRecord::Base

  def self.zooniverse_id_prefix(id_suffix)
    "ARG000#{ id_suffix.to_s.rjust(4, "0") }"
  end
end
