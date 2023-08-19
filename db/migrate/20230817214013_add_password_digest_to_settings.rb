class AddPasswordDigestToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :password_digest, :string
  end
end
