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
boolean route_mode = false;
int[] route_dir;
int trace_step = 0;
int piece_xprev = 0;
int piece_yprev = 0;
int piece_dirprev = 0 ;
boolean on_move = false;
boolean on_turn = false;
int move_time = 20;
int move_count = 0;

void setup() {
    size(800, 600, P3D);
    make_board(13, 9, 46);
    init_maze();
    //for (int[] i: road_map) {
    //  for (int j: i) {
    //    print(j);
    //  }
    //}
}
    
void draw() {
    draw_maze3D();
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
    road_map[2][3] = 2;
    piece_x = 2;
    piece_y = 3;
    piece_size = 0.7*road_w;
    piece_dir = 0;
}

void draw_maze() {
    noStroke();
    background(100);
    for (int x = 2; x < board_x-2; x++) {
        for (int y = 2; y < board_y-2; y++) {
            if (road_map[x][y] == 0) {
                fill(100, 0, 0);
            } else if (road_map[x][y] == 1) {
                fill(0, 200, 0);
            } else if (road_map[x][y] == 2) {
                fill(200, 200, 0);
            } else if (road_map[x][y] == 3) { 
                fill(200, 0, 200);
            }
            rect(road_w*x, road_w*y, road_w, road_w);
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
}

void draw_piece() {
    boolean in_touch = false;
    int pos_x = mouseX % road_w;
    int pos_y = mouseY % road_w;
    int p_x = mouseX / road_w;
    int p_y = mouseY / road_w;
    if (p_x >= 2 && p_x < board_x-2 && p_y >= 2 && p_y < board_y-2) {
        piece_x = p_x;
        piece_y = p_y;
    }
    if (road_map[piece_x][piece_y] == 1 || (road_map[piece_x+1][piece_y] == 1 
        && pos_x > road_w-piece_size/2) || (road_map[piece_x-1][piece_y] == 1 
        && pos_x < piece_size/2) || (road_map[piece_x][piece_y+1] == 1 
        && pos_y > road_w-piece_size/2) || (road_map[piece_x][piece_y-1] == 1 
        && pos_y < piece_size/2)){
        in_touch = true;
    }
    if (in_touch) {
        fill(255, 0, 0);
        stroke(255, 0, 0);
    } else {
        fill(0, 200, 0);
        stroke(0, 200, 0);
    ellipse(mouseX, mouseY, piece_size, piece_size);
    }
}

//void trace_route() {
//    if (frameCount % 10 == 0) {
//        int step_dir = route_dir[trace_step];
//        piece_x = piece_x + dir_x[step_dir];
//        piece_y = piece_y + dir_y[step_dir];
//        if (road_map[piece_x][piece_y] == 3) {
//            route_mode = false;
//        }
//        trace_step++;
//    }
//}

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
            float mdir_x = cos((piece_dirprev + r*f)*HALF_PI);
            float mdir_y = sin((piece_dirprev + r*f)*HALF_PI);
            camera(piece_x*road_w, piece_y*road_w, 0, (piece_x+mdir_x)*road_w, (piece_y+mdir_y)*road_w, 0, 0, 0, -1);
        } else if (on_move) {
            float m_x = piece_x - piece_xprev;
            float m_y = piece_y - piece_yprev;
            camera((piece_xprev+m_x*r)*road_w, (piece_yprev+m_y*r)*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1);
        } else {
            camera(piece_x*road_w, piece_y*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1);
        }
    }
    for (int x = 2; x < board_x-2; x++) {
        for (int y = 2; y < board_y-2; y++) {
            if (road_map[x][y] == 0) {
                fill(100, 0, 0);
            } else if (road_map[x][y] == 1){
                fill(0, 200, 0);
            } else if (road_map[x][y] == 2) {
                fill(200, 200, 0);
            } else if (road_map[x][y] == 3) {
                fill(200, 0, 200);
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
