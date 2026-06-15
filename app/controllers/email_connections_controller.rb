class EmailConnectionsController < InertiaController
  def show
    render inertia: { email_connection: serialize_connection(current_email_connection) }
  end

  def create
    authorize EmailConnection

    support_address = email_connection_params[:support_address].to_s.downcase.strip
    hostname = EmailConnection.domain_from(support_address)

    if hostname.blank?
      redirect_back_or_to email_connection_path, inertia: { errors: { support_address: [ "Support address is invalid" ] } }
      return
    end

    if current_email_connection
      redirect_to email_connection_path, alert: "Email connection already exists."
      return
    end

    sending_domain = current_user.sending_domains.find_by(hostname: hostname)
    unless sending_domain
      domain_attrs = ResendClient.new.create_or_find_sending_domain(hostname)
    end

    agent = current_user.agents.first_or_initialize(name: "Support")

    ActiveRecord::Base.transaction do
      agent.save! if agent.new_record?
      sending_domain ||= current_user.sending_domains.create!(
        hostname: domain_attrs.fetch(:hostname),
        resend_domain_id: domain_attrs.fetch(:resend_domain_id),
        status: domain_attrs.fetch(:status),
        dns_records: domain_attrs.fetch(:dns_records),
        return_path_label: SendingDomain::RETURN_PATH_LABEL
      )
      agent.create_email_connection!(
        sending_domain: sending_domain,
        support_address: support_address
      )
    end

    redirect_to email_connection_path, notice: "Email connection started."
  rescue ResendClient::Error
    redirect_back_or_to email_connection_path, alert: "We could not create the sending domain. Try again, or contact support if it keeps happening."
  rescue ActiveRecord::RecordInvalid => error
    redirect_back_or_to email_connection_path, inertia: { errors: error.record.errors.to_hash(true) }
  end

  def update
    connection = current_email_connection
    return redirect_to email_connection_path, alert: "Add a support address first." unless connection

    authorize connection

    if connection.update(update_params.merge(forwarding_status: :needs_forwarding, forwarding_verified_at: nil))
      redirect_to email_connection_path, notice: "Support address updated. Send a new test email to prove forwarding works."
    else
      redirect_back_or_to email_connection_path, inertia: { errors: connection.errors.to_hash(true) }
    end
  end

  def check_dns
    connection = current_email_connection
    return redirect_to email_connection_path, alert: "Add a support address first." unless connection

    authorize connection

    ResendClient.new.verify_sending_domain(connection.sending_domain.resend_domain_id)
    connection.sending_domain.checking! unless connection.sending_domain.verified?

    redirect_to email_connection_path, notice: "DNS check started. Refresh this page after Resend updates the status."
  rescue ResendClient::Error
    redirect_to email_connection_path, alert: "We could not check DNS records. Try again in a few minutes."
  end

  private

  def current_email_connection
    current_user.email_connection
  end

  def email_connection_params
    params.expect(email_connection: [ :support_address ])
  end

  def update_params
    params.expect(email_connection: [ :support_address ])
  end

  def serialize_connection(connection)
    return nil unless connection

    sending_domain = connection.sending_domain
    {
      support_address: connection.support_address,
      forwarding_address: connection.forwarding_address,
      forwarding_status: connection.forwarding_status,
      forwarding_ready: connection.ready?,
      forwarding_verified_at: connection.forwarding_verified_at,
      complete: connection.complete?,
      sending_domain: {
        hostname: sending_domain.hostname,
        status: sending_domain.status,
        verified: sending_domain.verified?,
        verified_at: sending_domain.verified_at,
        dns_records: sending_domain.dns_records,
        return_path_label: sending_domain.return_path_label
      }
    }
  end
end
