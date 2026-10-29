# Development-only stub for thinking-sphinx.
#
# Sphinx 2.2.x (what thinking-sphinx 3.x targets) has no arm64 build, so it
# can't run in the Apple Silicon dev container. Production is x86_64 and runs
# real Sphinx, so this stub is strictly a dev convenience: it makes
# AudioMessage.search return an empty paginated collection instead of raising
# a connection error, so search-dependent pages render while developing.
#
# In development it goes one step further and answers listing pages (speaker,
# place, language, ...) from MySQL: the `:with` attribute filters, a title/
# subject LIKE for any query text, and the Sphinx-style `:order` mapped to
# SQL. It is not Sphinx (no stemming or relevance), just enough to click
# around. Tests keep the empty result so they don't depend on it.
#
# Remove (or it simply won't apply) in production, where real Sphinx answers.
if Rails.env.development? || Rails.env.test?
  module SphinxDevStub
    SORT_SQL = {
      'full_title'   => 'audio_messages.title',
      'speaker_name' => 'speakers.last_name %s, speakers.first_name',
      'place'        => 'places.name',
      'language'     => 'languages.name',
      'event_date'   => 'audio_messages.event_date',
      'filesize'     => 'audio_messages.filesize',
      'duration'     => 'audio_messages.duration',
    }

    def search(*args)
      opts     = args.last.is_a?(Hash) ? args.last : {}
      page     = (opts[:page] || 1).to_i
      per_page = (opts[:per_page] || 20).to_i
      return WillPaginate::Collection.new(page, per_page, 0) if Rails.env.test?
      Rails.logger.warn("[sphinx stub] #{name}.search answered from MySQL (no Sphinx daemon in dev)")

      # Search appends Sphinx "*" wildcards to each word; LIKE doesn't need them.
      query = args.first.is_a?(String) ? args.first.delete('*').strip : ''
      scope = where(publish: true).left_joins(:speaker, :place, :language)
      (opts[:with] || {}).each do |attr, value|
        if column_names.include?(attr.to_s)
          scope = scope.where(attr => value)
        else
          Rails.logger.warn("[sphinx stub] ignoring unsupported filter #{attr}")
        end
      end
      unless query.empty?
        like = "%#{sanitize_sql_like(query)}%"
        scope = scope.where('audio_messages.title LIKE ? OR audio_messages.subj LIKE ?', like, like)
      end
      scope.order(Arel.sql(sql_order(opts[:order])))
           .includes(opts.dig(:sql, :include) || [])
           .paginate(page: page, per_page: per_page)
    end

    private

    # "speaker_name asc, full_title asc" -> SQL, skipping unknown fields.
    def sql_order(order)
      parts = order.to_s.split(',').map do |part|
        field, dir = part.split
        dir = dir.to_s.downcase == 'desc' ? 'DESC' : 'ASC'
        sql = SORT_SQL[field]
        next unless sql
        sql.include?('%s') ? "#{sql % dir} #{dir}" : "#{sql} #{dir}"
      end.compact
      parts.empty? ? 'speakers.last_name ASC, audio_messages.title ASC' : parts.join(', ')
    end
  end

  Rails.application.config.to_prepare do
    AudioMessage.singleton_class.prepend(SphinxDevStub) unless
      AudioMessage.singleton_class.include?(SphinxDevStub)
  end
end
