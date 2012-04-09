require 'delegate'

##
# This class can be used to wrap an object so that any exceptions raised by the object's methods are recued and passed to a specified exception_handler block
#
class ExceptionCatchingDelegator < SimpleDelegator

  ##
  # * *Args* :
  #   - ++ -> delgate - object to be wrapped
  #   - ++ -> exception_handler - block to handle rescued exeptions (will be called with yield(exception))
  #
  def initialize(delegate, exception_handler)
    super(delegate)
    @exception_handler = exception_handler
  end

  ##
  # Override of method_missing to rescue exceptions and pass them to the exception_handler
  #
  def method_missing(m, *args, &block)
    begin
      return super(m, *args, &block)
    rescue Exception => exception
      @exception_handler.yield(exception)
    end
  end

end

##
# This class can be used to wrap an object so that exceptions matching a given type are rescued and then raised as another type.
#
# This kind of exception converting is most of use when dealing with exceptions passed across DRb where a remote
# exception class may not exist on the client-side.
#
class ExceptionConvertingDelegator < ExceptionCatchingDelegator
  
  ##
  # * *Args* :
  #   - ++ -> delgate - object to be wrapped
  #   - ++ -> exception_type_to_catch - an exception class or name of an exception class that will be used to match (in a regular-expression sense) the name of exceptions thrown by the delegate's methods
  #   - ++ -> exception_type_to_throw - the exception class that will be used to create and raise a new exception
  #
  def initialize(delegate, exception_type_to_catch = Exception, exception_type_to_throw = RuntimeError)

    handler = lambda do |e|
      
      raise e unless e.class.name =~ Regexp.new(exception_type_to_catch.to_s)
      
      # Create and raise a RuntimeError
      message = e.class.name
      unless e.message.nil? || e.message.size == 0
        message << " "
        message << e.message
      end
      new_exception = exception_type_to_throw.new(message)
      new_exception.set_backtrace(e.backtrace)
      raise new_exception
    end

    super(delegate, handler)

  end

end
