class RemoveArrayUseSeenTable < ActiveRecord::Migration
  def change
    remove_column :project_subjects, :seen_user_ids, :string, array: true
    create_table :user_seen_subjects do |t|
      t.integer :user_id
      t.integer :subject_id
      t.timestamps
    end
    add_index :user_seen_subjects, :user_id
    add_index :user_seen_subjects, :subject_id
  end
end
