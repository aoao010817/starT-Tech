import processing.net.*;

Server server;

int client_num = 0;// クライアント数を保持

// 各クライアントの座標と待機時間を保持[x座標, y座標, 待機時間, アバター番号]
// 待機時間は各ユーザーの0.1秒ごとのメッセージを受信するたびインクリメントされ、該当クライアントからの
// メッセージがあると全クライアントの数分引かれる。待機時間が全クライアント数の5倍以上(0.5秒間メッセージなし)になったユーザーは接続解除される
int[][] coordinates = new int[100][4];
int[] deletes = new int[100];
int delete_num = 0;

void setup() {
  server = new Server(this, 5024);
}

void draw() {
  Client c = server.available();
  if(c != null) {
    String C_str = c.readString();
    println("S:" + C_str);
    String S_str = "";
    int C_id = int(C_str.substring(0, 2));
    int avater_num = int(C_str.substring(2, 3));
    int piece_x = int(C_str.substring(3, 5));
    int piece_y = int(C_str.substring(5, 7));
    if (C_id < 10) {
      S_str = "0" + str(C_id);
    } else if (C_id >= 10) {
      S_str = str(C_id);
    }
    coordinates[int(C_id)-1][0] = piece_x;
    coordinates[int(C_id)-1][1] = piece_y;
    coordinates[int(C_id)-1][2] -= client_num;
    coordinates[int(C_id)-1][4] = avater_num;
    for (int i = 1; i <= client_num; i++) {
      coordinates[i-1][2]++;
      if (coordinates[i-1][2] > client_num*5) {
        coordinates[i-1][0] = 0;
        coordinates[i-1][1] = 1;
        coordinates[i-1][2] = 0;
        coordinates[i-1][4] = 0;
        deletes[delete_num] = i;
        delete_num++;
      }
      if (i < 10) {
        S_str += "0" + str(i);
      } else {
        S_str += str(i);
      }
      S_str += coordinates[i-1][4];
      if (coordinates[i-1][0] < 10) {
        S_str += "0" + str(coordinates[i-1][0]);
      } else {
        S_str += str(coordinates[i-1][0]);
      }
      if (coordinates[i-1][1] < 10) {
        S_str += "0" + str(coordinates[i-1][1]);
      } else {
        S_str += str(coordinates[i-1][1]);
      }
    }
    // format: 受信したクライアントID(3桁) + 
    //         (対象クライアントID(3桁) + X座標(2桁) + Y座標(2桁)) ＊ユーザー数繰り返し
    server.write(S_str);
  }
  if (client_num > 95) {
    client_num = 0;
    delete_num = 0;
  }
}

// 新しいクライアントの接続があったときに実行
void serverEvent(Server someServer, Client someClient) {
  client_num++;
  String S_str = "";
  int avater_num = int(random(0, 4));
  if (client_num < 10) {
    S_str = "0" + str(client_num);
  } else if (client_num >= 10) {
    S_str = str(client_num);
  }
  S_str += str(avater_num);
  // format: 新規に発行するクライアントID(2桁) + アバター番号(0～3)
  server.write(S_str);
  
  coordinates[client_num-1][2] = 0;
}
