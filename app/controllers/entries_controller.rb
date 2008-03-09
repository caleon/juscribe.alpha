class EntriesController < ApplicationController
  
  def index
    super
  end
  
  def show
    super
  end
  
  def new
    super
  end
  
  def create
    super
  end
  
  def edit
    super
  end
  
  def update
    super
  end
  
  def destroy
    super
  end
  
  private
  def run_initialize
    @klass = Entry
    @plural_sym = "entries"
    @instance_name = 'entry'
    @instance_str = 'entry'
    @instance_sym = "@entry"
  end
end
