# Development-only stub for thinking-sphinx.
#
# Sphinx 2.2.x (what thinking-sphinx 3.x targets) has no arm64 build, so it
# can't run in the Apple Silicon dev container. Production is x86_64 and runs
# real Sphinx, so this stub is strictly a dev convenience: it makes
# AudioMessage.search return an empty paginated collection instead of raising
# a connection error, so search-dependent pages render while developing.
#
# Remove (or it simply won't apply) in production, where real Sphinx answers.
if Rails.env.development?
  module SphinxDevStub
    def search(*args)
      opts     = args.last.is_a?(Hash) ? args.last : {}
      page     = (opts[:page] || 1).to_i
      per_page = (opts[:per_page] || 30).to_i
      Rails.logger.warn("[sphinx stub] #{name}.search stubbed empty (no Sphinx daemon in dev)")
      WillPaginate::Collection.new(page, per_page, 0)
    end
  end

  Rails.application.config.to_prepare do
    AudioMessage.singleton_class.prepend(SphinxDevStub) unless
      AudioMessage.singleton_class.include?(SphinxDevStub)
  end
end
