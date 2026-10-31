class ConfirmExistingUsers < ActiveRecord::Migration[8.1]
  def up
    execute 'UPDATE users SET confirmed_at = created_at WHERE confirmed_at IS NULL'
  end

  # The column was already there, and code without :confirmable ignores it.
  def down
  end
end
