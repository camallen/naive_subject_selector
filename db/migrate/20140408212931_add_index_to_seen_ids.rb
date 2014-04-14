class AddIndexToSeenIds < ActiveRecord::Migration
  def change
    add_index :project_subjects, :seen_user_ids, using: 'gin'
  end
end
