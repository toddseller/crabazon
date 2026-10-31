class LowercaseCategoryNames < ActiveRecord::Migration[8.1]
  def up
    execute 'UPDATE categories SET name = lower(trim(name))'
  end

  # The live names were all title case, which initcap restores exactly.
  def down
    execute 'UPDATE categories SET name = initcap(name)'
  end
end
