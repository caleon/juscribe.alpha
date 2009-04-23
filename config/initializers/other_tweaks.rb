# The following is to allow either a model or its ID to be supplied as
# arguments to a method.
class Fixnum
  def to_id; self; end;
end

# this is for test_helper #as method
class PathHash < Hash
  def with(opts)
    opts.each {|key, val| self[key] = val }
    self
  end
end