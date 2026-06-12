class WebConnectorsController < InertiaController
  def new
    authorize WebConnector
    render inertia: {
      web_connector: {
        name: "",
        description: "",
        urls: [ "" ],
        max_depth: WebConnector::DEFAULT_MAX_DEPTH,
        max_pages: WebConnector::DEFAULT_MAX_PAGES,
        delay_seconds: WebConnector::DEFAULT_DELAY_SECONDS,
        concurrency: WebConnector::DEFAULT_CONCURRENCY,
        allow_pdfs: false
      }
    }
  end

  def create
    connector = current_user.web_connectors.new(web_connector_params)
    authorize connector

    if connector.save
      redirect_to data_sources_path, notice: "Web source added."
    else
      redirect_back_or_to new_web_connector_path, inertia: { errors: connector.errors.to_hash(true) }
    end
  end

  def destroy
    connector = policy_scope(WebConnector).find(params[:id])
    authorize connector
    connector.destroy
    redirect_to data_sources_path, notice: "Web source removed."
  end

  private

  def web_connector_params
    params.expect(web_connector: [ :name, :description, :max_depth, :max_pages, :delay_seconds, :concurrency, :allow_pdfs, urls: [] ])
  end
end
