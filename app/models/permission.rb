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
    allow :users, [:new,:register]
    allow :videos, [:index, :speaker, :show]
    allow :welcome, [:index, :thanks, :search, :contact, :about, :autocomplete, :search, :favicon, :news, :advanced, :advanced_search]
    allow :writings, [:index, :speaker, :show]
    
    if user
      if user.admin?
        allow_all
      else
        allow :users, [:index, :change_password, :update_password]
        if user.audio_message_editor?
          allow :audio_messages, [:edit, :update]
          allow_param :audio_message, [:title, :subj, :speaker_id, :place_id, :publish, :event_date, :language_id]
        end
        if user.speaker_editor?
          allow :speakers, [:edit, :update]
          allow_param :speaker, [:first_name, :last_name, :middle_name, :suffix, :picture_file, :bio]
        end
        if user.place_editor?
          allow :places, [:edit, :update]
          allow_param :place, [:name, :cc, :picture_file, :bio]
        end
        if user.video_editor?
          allow :videos, [:edit, :update]
          allow_param :video, [:title]
        end
        if user.tags_editor?
          #allow :tags, [:edit, :update, :create]
        end
      end
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

  def allow_param(resources, attributes)
    @allowed_params ||= {}
    Array(resources).each do |resource|
      @allowed_params[resource.to_s] ||= []
      @allowed_params[resource.to_s] += Array(attributes).map(&:to_s)
    end
  end

  def allow_param?(resource, attribute)
    if @allow_all
      true 
    elsif @allowed_params && @allowed_params[resource.to_s]
      @allowed_params[resource.to_s].include? attribute.to_s
    end
  end

  def permit_params!(params)
    if @allow_all
      params.permit!
    elsif @allowed_params
      @allowed_params.each do |resource, attributes|
        if params[resource].respond_to? :permit
          params[resource] = params[resource].permit(*attributes)
        end
      end
    end
  end

end
