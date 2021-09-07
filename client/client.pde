import processing.net.*;
Client client;

void setup() {
  client = new Client(this, "192.168.86.24", 20000);
}

void draw(){}

void clientEvent(Client c) {
  String s = c.readString();
  if (s != null) {
    println("client received: " + s);
  }
}

void mouseClicked() {
  String s = "(" + mouseX + "," + mouseY + ") was clicked";
  println(s);
  client.write(s);
}
