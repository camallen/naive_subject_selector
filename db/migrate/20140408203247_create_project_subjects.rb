class CreateProjectSubjects < ActiveRecord::Migration
  def change
    create_table :project_subjects do |t|
      t.string :zooniverse_id
      t.integer :priority
      t.string :seen_user_ids, array: true, default: '{}'
      t.timestamps
    end
  end
end
