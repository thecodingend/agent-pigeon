class WebConnectorsController < InertiaController
  def new
    authorize WebConnector
    render inertia: { web_connector: { name: "", description: "", urls: [ "" ] } }
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
    params.expect(web_connector: [ :name, :description, urls: [] ])
  end
end
