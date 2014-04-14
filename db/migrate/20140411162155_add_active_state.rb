class AddActiveState < ActiveRecord::Migration
  def change
    add_column :project_subjects, :active, :boolean, default: true
    add_index  :project_subjects, :active
  end
end
