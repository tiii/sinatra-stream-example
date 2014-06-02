require 'sinatra'
require 'sinatra/streaming'

class StreamingTest < Sinatra::Base
  helpers Sinatra::Streaming

  get '/' do
    <<-HTML
      <html lang="de" xml:lang="de">
        <head>
          <title>Streaming Example</title>
          <script type="text/javascript">

            window.onload = function() {
              var bodyElement = document.getElementsByTagName('body')[0];
              var scrollToBottom = false;

              var streamContainer = document.getElementById("stream-container");
              streamContainer.innerHtml = "";

              var xhr = new XMLHttpRequest();
              xhr.open('GET', '/stream');
              xhr.seenBytes = 0;

              xhr.onreadystatechange = function() {
                scrollToBottom = false

                if(xhr.readyState > 2) {
                  var newData = xhr.responseText.substr(xhr.seenBytes);
                  var newTextNode = document.createTextNode(newData);

                  if(bodyElement.offsetHeight <= window.scrollY + bodyElement.clientHeight) {
                    scrollToBottom = true;
                  }

                  streamContainer.appendChild(newTextNode);

                  if(scrollToBottom) {
                    window.scrollTo(0, bodyElement.scrollHeight)
                  }

                  xhr.seenBytes = xhr.responseText.length;
                }
              };

              xhr.onloadend = function() {
                streamContainer.appendChild(document.createTextNode('..finished streaming.'));
                if(scrollToBottom) {
                  window.scrollTo(0, bodyElement.scrollHeight)
                }
              };
              xhr.send();
            }
          </script>
        </head>

        <body>
          <pre id="stream-container"></pre>
        </body>
      </html>
    HTML
  end

  get '/stream' do
    content_type 'application/octet-stream'
    stream do |out|
      # really close client connection
      out.callback { http.conn.close_connection }
      out.errback { http.conn.close_connection }

      150.times do
        break if out.closed?
        out << "#{Time.now.utc}\n"
        sleep 1
      end
    end
  end

end