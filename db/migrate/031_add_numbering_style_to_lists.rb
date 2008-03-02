class AddNumberingStyleToLists < ActiveRecord::Migration
  def self.up
    # refers to numbering style, i.e. cardinal, ordinal, roman, none, dotted
    add_column :lists, :style, :string
  end

  def self.down
    remove_column :lists, :style
  end
end
