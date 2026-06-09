require "test_helper"

class AgentsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    sign_in @user
  end

  test "new page includes setup defaults and picker data" do
    domain = verified_domain("new-agent.example")
    existing = @user.agents.create!(domain: domain, name: "Help", local_part: "help")
    api = @user.api_connectors.create!(name: "Customers", base_url: "https://api.example.com/customers")
    web = @user.web_connectors.create!(name: "Docs", urls: [ "https://docs.example.com/start" ])

    get new_agent_path

    assert_inertia_response
    assert_inertia_component "agents/new"

    props = inertia.props.deep_symbolize_keys
    assert_equal "thread_history", props[:agent][:context_policy]
    assert_equal %w[support ops sales_research custom], props[:prompt_templates].map { |template| template[:key] }
    assert_equal [ api.id ], props[:connectors][:api].map { |connector| connector[:id] }
    assert_equal [ web.id ], props[:connectors][:web].map { |connector| connector[:id] }

    help = props[:email_options].find { |option| option[:local_part] == existing.local_part }
    assert_not help[:available]
    assert_not help[:current]
  end

  test "creates an agent with prompt tools allowlist and context policy" do
    domain = verified_domain("create-agent.example")
    api = @user.api_connectors.create!(name: "Customers", base_url: "https://api.example.com/customers")
    web = @user.web_connectors.create!(name: "Docs", urls: [ "https://docs.example.com/start" ])

    assert_difference "Agent.count", 1 do
      post agents_path, params: {
        agent: {
          name: "Ops",
          local_part: "ops",
          system_prompt: "Handle operational requests.",
          status: "active",
          inbox_policy: "allowlist",
          context_policy: "last_message_only",
          api_connector_ids: [ api.id ],
          web_connector_ids: [ web.id ],
          allowlist_patterns: [ "ADA@example.com", "@Example.com", "" ]
        }
      }
    end

    agent = @user.agents.order(:created_at).last
    assert_redirected_to agent_path(agent)
    assert_equal domain, agent.domain
    assert_equal "Ops", agent.name
    assert_equal "ops", agent.local_part
    assert_equal "Handle operational requests.", agent.system_prompt
    assert_equal "allowlist", agent.inbox_policy
    assert_equal "last_message_only", agent.context_policy
    assert_equal [ api.id ], agent.api_connectors.ids
    assert_equal [ web.id ], agent.web_connectors.ids
    assert_equal [ "@example.com", "ada@example.com" ], agent.allowlist_entries.order(:pattern).pluck(:pattern)
  end

  test "edit page preselects current agent settings" do
    domain = verified_domain("edit-agent.example")
    occupied = @user.agents.create!(domain: domain, name: "Help", local_part: "help")
    agent = @user.agents.create!(
      domain: domain,
      name: "Ops",
      local_part: "ops",
      system_prompt: "Handle ops.",
      inbox_policy: "allowlist",
      context_policy: "last_message_only",
    )
    agent.allowlist_entries.create!(pattern: "@example.com")
    api = @user.api_connectors.create!(name: "Customers", base_url: "https://api.example.com/customers")
    web = @user.web_connectors.create!(name: "Docs", urls: [ "https://docs.example.com/start" ])
    agent.api_connectors << api
    agent.web_connectors << web

    get edit_agent_path(agent)

    assert_inertia_response
    assert_inertia_component "agents/edit"

    props = inertia.props.deep_symbolize_keys
    assert_equal "last_message_only", props[:agent][:context_policy]
    assert_equal [ api.id ], props[:agent][:api_connector_ids]
    assert_equal [ web.id ], props[:agent][:web_connector_ids]
    assert_equal [ "@example.com" ], props[:agent][:allowlist_patterns]

    current = props[:email_options].find { |option| option[:local_part] == agent.local_part }
    claimed = props[:email_options].find { |option| option[:local_part] == occupied.local_part }
    assert current[:current]
    assert current[:available]
    assert_not claimed[:current]
    assert_not claimed[:available]
  end

  test "cannot claim an existing address on the same domain" do
    domain = verified_domain("duplicate-agent.example")
    @user.agents.create!(domain: domain, name: "Help", local_part: "help")

    assert_no_difference "Agent.count" do
      post agents_path, params: {
        agent: {
          name: "Second help",
          local_part: "help",
          system_prompt: "Reply carefully.",
          status: "active",
          inbox_policy: "open",
          context_policy: "thread_history"
        }
      }
    end

    assert_redirected_to new_agent_path
  end

  private

  def verified_domain(hostname)
    @user.create_domain!(hostname: hostname, status: :verified, verified_at: Time.current)
  end
end
