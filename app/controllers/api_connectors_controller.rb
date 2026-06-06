class ApiConnectorsController < InertiaController
  def new
    authorize ApiConnector
    render inertia: {
      api_connector: {
        name: "",
        description: "",
        base_url: "",
        http_method: "get",
        auth_type: "bearer",
        request_example_text: "",
        response_example_text: "",
        query_schema_text: "",
        response_schema_text: "",
        timeout_seconds: ApiConnector::DEFAULT_TIMEOUT_SECONDS,
        max_response_bytes: ApiConnector::DEFAULT_MAX_RESPONSE_BYTES,
        enabled: true
      }
    }
  end

  def create
    connector = current_user.api_connectors.new(api_connector_params.merge(http_method: "get", auth_type: "bearer"))
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
    params.expect(api_connector: [
      :name,
      :description,
      :base_url,
      :auth_token,
      :request_example_text,
      :response_example_text,
      :query_schema_text,
      :response_schema_text,
      :timeout_seconds,
      :max_response_bytes,
      :enabled
    ])
  end
end
