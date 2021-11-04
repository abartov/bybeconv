# Base class for all service
# Exposes class method 'call', which creates new instance of service object and calls it with provided arguments.
# So instead of 'MyService.new.call(x, y)' we can use 'MyService.call(x, y)'
class ApplicationService
  def self.call(*args, &block)
    new.call(*args, &block)
  end
end
