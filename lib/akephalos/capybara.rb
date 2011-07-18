# Driver class exposed to Capybara. It implements Capybara's full driver API,
# and is the entry point for interaction between the test suites and HtmlUnit.
#
# This class and +Capybara::Driver::Akephalos::Node+ are written to run on both
# MRI and JRuby, and is agnostic whether the Akephalos::Client instance is used
# directly or over DRb.
class Capybara::Driver::Akephalos < Capybara::Driver::Base

  # Akephalos-specific implementation for Capybara's Driver::Node class.
  class Node < Capybara::Driver::Node

    # @api capybara
    # @return [String] the inner text of the node
    def text
      native.text
    end

    # @api capybara
    # @param [String] name attribute name
    # @return [String] the attribute value
    def [](name)
      name = name.to_s
      case name
      when 'checked'
        native.checked?
      else
        native[name.to_s]
      end
    end

    # @api capybara
    # @return [String, Array<String>] the form element's value
    def value
      native.value
    end

    # Set the form element's value.
    #
    # @api capybara
    # @param [String] value the form element's new value
    def set(value)
      if tag_name == 'textarea'
        native.value = value.to_s
      elsif tag_name == 'input' and type == 'radio'
        click
      elsif tag_name == 'input' and type == 'checkbox'
        if value != self['checked']
          click
        end
      elsif tag_name == 'input'
        native.value = value.to_s
      end
    end

    # @api capybara
    def select_option
      native.click
    end

    # Unselect an option from a select box.
    #
    # @api capybara
    def unselect_option
      unless select_node.multiple_select?
        raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
      end

      native.unselect
    end

    # Click the element.
    def click
      native.click
    end

    # Drag the element on top of the target element.
    #
    # @api capybara
    # @param [Node] element the target element
    def drag_to(element)
      trigger('mousedown')
      element.trigger('mousemove')
      element.trigger('mouseup')
    end

    # @api capybara
    # @return [String] the element's tag name
    def tag_name
      native.tag_name
    end

    # @api capybara
    # @return [true, false] the element's visiblity
    def visible?
      native.visible?
    end

    # @api capybara
    # @return [true, false] the element's visiblity
    def checked?
      native.checked?
    end

    # @api capybara
    # @return [true, false] the element's visiblity
    def selected?
      native.selected?
    end

    # @api capybara
    # @return [String] the XPath to locate the node
    def path
      native.xpath
    end

    # Trigger an event on the element.
    #
    # @api capybara
    # @param [String] event the event to trigger
    def trigger(event)
      native.fire_event(event.to_s)
    end

    # @api capybara
    # @param [String] selector XPath query
    # @return [Array<Node>] the matched nodes
    def find(selector)
      nodes = []
      native.find(selector).each { |node| nodes << self.class.new(self, node) }
      nodes
    end

    protected

    # @return [true, false] whether the node allows multiple-option selection (if the node is a select).
    def multiple_select?
      tag_name == "select" && native.multiple_select?
    end

    private

    # Return all child nodes which match the selector criteria.
    #
    # @api capybara
    # @return [Array<Node>] the matched nodes
    def all_unfiltered(selector)
      nodes = []
      native.find(selector).each { |node| nodes << self.class.new(driver, node) }
      nodes
    end

    # @return [String] the node's type attribute
    def type
      native[:type]
    end

    # @return [Node] the select node, if this is an option node
    def select_node
      find('./ancestor::select').first
    end
  end

  attr_reader :app, :rack_server, :options

  # Creates a new instance of the Akephalos Driver for Capybara. The driver is
  # registered with Capybara by a name, so that it can be chosen when
  # Capybara's javascript_driver is changed. By default, Akephalos is
  # registered like this:
  #
  #   Capybara.register_driver :akephalos do |app|
  #     Capybara::Akephalos::Driver.new(
  #       app,
  #       :browser => :firefox_3_6,
  #       :validate_scripts => true
  #     )
  #   end
  #
  # @param app the Rack application to run
  # @param [Hash] options the Akephalos configuration options
  # @option options [Symbol] :browser (:firefox_3_6) the browser
  #   compatibility mode to run in. Available options:
  #       :firefox_3_6
  #       :firefox_3
  #       :ie6
  #       :ie7
  #       :ie8
  #
  # @option options [true, false] :validate_scripts (true) whether to raise
  #   exceptions on script errors
  #
  def initialize(app, options = {})
    @app = app
    @options = options
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  # Visit the given path in the browser.
  #
  # @param [String] path relative path to visit
  def visit(path)
    browser.visit(url(path))
  end

  # @return [String] the page's original source
  def source
    page.source
  end

  # @return [String] the page's modified source
  # page.modified_source will return a string with
  # html entities converted into the unicode equivalent
  # but the string will be marked as ASCII-8BIT
  # which causes conversion issues so we force the encoding
  # to UTF-8 (ruby 1.9 only)
  def body
    body_source = page.modified_source

    if body_source.respond_to?(:force_encoding)
      body_source.force_encoding("UTF-8")
    else
      body_source
    end
  end

  # @return [Hash{String => String}] the page's response headers
  def response_headers
    page.response_headers
  end

  # @return [Integer] the response's status code
  def status_code
    page.status_code
  end

  # Execute the given block within the context of a specified frame.
  #
  # @param [String] frame_id the frame's id
  # @raise [Capybara::ElementNotFound] if the frame is not found
  def within_frame(frame_id, &block)
    unless page.within_frame(frame_id, &block)
      raise Capybara::ElementNotFound, "Unable to find frame with id '#{frame_id}'"
    end
  end

  # Clear all cookie session data.
  # @deprecated This method is deprecated in Capybara's master branch. Use
  #   {#reset!} instead.
  def cleanup!
    reset!
  end

  # Clear all cookie session data.
  def reset!
    cookies.clear
  end

  # Confirm or cancel the dialog, returning the text of the dialog
  def confirm_dialog(confirm = true, &block)
    browser.confirm_dialog(confirm, &block)
  end

  # @return [String] the page's current URL
  def current_url
    page.current_url
  end

  # Search for nodes which match the given XPath selector.
  #
  # @param [String] selector XPath query
  # @return [Array<Node>] the matched nodes
  def find(selector)
    nodes = []
    page.find(selector).each { |node| nodes << Node.new(self, node) }
    nodes
  end

  # Execute JavaScript against the current page, discarding any return value.
  #
  # @param [String] script the JavaScript to be executed
  # @return [nil]
  def execute_script(script)
    page.execute_script script
  end

  # Execute JavaScript against the current page and return the results.
  #
  # @param [String] script the JavaScript to be executed
  # @return the result of the JavaScript
  def evaluate_script(script)
    page.evaluate_script script
  end

  # @return the current page
  def page
    browser.page
  end

  # @return the browser
  def browser
    @browser ||= Akephalos::Client.new(@options)
  end

  # @return the session cookies
  def cookies
    browser.cookies
  end

  # @return [String] the current user agent string
  def user_agent
    browser.user_agent
  end

  # Set the User-Agent header for this session. If :default is given, the
  # User-Agent header will be reset to the default browser's user agent.
  #
  # @param [:default] user_agent the default user agent
  # @param [String] user_agent the user agent string to use
  def user_agent=(user_agent)
    browser.user_agent = user_agent
  end

  # Disable waiting in Capybara, since waiting is handled directly by
  # Akephalos.
  #
  # @return [false]
  def wait
    false
  end

  private

  # @param [String] path
  # @return [String] the absolute URL for the given path
  def url(path)
    rack_server.url(path)
  end

end

Capybara.register_driver :akephalos do |app|
  Capybara::Driver::Akephalos.new(app)
end
