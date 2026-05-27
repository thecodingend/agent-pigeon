class DataSourcesController < InertiaController
  def index
    api_sources = policy_scope(ApiConnector).order(:name).map do |c|
      { id: c.id, name: c.name, description: c.description, kind: "api", http_method: c.http_method, base_url: c.base_url, agent_count: c.agents_count }
    end
    web_sources = policy_scope(WebConnector).order(:name).map do |c|
      { id: c.id, name: c.name, description: c.description, kind: "web", urls: c.urls, agent_count: c.agents_count }
    end

    render inertia: { api_sources: api_sources, web_sources: web_sources }
  end
end
