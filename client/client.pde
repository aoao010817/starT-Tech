import processing.net.*;
Client client;

int board_x = 0;
int board_y = 0;
int road_w = 0;
int[][] road_map;
int piece_x = 0;
int piece_y = 0;
float piece_size = 0;
int[] dir_x = {1, 0, -1, 0};
int[] dir_y = {0, 1, 0, -1};
int piece_dir = 0;
int[] route_dir;
int trace_step = 0;
int piece_xprev = 0;
int piece_yprev = 0;
int piece_dirprev = 0 ;
boolean on_move = false;
boolean on_turn = false;
int move_time = 10;
int move_count = 0;
String C_id = "00";

void setup() {
    size(800, 600, P3D);
    client = new Client(this, "192.168.86.31", 5024);
    make_board(15, 15, 32);
    init_maze();
}

void draw(){
    draw_maze3D();
}

void clientEvent(Client c) {
    String S_str = c.readString();
    if (S_str != null) {
        if (C_id == "00") {
            C_id = S_str.substring(0, 2);
        }
        println("C: " + S_str);
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
    
    String C_str = C_id;
    if (piece_x < 10) {
      C_str += "00" + str(piece_x);
    } else if (piece_x < 100) {
      C_str += "0" + str(piece_x);
    } else {
      C_str += str(piece_x);
    }
    if (piece_y < 10) {
      C_str += "00" + str(piece_y);
    } else if (piece_y < 100) {
      C_str += "0" + str(piece_y);
    } else {
      C_str += str(piece_y);
    }
    client.write(C_str);
}

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
    piece_size = 0.8*road_w;
    piece_dir = 0;
}

void draw_maze3D() {
    background(100);
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
            }
            pushMatrix();
            if (road_map[x][y] == 1) {
                translate(x*road_w, y*road_w, 0);
                box(road_w);
            } else {
                translate(x*road_w, y*road_w, -road_w/2);
                box(road_w, road_w, 1);
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
