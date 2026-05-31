class AddContextPolicyToAgents < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :context_policy, :integer, null: false, default: 0
  end
end
