class ResendClient
  Error = Class.new(StandardError)

  def create_or_find_sending_domain(hostname)
    domain_response(Resend::Domains.create(
      name: hostname,
      "customReturnPath" => SendingDomain::RETURN_PATH_LABEL
    ))
  rescue Resend::Error => error
    raise Error, error.message unless error.message.include?("domain has been registered already")

    find_sending_domain(hostname) || raise(Error, error.message)
  end

  def verify_sending_domain(resend_domain_id)
    Resend::Domains.verify(resend_domain_id)
    true
  rescue Resend::Error => error
    raise Error, error.message
  end

  private

  def find_sending_domain(hostname)
    response = Resend::Domains.list
    domains = response.to_h.fetch(:data)
    match = domains.find { |domain| domain.fetch("name") == hostname }
    domain_response(Resend::Domains.get(match.fetch("id"))) if match
  rescue Resend::Error => error
    raise Error, error.message
  end

  def domain_response(response)
    data = response.to_h
    {
      resend_domain_id: data.fetch(:id),
      hostname: data.fetch(:name),
      status: SendingDomain.status_from_resend(data.fetch(:status)),
      dns_records: data.fetch(:records)
    }
  end

end
