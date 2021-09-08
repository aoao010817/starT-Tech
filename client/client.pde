import processing.net.*;
Client client;
PVector gravity = new PVector(0.05, 0.05, -0.1); //重力のようなもの
ArrayList<ParticleSystem> particleSystem; //花火の情報

int board_x = 0;// ボードサイズ
int board_y = 0;
int road_w = 0;// ボード1マスのサイズ
int[][] road_map;// ボード情報(0:移動可能, 1:移動不可能, 2～5:他ユーザー)
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
String C_id = "000"; // 自分のクライアントID
PShape Avater1;
PShape Avater2;
PShape Avater3;
PShape Avater4;
PShape Yagura;
Boolean id_exist = false;
int request_count = 0;
boolean keyFlag = false;
String tmp = "";

void setup() {
    size(800, 600, P3D);
    // client = new Client(this, "153.122.191.29", 5024);
    make_board(20, 20, 24);
    init_maze();
    smooth(); // 描画を滑らかに
    particleSystem = new ArrayList<ParticleSystem>();
    Avater1 = loadShape("../Avater/Avater1.obj"); //Avaterの読み込み
    Avater2 = loadShape("../Avater2/Avater2.obj");
    Avater3 = loadShape("../Avater3/Avater3.obj");
    Avater4 = loadShape("../Avater4/Avater4.obj");
    Yagura = loadShape("../Yagura/Yagura.obj");
}

