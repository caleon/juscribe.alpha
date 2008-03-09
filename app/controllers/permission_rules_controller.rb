class PermissionRulesController < ApplicationController
  # TODO: view lets you MERGE parts of each of the rules. Need to feed model attrs hash.
  
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
    @klass = PermissionRule
    @plural_sym = "permission_rules"
    @instance_name = 'permission'
    @instance_str = 'permission'
    @instance_sym = "@permission"
  end
end
