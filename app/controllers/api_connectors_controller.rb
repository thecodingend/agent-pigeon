class ApiConnectorsController < InertiaController
  def new
    authorize ApiConnector
    render inertia: {
      api_connector: { name: "", description: "", base_url: "", http_method: "get", auth_token: "", request_example_text: "", response_example_text: "" }
    }
  end

  def create
    connector = current_user.api_connectors.new(api_connector_params)
    authorize connector

    if connector.save
      redirect_to data_sources_path, notice: "API source added."
    else
      redirect_back_or_to new_api_connector_path, inertia: { errors: connector.errors.to_hash(true) }
    end
  end

  def destroy
    connector = policy_scope(ApiConnector).find(params[:id])
    authorize connector
    connector.destroy
    redirect_to data_sources_path, notice: "API source removed."
  end

  private

  def api_connector_params
    params.expect(api_connector: [ :name, :description, :base_url, :http_method, :auth_token, :request_example_text, :response_example_text ])
  end
end
