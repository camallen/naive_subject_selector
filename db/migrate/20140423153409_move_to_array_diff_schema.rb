class MoveToArrayDiffSchema < ActiveRecord::Migration
  def change
    remove_column :project_subjects, :seen_user_ids
    add_column :users, :seen_subject_ids, :integer, array: true, default: []
    add_index :users, :seen_subject_ids, using: 'gin'
    create_table :subjects_to_classify do |t|
      t.integer :subject_ids, array: true, default: []
      t.timestamps
    end
  end
end
