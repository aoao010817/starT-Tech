import processing.net.*;
Client client;

int board_x = 0;// ボードサイズ
int board_y = 0;
int road_w = 0;// ボード1マスのサイズ
int[][] road_map;// ボード情報(0:移動可能, 1:移動不可能, 2:他ユーザー)
int piece_x = 0;// 自アバターの座標
int piece_y = 0; 
int[] dir_x = {1, 0, -1, 0}; //進行方向と座標の関係を保持
int[] dir_y = {0, 1, 0, -1};
int piece_dir = 0;// 自アバターの向き
int piece_xprev = 0; // 一つ前の情報を保持
int piece_yprev = 0;
int piece_dirprev = 0 ;
boolean on_move = false;
boolean on_turn = false;
int move_time = 10; // アニメーションの描画時間(ms)
int move_count = 0;
String C_id = "00"; // 自分のクライアントID

void setup() {
    size(800, 600, P3D);
    client = new Client(this, "153.122.191.29", 5024);
    // client = new Client(this, "153.122.191.29", 5024);
    make_board(20, 20, 24);
    init_maze();
}

void draw(){
    draw_maze3D();
}

// サーバーからメッセージを受け取った際に実行
void clientEvent(Client c) {
    String S_str = c.readString();
    println("C:"  + S_str);
    if (S_str != null) {
        if (C_id == "00") {
            C_id = S_str.substring(0, 2);
        }
        for (int x = 3; x < board_x-3; x++) {
            for (int y = 3; y < board_y-3; y++) {
                road_map[x][y] = 0;
            }
        }
        for (int i = 0; i < (S_str.length()-2) / 6; i++) {
            String id = S_str.substring(6 * i + 2, 6 * i + 4);
            int x = int(S_str.substring(6 * i + 4, 6 * i + 6));
            int y = int(S_str.substring(6 * i + 6, 6 * i + 8));
            if (!id.equals(C_id)) {
                road_map[x][y] = 2;
            }
        }
    }
}

void keyPressed() {
    if (keyCode == UP) {
        if (piece_dir == 0 && road_map[piece_x+1][piece_y] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x += 1;
            on_move = true;
        } else if (piece_dir == 1 && road_map[piece_x][piece_y+1] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y += 1;
            on_move = true;
        } else if (piece_dir == 2 && road_map[piece_x-1][piece_y] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x -= 1;
            on_move = true;
        } else if (piece_dir == 3 && road_map[piece_x][piece_y-1] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y -= 1;
            on_move = true;
        }
    } else if (keyCode == DOWN) {
        if (piece_dir == 0 && road_map[piece_x-1][piece_y] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x -= 1;
            on_move = true;
        } else if (piece_dir == 1 && road_map[piece_x][piece_y-1] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y -= 1;
            on_move = true;
        } else if (piece_dir == 2 && road_map[piece_x+1][piece_y] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x += 1;
            on_move = true;
        } else if (piece_dir == 3 && road_map[piece_x][piece_y+1] != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y += 1;
            on_move = true;
        }
    } else if (keyCode == LEFT) {
        piece_dirprev = piece_dir;
        piece_dir = (piece_dir+3) % 4;
        on_turn = true;
    } else if (keyCode == RIGHT) {
        piece_dirprev = piece_dir;
        piece_dir = (piece_dir+1) % 4;
        on_turn = true;
    }
    
    // format: クライアントID(2桁) + X座標(2桁) + Y座標(2桁) 
    String C_str = C_id;
    if (piece_x < 10) {
      C_str += "0" + str(piece_x);
    } else {
      C_str += str(piece_x);
    }
    if (piece_y < 10) {
      C_str += "0" + str(piece_y);
    } else {
      C_str += str(piece_y);
    }
    client.write(C_str);
}

// ボード初期化関数
// int x: ボードのX方向の大きさ
// int y: ボードのY方向の大きさ
// int w: 1マスの大きさ
void make_board(int x, int y, int w) {
    board_x = x+4;
    board_y = y+4;
    road_w = w;
    road_map = new int[board_x][board_y];
    for (int i = 0; i < board_y; i++) {
        for (int j = 0; j < board_x; j++) {
            road_map[j][i] = 0;
        }
    }
}

// ボード、座標初期化関数
void init_maze() {
    for (int x = 0; x < board_x; x++) {
        for (int y = 0; y < board_y; y++) {
            road_map[x][y] = 1;
        }
    }
    for (int x = 3; x < board_x-3; x++) {
        for (int y = 3; y < board_y-3; y++) {
            road_map[x][y] = 0;
        }
    }
    piece_x = int(random(3, board_x-3));
    piece_y = int(random(3, board_y-3));
    piece_dir = 0;
}

// 描画関数
void draw_maze3D() {
    background(20);
    stroke(0);
    float r = float(move_count)/float(move_time-1);
    perspective(radians(100), float(width)/float(height), 1, 800);
    if (on_turn) {
        int f = 0;
        if (piece_dir-piece_dirprev == 1 || piece_dir-piece_dirprev == -3) {
            f = 1;
        } else if (piece_dir-piece_dirprev == -1 || piece_dir-piece_dirprev == 3) {
            f = -1;
        }
        float mdir_x = cos((piece_dirprev + r*f)*HALF_PI);
        float mdir_y = sin((piece_dirprev + r*f)*HALF_PI);
        camera(piece_x*road_w, piece_y*road_w, 0, (piece_x+mdir_x)*road_w, (piece_y+mdir_y)*road_w, 0, 0, 0, -1);
    } else if (on_move) {
        float m_x = piece_x - piece_xprev;
        float m_y = piece_y - piece_yprev;
        camera((piece_xprev+m_x*r)*road_w, (piece_yprev+m_y*r)*road_w, 0, (piece_x+dir_x[piece_dir])*road_w+dir_x[piece_dir], (piece_y+dir_y[piece_dir])*road_w+dir_y[piece_dir], 0, 0, 0, -1);
    } else {
        camera(piece_x*road_w, piece_y*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1);
    }
    for (int x = 2; x < board_x-2; x++) {
        for (int y = 2; y < board_y-2; y++) {
            if (road_map[x][y] == 0) {
                fill(255, 255, 255);
            } else if (road_map[x][y] == 1) {
                fill(30, 30, 30);
            } else if (road_map[x][y] == 2) {
                fill(30, 30, 30);
            }
            
            pushMatrix();
            fill(255, 255, 255);
            translate(x*road_w, y*road_w, -road_w/2);
            box(road_w, road_w, 1);
            popMatrix();
            
            pushMatrix();
            if (road_map[x][y] == 2) {
                fill(200, 200, 200);
                translate(x*road_w, y*road_w, -road_w*0.1);
                box(road_w*0.8);
            }
            popMatrix();
        }
    }
    if (on_turn || on_move) {
        move_count++;
        if (move_count == move_time) {
            on_move = false;
            on_turn = false;
            move_count = 0;
        }
    }
}
