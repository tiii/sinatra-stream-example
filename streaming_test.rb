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
              var streamContainer = document.getElementById("stream-container");
              streamContainer.innerHtml = "";

              var xhr = new XMLHttpRequest();
              xhr.open('GET', '/stream');
              xhr.seenBytes = 0;

              xhr.onreadystatechange = function() {
                if(xhr.readyState > 2) {
                  var newData = xhr.responseText.substr(xhr.seenBytes);                  
                  var newTextNode = document.createTextNode(newData);

                  streamContainer.appendChild(newTextNode);

                  xhr.seenBytes = xhr.responseText.length;
                }
              };

              xhr.onloadend = function() {
                streamContainer.appendChild(document.createTextNode('..finished streaming.'));
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
    content_type 'text/event-stream'
    stream do |out|
      15.times do
        break if out.closed?
        out << "#{Time.now.utc}\n"
        sleep 1
      end
    end
  end
  
end