class AgentsController < InertiaController
  EMAIL_LOCAL_PART_OPTIONS = %w[help support hello ops sales billing].freeze
  PROMPT_TEMPLATES = [
    {
      key: "support",
      name: "Support",
      system_prompt: "You are a helpful support agent. Read the full email thread before replying, answer clearly, and use attached tools only when they can improve accuracy. If a customer asks for something you cannot verify, say what information is missing and ask one concise follow-up question."
    },
    {
      key: "ops",
      name: "Operations",
      system_prompt: "You are an operations assistant. Triage incoming requests, identify the next action, and keep replies practical and brief. Use connected sources to check facts before making commitments, and call out blockers plainly."
    },
    {
      key: "sales_research",
      name: "Sales research",
      system_prompt: "You are a sales research assistant. Help qualify leads and prepare useful replies by looking for relevant company, contact, and product context in the connected sources. Keep responses specific, professional, and easy to forward."
    },
    {
      key: "custom",
      name: "Custom",
      system_prompt: ""
    }
  ].freeze

  before_action :set_agent, only: [ :show, :edit, :update, :destroy ]
  before_action :require_verified_domain, only: [ :new, :create ]

  def index
    agents = policy_scope(Agent).includes(:domain).order(:name).map { |a| serialize_agent(a) }
    render inertia: { agents: agents }
  end

  def new
    authorize Agent
    agent = current_user.agents.new(domain: current_user.domain)
    render inertia: {
      agent: serialize_agent_for_form(agent),
      domain: serialize_domain(current_user.domain),
      email_options: email_options_for(agent),
      prompt_templates: PROMPT_TEMPLATES,
      connectors: connector_picker_options
    }
  end

  def create
    agent = current_user.agents.new(agent_params.merge(domain: current_user.domain))
    authorize agent
    attach_connectors(agent)
    sync_allowlist(agent, params.dig(:agent, :allowlist_patterns))

    if agent.save
      redirect_to agent_path(agent), notice: "Agent created. Send a note to #{agent.email_address} to start a thread."
    else
      redirect_back_or_to new_agent_path, inertia: { errors: agent.errors.to_hash(true) }
    end
  end

  def show
    threads = @agent.email_threads.includes(:email_messages).limit(100).map do |thread|
      {
        id: thread.id,
        subject: thread.subject.presence || "(no subject)",
        last_sender: thread.last_sender,
        snippet: thread.snippet,
        last_activity_at: thread.last_activity_at,
        message_count: thread.email_messages.size
      }
    end
    render inertia: { agent: serialize_agent(@agent), threads: threads }
  end

  def edit
    render inertia: {
      agent: serialize_agent_for_form(@agent),
      domain: serialize_domain(current_user.domain),
      email_options: email_options_for(@agent),
      prompt_templates: PROMPT_TEMPLATES,
      connectors: connector_picker_options
    }
  end

  def update
    attach_connectors(@agent)
    sync_allowlist(@agent, params.dig(:agent, :allowlist_patterns))

    if @agent.update(agent_params)
      redirect_to agent_path(@agent), notice: "Agent updated."
    else
      redirect_back_or_to edit_agent_path(@agent), inertia: { errors: @agent.errors.to_hash(true) }
    end
  end

  def destroy
    @agent.destroy
    redirect_to agents_path, notice: "Agent removed."
  end

  private

  def set_agent
    @agent = policy_scope(Agent).find(params[:id])
    authorize @agent
  end

  def require_verified_domain
    return if current_user.domain_verified?
    redirect_to domain_path, alert: "Verify a domain first — your pigeon needs an address."
  end

  def agent_params
    params.expect(agent: [ :name, :local_part, :system_prompt, :status, :inbox_policy, :context_policy ])
  end

  def attach_connectors(agent)
    if (ids = params.dig(:agent, :api_connector_ids))
      owned = policy_scope(ApiConnector).where(id: ids).ids
      agent.agent_api_connectors = owned.map { |id| AgentApiConnector.new(api_connector_id: id) }
    end
    if (ids = params.dig(:agent, :web_connector_ids))
      owned = policy_scope(WebConnector).where(id: ids).ids
      agent.agent_web_connectors = owned.map { |id| AgentWebConnector.new(web_connector_id: id) }
    end
  end

  def sync_allowlist(agent, patterns)
    return if patterns.nil?
    cleaned = Array(patterns).map { |p| p.to_s.strip }.reject(&:blank?).uniq
    agent.allowlist_entries = cleaned.map { |pattern| AllowlistEntry.new(pattern: pattern) }
  end

  def connector_picker_options
    api = policy_scope(ApiConnector).order(:name).map do |c|
      { id: c.id, kind: "api", name: c.name, description: c.description, summary: "#{c.http_method.upcase} #{c.base_url}" }
    end
    web = policy_scope(WebConnector).order(:name).map do |c|
      { id: c.id, kind: "web", name: c.name, description: c.description, summary: "#{c.urls.size} #{'URL'.pluralize(c.urls.size)}" }
    end
    { api: api, web: web }
  end

  def email_options_for(agent)
    domain = agent.domain || current_user.domain
    taken = current_user.agents.where(domain: domain).where.not(id: agent.id).pluck(:local_part)
    local_parts = (EMAIL_LOCAL_PART_OPTIONS + current_user.agents.where(domain: domain).pluck(:local_part) + [ agent.local_part ]).compact.reject(&:blank?).uniq

    local_parts.map do |local_part|
      current = local_part == agent.local_part
      {
        local_part: local_part,
        email_address: "#{local_part}@#{domain.hostname}",
        available: current || !taken.include?(local_part),
        current: current
      }
    end
  end

  def serialize_agent(agent)
    {
      id: agent.id,
      name: agent.name,
      local_part: agent.local_part,
      email_address: agent.local_part.present? ? agent.email_address : nil,
      status: agent.status,
      inbox_policy: agent.inbox_policy,
      context_policy: agent.context_policy,
      system_prompt: agent.system_prompt,
      created_at: agent.created_at,
      threads_count: agent.email_threads_count,
      last_activity_at: agent.last_activity_at
    }
  end

  def serialize_agent_for_form(agent)
    serialize_agent(agent).merge(
      api_connector_ids: agent.persisted? ? agent.agent_api_connectors.pluck(:api_connector_id) : [],
      web_connector_ids: agent.persisted? ? agent.agent_web_connectors.pluck(:web_connector_id) : [],
      allowlist_patterns: agent.persisted? ? agent.allowlist_entries.order(:id).pluck(:pattern) : []
    )
  end

  def serialize_domain(domain)
    return nil unless domain
    { hostname: domain.hostname, status: domain.status, verified: domain.verified? }
  end
end
