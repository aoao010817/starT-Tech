import processing.net.*;

Server server;

int client_num = 0;
int[][] coordinates = new int[50][2];

void setup() {
  server = new Server(this, 5024);
}

void draw() {
  Client c = server.available();
  if(c != null) {
    String C_str = c.readString();
    print(C_str);
    String S_str = "";
    int C_id = int(C_str.substring(0, 2));
    int piece_x = int(C_str.substring(2, 5));
    int piece_y = int(C_str.substring(5, 8));
    if (C_id == 0) {
      client_num++;
      C_id = client_num;
      if (C_id < 10) {
        S_str = "0" + str(C_id);
      } else if (C_id >= 10) {
        S_str = str(C_id);
      }
    }
    coordinates[int(C_id)-1][0] = piece_x;
    coordinates[int(C_id)-1][1] = piece_y;
    for (int i = 1; i <= client_num; i++) {
      S_str += str(i);
      if (coordinates[i-1][0] < 10) {
        S_str += "00" + str(coordinates[i-1][0]);
      } else if (coordinates[i-1][0] < 100) {
        S_str += "0" + str(coordinates[i-1][0]);
      } else {
        S_str += str(coordinates[i-1][0]);
      }
      if (coordinates[i-1][1] < 10) {
        S_str += "00" + str(coordinates[i-1][1]);
      } else if (coordinates[i-1][1] < 100) {
        S_str += "0" + str(coordinates[i-1][1]);
      } else {
        S_str += str(coordinates[i-1][1]);
      }
    }
    server.write(C_str);
  };
}
