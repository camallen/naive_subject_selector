class AddGroupId < ActiveRecord::Migration
  def change
    add_column :project_subjects, :group_id, :integer
  end
end
