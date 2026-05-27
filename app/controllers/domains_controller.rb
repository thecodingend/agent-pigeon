class DomainsController < InertiaController
  def show
    domain = current_user.domain
    authorize(domain) if domain

    payload = domain && {
      hostname: domain.hostname,
      status: domain.status,
      verified: domain.verified?,
      verified_at: domain.verified_at,
      dns_records: domain.dns_records,
      created_at: domain.created_at
    }
    render inertia: { domain: payload }
  end

  def create
    domain = current_user.build_domain(domain_params)
    authorize domain

    if domain.save
      redirect_to domain_path, notice: "Add the DNS records below at your DNS provider, then re-check."
    else
      redirect_back_or_to domain_path, inertia: { errors: domain.errors.to_hash(true) }
    end
  end

  def update
    domain = current_user.domain
    if domain.nil?
      redirect_to domain_path, alert: "No domain to verify."
      return
    end
    authorize domain

    # Skeleton: pretend we re-checked with Resend and it came back verified.
    domain.update!(status: :verified, verified_at: Time.current)
    redirect_to domain_path, notice: "Domain verified. Your pigeons can now fly."
  end

  def destroy
    domain = current_user.domain
    return redirect_to domain_path, notice: "Domain disconnected." if domain.nil?

    authorize domain
    domain.destroy
    redirect_to domain_path, notice: "Domain disconnected."
  end

  private

  def domain_params
    params.expect(domain: [ :hostname ])
  end
end
