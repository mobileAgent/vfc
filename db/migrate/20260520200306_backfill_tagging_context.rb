# Backfill migration for the acts_as_taggable_on_steroids ->
# acts-as-taggable-on transition.
#
# acts_as_taggable_on_steroids stored taggings with no `context`.
# acts-as-taggable-on namespaces every tagging by context (default 'tags')
# and filters all queries by it, so existing taggings with NULL context
# become invisible until backfilled.
#
# IMPORTANT: this migration MUST run after the acts-as-taggable-on
# install migrations (which add the `context` column and `taggings_count`).
# Its timestamp must be higher than all of those. If you run
# `rake acts_as_taggable_on_engine:install:migrations` and it produces
# migrations with a timestamp later than this file's, rename this file to
# a later timestamp so it sorts last.
class BackfillTaggingContext < ActiveRecord::Migration
  def up
    # Assign the default context to all pre-existing taggings.
    execute "UPDATE taggings SET context = 'tags' WHERE context IS NULL"

    # Rebuild the taggings_count counter cache on each tag so tag clouds
    # and "most used" ordering reflect reality.
    if defined?(ActsAsTaggableOn::Tag)
      ActsAsTaggableOn::Tag.reset_column_information
      ActsAsTaggableOn::Tag.find_each do |tag|
        ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
      end
    end
  end

  def down
    # Data-only, non-destructive. Nothing meaningful to reverse.
    raise ActiveRecord::IrreversibleMigration
  end
end
