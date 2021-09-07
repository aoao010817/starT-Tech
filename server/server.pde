import processing.net.*;

Server server;

void setup() {
  server = new Server(this, 20000);
}

void draw() {
  Client c = server.available();
  if(c != null) {
    String s = c.readString();
    println("server received: " + s);
    server.write(s);
  }
}
