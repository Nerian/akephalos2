class Application < TestApp
  get '/slow_page' do
    sleep 1
    "<p>Loaded!</p>"
  end

  get '/slow_ajax_load' do
    <<-HTML
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
    <title>with_js</title>
    <script src="/jquery.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript">
      $(function() {
       $('#ajax_load').click(function() {
         $('body').load('/slow_page');
         return false;
       });
      });
    </script>
  </head>
  <body>
    <a href="#" id="ajax_load">Click me</a>
  </body>
    HTML
  end

  get '/user_agent_detection' do
    request.user_agent
  end

  get '/app_domain_detection' do
    "http://#{request.host_with_port}/app_domain_detection"
  end

  get '/page_with_javascript_error' do
    <<-HTML
  <head>
    <script type="text/javascript">
      $() // is not defined
    </script>
  </head>
  <body>
  </body>
   HTML
  end

  get '/ie_test' do
    <<-HTML
  <body>
  <!--[if IE 6]>
  This is for InternetExplorer6
  <![endif]-->
  <!--[if IE 7]>
  This is for InternetExplorer7
  <![endif]-->
  <!--[if IE 8]>
  This is for InternetExplorer8
  <![endif]-->
  </body>
    HTML
  end

  # &#09;   horizontal tab
  # &#10;   line feed
  # &#13;   carriage return
  # &#160;	&nbsp;
  get "/domnode_test" do
    <<-HTML
  <body>
    <p id="original_html">original html</p>
    <p id="horizontal_tab">&#09;original&#09; html&#09;</p>
    <p id="line_feed">&#10;original&#10; html&#10;</p>
    <p id="carriage_return">&#13;original&#13; html&#13;</p>
    <p id="non_breaking_space">&#160;original&#160; html&#160;</p>
  </body>
    HTML
  end

  get "/xml_vs_source_test" do
    <<-HTML
  <body>
    <p id="javascript_modified">javascript modified</p>
    <script type="text/javascript">
        document.getElementById("javascript_modified").innerHTML = 'javascript modified after';
    </script>
  </body>
    HTML
  end

  get "/confirm_test" do
    <<-HTML
  <body>
    <p id="test">Test</p>
    <script type="text/javascript">
      if (confirm("Are you sure?")) {
        document.getElementById("test").innerHTML = 'Confirmed';
      } else {
        document.getElementById("test").innerHTML = 'Cancelled';
      }
    </script>
  </body>
    HTML
  end
end

if $0 == __FILE__
  Rack::Handler::Mongrel.run Application, :Port => 8070
end

