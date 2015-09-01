class AddAdminAndNameColumnsToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :name, :string
    add_column :agents, :admin, :boolean, default: false
  end
end
