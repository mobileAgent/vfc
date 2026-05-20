# This migration comes from acts_as_taggable_on_engine (originally 1)
#
# Modified for the acts_as_taggable_on_steroids -> acts-as-taggable-on
# transition. The `tags` and `taggings` tables already exist (created by
# steroids), so we guard create_table and instead add only the columns and
# indexes acts-as-taggable-on needs that the legacy schema lacks.
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    unless table_exists?(:tags)
      create_table :tags do |t|
        t.string :name
      end
    end

    if table_exists?(:taggings)
      # Legacy steroids taggings table: add the AATO-specific columns.
      add_column :taggings, :tagger_id,   :integer             unless column_exists?(:taggings, :tagger_id)
      add_column :taggings, :tagger_type, :string              unless column_exists?(:taggings, :tagger_type)
      add_column :taggings, :context,     :string, limit: 128  unless column_exists?(:taggings, :context)
    else
      create_table :taggings do |t|
        t.references :tag
        t.references :taggable, polymorphic: true
        t.references :tagger,   polymorphic: true
        t.string :context, limit: 128
        t.datetime :created_at
      end
    end

    add_index :taggings, :tag_id unless index_exists?(:taggings, :tag_id)
    unless index_exists?(:taggings, [:taggable_id, :taggable_type, :context])
      add_index :taggings, [:taggable_id, :taggable_type, :context]
    end
  end

  def self.down
    # Do NOT drop tables that predate acts-as-taggable-on. Only remove the
    # columns this migration added.
    remove_column :taggings, :context     if column_exists?(:taggings, :context)
    remove_column :taggings, :tagger_id   if column_exists?(:taggings, :tagger_id)
    remove_column :taggings, :tagger_type if column_exists?(:taggings, :tagger_type)
  end
end
