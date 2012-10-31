class Permission

  def initialize(user)
    allow :audio_messages, [:show, :gold]
    allow :dates, [:index, :years, :year, :speaker, :show, :delivered]
    allow :errors, [:not_found, :error]
    allow :hymns, [:index, :show]
    allow :languages, [:index, :speakers, :show]
    allow :login, [:index, :login, :logout, :forgotten_password, :reset_password]
    allow :motms, [:index]
    allow :notes, [:index, :speaker, :show]
    allow :places, [:index, :speakers, :show]
    allow :speakers, [:index, :place, :language, :show]
    allow :tags, [:show]
    allow :user, [:register]
    allow :videos, [:index, :speaker, :show]
    allow :welcome, [:index, :thanks, :search, :contact, :about, :autocomplete, :search, :favicon]
    allow :writings, [:index, :speaker, :show]
    if user
      allow :user, [:index, :change_password, :update_password]
      #allow :audio_message, [:edit, :update] do |audio_message|
      #  audio_message.speaker_id = user.speaker_id
      #end
      allow_all if user.admin?
    end
  end

  def allow?(controller, action, resource = nil)
    allowed = @allow_all || @allowed_actions[[controller.to_s, action.to_s]]
    allowed && (allowed == true || resource && allowed.call(resource))
  end

  def allow_all
    @allow_all = true
  end

  def allow(controllers, actions, &block)
    @allowed_actions ||= {}
    Array(controllers).each do |controller|
      Array(actions).each do |action|
        @allowed_actions[[controller.to_s,action.to_s]] = block || true
      end
    end
  end


end