void draw(){
  draw_maze3D();  
  if (random(1) < 0.3) {
    particleSystem.add(new ParticleSystem());
  }
  for (int i = particleSystem.size()-1; i >= 0; i--) {
    ParticleSystem ps = particleSystem.get(i);
    ps.run();
    if (ps.done()) {
      particleSystem.remove(ps);
    }
  }
  
  request_count++;
  if (request_count >= 12 && id_exist) {
    request_count = 0;
    // format: クライアントID(3桁) + X座標(2桁) + Y座標(2桁) 

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
}

//Avaterを生成する関数を作成
void Avater(int x, int y) {
  PShape[] Avater_list = {
    Avater1,
    Avater2,
    Avater3,
    Avater4
  };
  pushMatrix();
  fill(200, 0, 0);
  translate(x*road_w, y*road_w, -11);
  lights();
  shape(Avater_list[road_map[x][y]-2]);
  popMatrix();
}

void Yagura() {
  pushMatrix();
  translate((board_x-2)*road_w/2, (board_y-2)*road_w/2, -11);
  lights();
  shape(Yagura);
  popMatrix();
}

// サーバーからメッセージを受け取った際に実行
void clientEvent(Client c) {
  String S_str = c.readString();
  println("C:"  + S_str);
  if (S_str != null) {
    if (S_str.substring(0, 3).equals(C_id)) { // 対象クライアントIDが自分のIDと等しいとき 
      for (int x = 2; x < board_x-2; x++) { // 他ユーザーの描画をリセット
        for (int y = 2; y < board_y-2; y++) {
          road_map[x][y] = 0;
        }
      }
      for (int i = 0; i < (S_str.length()-2) / 7; i++) { // 他ユーザーの座標を取得
        String id = S_str.substring(6 * i + 2, 6 * i + 5);
        int x = int(S_str.substring(6 * i + 5, 6 * i + 7));
        int y = int(S_str.substring(6 * i + 7, 6 * i + 9));
        if (!id.equals(C_id)) {
          road_map[x][y] = 2 + int(id.substring(2));
        }
      }
    } else if (C_id == "000") { // 自分のクライアントIDが未登録でサーバーからIDが発行されたとき
      if (S_str.length() == 3) {
         C_id = S_str;
         id_exist = true;
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
    // コメント入力
    println("key pressed key=" + key + ",keyCode=" + keyCode);
    if (keyCode == 47) {
        keyFlag = true;
    }
    else if (keyCode == 10) {
        keyFlag = false;
        println("入力:" + tmp);
        // client.write("str"+tmp);
        tmp = "";
    }
    if (keyFlag){
      if (keyCode == 8) { // backspace.
        if (tmp.length() >= 1) {
        tmp = tmp.substring(0, tmp.length()-1);
        }
    } else if(keyCode != 47) {
      tmp += key;
      println("現在:"+tmp);
    }
  }
}

// ボード初期化関数
// int x: ボードのX方向の大きさ
// int y: ボードのY方向の大きさ
// int w: 1マスの大きさ
void make_board(int x, int y, int w) {
    board_x = x+2;
    board_y = y+2;
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
    for (int x = 2; x < board_x-2; x++) {
        for (int y = 2; y < board_y-2; y++) {
            road_map[x][y] = 0;
        }
    }
    piece_x = int(random(4, board_x-4));
    piece_y = int(random(4, board_y-4));
    piece_dir = 0;
}

// 描画関数
void draw_maze3D() {
    colorMode(RGB, 255, 255, 255); // RGBでの色指定モード
    background(20); //空の色
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
            if (road_map[x][y] != 1) {
                pushMatrix();
                fill(255, 255, 255);
                translate(x*road_w, y*road_w, -road_w/2);
                box(road_w, road_w, 1);
                popMatrix();
            }
            if (road_map[x][y] >= 2) {
                Avater(x, y);
            }
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
    Yagura();
}

//以下花火
class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  float life = 100;
  float lifeSpan = random(life/50, life/30);
  boolean seed = false;
  color c;
  Particle() {
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    pos = new PVector(random(0,800), random(0,600), 0);
    vel = new PVector(0, 0, random(-12, -6));
    acc = new PVector(0, 0, 0.1);
    c = color(random(360), 80, 100);
  }
  Particle(float x, float y, float hue) {
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    pos = new PVector(x, y, random(-500, 500));
    vel = new PVector(0, 0, random(-12, -6));
    acc = new PVector(0, 0, 0.1);
    c = color(hue, 80, 100);
    seed = true;
  }
  Particle(PVector _pos, float hue) {
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    pos = new PVector(_pos.x, _pos.y, _pos.z);
    vel = PVector.random3D();
    vel.mult(random(4, 6));
    acc = new PVector(0, 0, 0.1);
    c = color(hue, 80, 100);
  }
  void update() {
    pos.add(vel);
    vel.add(acc);
    if (!seed) {
      life -= lifeSpan;
      vel.mult(0.98);
    }
    acc.mult(0);
    if (pos.z > height) {
      pos = new PVector(random(-width/2, width/2), height, random(-500, 500));
      vel = new PVector(0, 0, random(-12, -8));
    }
  }
  void draw() {
    stroke(c, life);
    strokeWeight(4);
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    point(0, 0, 0);
    popMatrix();
  }
  void applyForce(PVector force) {
    acc.add(force);
  }
  void run() {
    update();
    draw();
  }
  boolean isDead() {
    if (life < 0) {
      return true;
    }
      return false;
  }
  boolean explode() {
    if (seed && vel.y > 0) {
      lifeSpan = 0;
      return true;
    }
    return false;
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  Particle p;
  float hue;
  ParticleSystem() {
    hue = random(360);
    switch (int(random(4))){
      case 0:
        p = new Particle(random(0,120), random(0,600), hue);
        break;
      case 1:
        p = new Particle(random(120,680), random(0,90), hue);
        break;
      case 2:
        p = new Particle(random(120,680), random(510,600), hue);
        break;
      case 3:
        p = new Particle(random(680,800), random(0,600), hue);
        break;
    }
    particles = new ArrayList<Particle>();
  }
  boolean done(){
    if (p == null && particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }
  void run() {
    if (p != null) {
      p.applyForce(gravity);
      p.update();
      p.draw();
      if (p.explode()) {
        for (int i = 0; i < 100; i++) {
          particles.add(new Particle(p.pos, hue));
        }
        p = null;
      }
    }
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle child = particles.get(i);
      child.applyForce(gravity);
      child.run();
      if (child.isDead()) {
        particles.remove(child);
      }
    }
  }
}
