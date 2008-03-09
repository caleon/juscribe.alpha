class EntriesController < ApplicationController
  def initialize(*args)
    @klass = Entry
    @plural_sym = "entries"
    @instance_name = 'entry'
    @instance_str = 'entry'
    @instance_sym = "@entry"
  end
end
