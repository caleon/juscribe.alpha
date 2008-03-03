# The following is to allow either a model or its ID to be supplied as
# arguments to a method.
class Fixnum
  def to_id; self; end;
end
