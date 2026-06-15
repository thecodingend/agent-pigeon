# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_03_163314) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agent_api_connectors", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "api_connector_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "api_connector_id"], name: "index_agent_api_connectors_on_agent_id_and_api_connector_id", unique: true
    t.index ["agent_id"], name: "index_agent_api_connectors_on_agent_id"
    t.index ["api_connector_id"], name: "index_agent_api_connectors_on_api_connector_id"
  end

  create_table "agent_web_connectors", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "web_connector_id", null: false
    t.index ["agent_id", "web_connector_id"], name: "index_agent_web_connectors_on_agent_id_and_web_connector_id", unique: true
    t.index ["agent_id"], name: "index_agent_web_connectors_on_agent_id"
    t.index ["web_connector_id"], name: "index_agent_web_connectors_on_web_connector_id"
  end

  create_table "agents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "email_threads_count", default: 0, null: false
    t.integer "inbox_policy", default: 0, null: false
    t.datetime "last_activity_at"
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.text "system_prompt", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_agents_on_user_id"
  end

  create_table "allowlist_entries", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.string "pattern", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "pattern"], name: "index_allowlist_entries_on_agent_id_and_pattern", unique: true
    t.index ["agent_id"], name: "index_allowlist_entries_on_agent_id"
  end

  create_table "api_connectors", force: :cascade do |t|
    t.integer "agents_count", default: 0, null: false
    t.text "auth_token"
    t.string "base_url", null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.integer "http_method", default: 0, null: false
    t.string "name", null: false
    t.jsonb "request_example", default: {}, null: false
    t.jsonb "response_example", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_api_connectors_on_user_id"
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_thread_id"
    t.bigint "model_id"
    t.datetime "updated_at", null: false
    t.index ["email_thread_id"], name: "index_chats_on_email_thread_id"
    t.index ["model_id"], name: "index_chats_on_model_id"
  end

  create_table "email_connections", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.string "forwarding_address", null: false
    t.integer "forwarding_status", default: 0, null: false
    t.datetime "forwarding_verified_at"
    t.bigint "sending_domain_id", null: false
    t.string "support_address", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_email_connections_on_agent_id", unique: true
    t.index ["forwarding_address"], name: "index_email_connections_on_forwarding_address", unique: true
    t.index ["sending_domain_id"], name: "index_email_connections_on_sending_domain_id"
    t.index ["support_address"], name: "index_email_connections_on_support_address", unique: true
  end

  create_table "email_messages", force: :cascade do |t|
    t.jsonb "cc_emails", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.integer "direction", null: false
    t.bigint "email_thread_id", null: false
    t.string "from_email", null: false
    t.text "html"
    t.string "in_reply_to"
    t.bigint "message_id"
    t.string "mime_message_id"
    t.integer "provider", default: 0, null: false
    t.string "provider_message_id"
    t.jsonb "provider_payload", default: {}, null: false
    t.datetime "received_at"
    t.text "references_header", default: [], null: false, array: true
    t.string "subject", default: "", null: false
    t.text "text"
    t.jsonb "to_emails", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["email_thread_id", "created_at"], name: "index_email_messages_on_email_thread_id_and_created_at"
    t.index ["email_thread_id"], name: "index_email_messages_on_email_thread_id"
    t.index ["message_id"], name: "index_email_messages_on_message_id"
    t.index ["provider", "provider_message_id"], name: "index_email_messages_on_provider_and_provider_message_id", unique: true, where: "(provider_message_id IS NOT NULL)"
  end

  create_table "email_threads", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_activity_at", null: false
    t.text "participants", default: [], null: false, array: true
    t.string "root_message_id"
    t.string "subject", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "last_activity_at"], name: "index_email_threads_on_agent_id_and_last_activity_at", order: { last_activity_at: :desc }
    t.index ["agent_id"], name: "index_email_threads_on_agent_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "cache_creation_tokens"
    t.integer "cached_tokens"
    t.bigint "chat_id", null: false
    t.text "content"
    t.json "content_raw"
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.bigint "model_id"
    t.integer "output_tokens"
    t.string "role", null: false
    t.text "thinking_signature"
    t.text "thinking_text"
    t.integer "thinking_tokens"
    t.bigint "tool_call_id"
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["model_id"], name: "index_messages_on_model_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["tool_call_id"], name: "index_messages_on_tool_call_id"
  end

  create_table "models", force: :cascade do |t|
    t.jsonb "capabilities", default: []
    t.integer "context_window"
    t.datetime "created_at", null: false
    t.string "family"
    t.date "knowledge_cutoff"
    t.integer "max_output_tokens"
    t.jsonb "metadata", default: {}
    t.jsonb "modalities", default: {}
    t.datetime "model_created_at"
    t.string "model_id", null: false
    t.string "name", null: false
    t.jsonb "pricing", default: {}
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["capabilities"], name: "index_models_on_capabilities", using: :gin
    t.index ["family"], name: "index_models_on_family"
    t.index ["modalities"], name: "index_models_on_modalities", using: :gin
    t.index ["provider", "model_id"], name: "index_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_models_on_provider"
  end

  create_table "resend_webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at"
    t.integer "status", default: 0, null: false
    t.string "svix_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_resend_webhook_events_on_event_type"
    t.index ["status"], name: "index_resend_webhook_events_on_status"
    t.index ["svix_id"], name: "index_resend_webhook_events_on_svix_id", unique: true
  end

  create_table "sending_domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "dns_records", default: [], null: false
    t.string "hostname", null: false
    t.string "resend_domain_id", null: false
    t.string "return_path_label", default: "agentpigeon", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "verified_at"
    t.index ["hostname"], name: "index_sending_domains_on_hostname", unique: true
    t.index ["resend_domain_id"], name: "index_sending_domains_on_resend_domain_id", unique: true
    t.index ["user_id"], name: "index_sending_domains_on_user_id"
  end

  create_table "tool_calls", force: :cascade do |t|
    t.jsonb "arguments", default: {}
    t.datetime "created_at", null: false
    t.bigint "message_id", null: false
    t.string "name", null: false
    t.text "thought_signature"
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["name"], name: "index_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "((provider IS NOT NULL) AND (uid IS NOT NULL))"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_connectors", force: :cascade do |t|
    t.integer "agents_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.text "urls", default: [], null: false, array: true
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_web_connectors_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_api_connectors", "agents"
  add_foreign_key "agent_api_connectors", "api_connectors"
  add_foreign_key "agent_web_connectors", "agents"
  add_foreign_key "agent_web_connectors", "web_connectors"
  add_foreign_key "agents", "users"
  add_foreign_key "allowlist_entries", "agents"
  add_foreign_key "api_connectors", "users"
  add_foreign_key "chats", "email_threads"
  add_foreign_key "chats", "models"
  add_foreign_key "email_connections", "agents"
  add_foreign_key "email_connections", "sending_domains"
  add_foreign_key "email_messages", "email_threads"
  add_foreign_key "email_messages", "messages"
  add_foreign_key "email_threads", "agents"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "models"
  add_foreign_key "messages", "tool_calls"
  add_foreign_key "sending_domains", "users"
  add_foreign_key "tool_calls", "messages"
  add_foreign_key "web_connectors", "users"
end
