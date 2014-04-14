class AddPriorityIndex < ActiveRecord::Migration
  def change
    add_index :project_subjects, :priority
  end
end
