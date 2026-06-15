require "test_helper"

class ResendClientTest < ActiveSupport::TestCase
  test "creates sending domain with custom return path" do
    calls = []
    response = Resend::Response.new({
      id: "domain_123",
      name: "example.com",
      status: "pending",
      records: []
    }, {})

    with_resend_domains(
      create: ->(params) {
        calls << params
        response
      }
    ) do
      domain = ResendClient.new.create_or_find_sending_domain("example.com")

      assert_equal "domain_123", domain.fetch(:resend_domain_id)
      assert_equal "agentpigeon", calls.first.fetch("customReturnPath")
    end
  end

  test "finds existing domain after create conflict" do
    list_response = Resend::Response.new({
      data: [
        {
          "id" => "domain_existing",
          "name" => "example.com",
          "status" => "verified"
        }
      ]
    }, {})
    get_response = Resend::Response.new({
      id: "domain_existing",
      name: "example.com",
      status: "verified",
      records: []
    }, {})

    with_resend_domains(
      create: ->(_params) { raise Resend::Error, "The example.com domain has been registered already." },
      list: -> { list_response },
      get: ->(domain_id) {
        assert_equal "domain_existing", domain_id
        get_response
      }
    ) do
      domain = ResendClient.new.create_or_find_sending_domain("example.com")

      assert_equal "domain_existing", domain.fetch(:resend_domain_id)
      assert_equal "verified", domain.fetch(:status)
    end
  end

  test "does not recover from unrelated create errors" do
    error = assert_raises(ResendClient::Error) do
      with_resend_domains(
        create: ->(_params) { raise Resend::Error, "API key is invalid" }
      ) do
        ResendClient.new.create_or_find_sending_domain("example.com")
      end
    end

    assert_equal "API key is invalid", error.message
  end

  private

  def with_resend_domains(create: nil, list: nil, get: nil)
    original_create = Resend::Domains.method(:create)
    original_list = Resend::Domains.method(:list)
    original_get = Resend::Domains.method(:get)

    Resend::Domains.define_singleton_method(:create) { |params| create.call(params) } if create
    Resend::Domains.define_singleton_method(:list) { list.call } if list
    Resend::Domains.define_singleton_method(:get) { |domain_id| get.call(domain_id) } if get

    yield
  ensure
    Resend::Domains.define_singleton_method(:create, original_create)
    Resend::Domains.define_singleton_method(:list, original_list)
    Resend::Domains.define_singleton_method(:get, original_get)
  end
end
