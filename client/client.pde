import processing.net.*;
Client client;
PVector gravity = new PVector(0.05, 0.05, -0.1); //重力のようなもの
ArrayList<ParticleSystem> particleSystem; //花火の情報

int board_x = 0;// ボードサイズ
int board_y = 0;
int road_w = 0;// ボード1マスのサイズ
int[][] road_map;// ボード情報(0:移動可能, 1:移動不可能, 2～17:他ユーザー, 18:移動不可能(床有り))
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
PShape Tyouchin;
PShape Yatai;
Boolean id_exist = false;
int request_count = 0;
boolean keyFlag = false; //入力モードON/OFF
boolean move = false; //出力モードON/OFF
String tmp = ""; //入力した文字列を記録するもの
String move_tmp = ""; //壁際に流す
ArrayList<ArrayList<String>> comment_l = new ArrayList(); 
String com = "";
float com_x;
float com_y;
float com_z;
float com_v;
float text_result;
ArrayList<String> del_com = new ArrayList();
float tyouchin_angle = 0; // ちょうちんの縦移動に用いるcos計算に与える角度

void setup() {
    size(1200, 900, P3D);
    client = new Client(this, "153.122.191.29", 5024);
    //client = new Client(this, "", 5024);
    make_board(20, 20, 24);
    init_maze();
    smooth(); // 描画を滑らかに
    particleSystem = new ArrayList<ParticleSystem>();
    Avater1 = loadShape("../Avater/Avater1.obj"); //Avaterの読み込み
    Avater2 = loadShape("../Avater2/Avater2.obj");
    Avater3 = loadShape("../Avater3/Avater3.obj");
    Avater4 = loadShape("../Avater4/Avater4.obj");
    Yagura = loadShape("../Yagura/Yagura.obj");
    Tyouchin = loadShape("../tyouchin/tyouchin.obj");
    Yatai = loadShape("../Yatai/Yatai.obj");
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
    // format: クライアントID(3桁) + 向き(0～3) + X座標(2桁) + Y座標(2桁) 

    String C_str = C_id + str(piece_dir);
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
void Avater(int x, int y, int num) {
  PShape[] Avater_list = {
    Avater1,
    Avater2,
    Avater3,
    Avater4
  };
  int avater_num = (num-2)/4;
  int avater_dir = (num-2)%4;
  
  pushMatrix();
  switch (num) {
    case 2:
      translate(x*road_w+16, y*road_w, -11);
      break;
    case 3:
      translate(x*road_w, y*road_w+16, -11);
      break;
    case 4:
      translate(x*road_w-16, y*road_w, -11);
      break;
    case 5:
      translate(x*road_w, y*road_w-16, -11);
      break;
    default:
      translate(x*road_w, y*road_w, -11);
  }
  lights();
  rotateZ(PI/2 * (avater_dir+1));
  shape(Avater_list[avater_num]);
  popMatrix();
}

void Yagura() {
  pushMatrix();
  translate((board_x-2)*road_w/2-8, (board_y-2)*road_w/2-8, -11);
  lights();
  shape(Yagura);
  popMatrix();
}

void Yatai() {
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    translate((i+1)*3*road_w, 21 * road_w - 8, -11);
    lights();
    shape(Yatai);
    popMatrix();
  }
}

void Tyouchin() {
  int[][] tyouchin_list = { // 中心座標を0, 0としたときのちょうちんの座標[x, y, z]
    {0, 8, 24},
    {8, 0, 36},
    {0, -8, 0},
    {-8, 0, 72},
    {5, 5, 198},
    {-5, -5, 246},
    {5, -5, 114},
    {-5, 5, 126}
  };
  for (int i = 0; i < tyouchin_list.length; i++) {
    pushMatrix();
    translate((board_x-2+tyouchin_list[i][0])*road_w/2, (board_y-2+tyouchin_list[i][1])*road_w/2, 3*cos(radians(tyouchin_list[i][2]+tyouchin_angle)));
    lights();
    shape(Tyouchin);
    popMatrix();
  }
  tyouchin_angle += 1.2;
}

// サーバーからメッセージを受け取った際に実行
void clientEvent(Client c) {
  String S_str = c.readString();
  println("C:" + S_str);
  if (S_str != null) {
    if (S_str.substring(0, 3).equals(C_id) && (S_str.length()-3)%8 == 0) { // 対象クライアントIDが自分のIDと等しいとき 
      for (int x = 1; x < board_x-1; x++) { // 他ユーザーの描画をリセット
        for (int y = 1; y < board_y-1; y++) {
          if (road_map[x][y] < 18) {
            road_map[x][y] = 0;
          }
        }
      }
      for (int i = 0; i < (S_str.length()-3) / 8; i++) { // 他ユーザーの座標を取得

        String id = S_str.substring(8 * i + 3, 8 * i + 6);
        int dir = int(S_str.substring(8 * i + 6, 8 * i + 7));
        int x = int(S_str.substring(8 * i + 7, 8 * i + 9));
        int y = int(S_str.substring(8 * i + 9, 8 * i + 11));
        if (!id.equals(C_id)) {
          road_map[x][y] = 2 + int(id.substring(2))*4 + dir;
        }
      }
    } else if (S_str.substring(0, 3).equals("str")) { // サーバーからコメントを受信したときの処理
      String comment = S_str.substring(3, S_str.length());
      ArrayList<String> comment_l2 = new ArrayList<String>();
      com_y = random(20,100);
      comment_l2.add(comment);
      comment_l2.add("0.0");
      comment_l2.add(""+com_y);
      comment_l2.add("600.0");
      comment_l2.add(""+random(1,1.6));
      comment_l.add(comment_l2);
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
        if (piece_dir == 0 && road_map[piece_x+1][piece_y]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x += 1;
            on_move = true;
        } else if (piece_dir == 1 && road_map[piece_x][piece_y+1]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y += 1;
            on_move = true;
        } else if (piece_dir == 2 && road_map[piece_x-1][piece_y]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x -= 1;
            on_move = true;
        } else if (piece_dir == 3 && road_map[piece_x][piece_y-1]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y -= 1;
            on_move = true;
        }
    } else if (keyCode == DOWN) {
        if (piece_dir == 0 && road_map[piece_x-1][piece_y]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x -= 1;
            on_move = true;
        } else if (piece_dir == 1 && road_map[piece_x][piece_y-1]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_y -= 1;
            on_move = true;
        } else if (piece_dir == 2 && road_map[piece_x+1][piece_y]%17 != 1) {
            piece_xprev = piece_x;
            piece_yprev = piece_y;
            piece_x += 1;
            on_move = true;
        } else if (piece_dir == 3 && road_map[piece_x][piece_y+1]%17 != 1) {
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
    // println("key pressed key=" + key + ",keyCode=" + keyCode); //動作確認コード
    if (keyCode == 47) {
        keyFlag = true; //「/」を入力したら入力モード
    }
    else if (keyCode == 10) {
        keyFlag = false; //Enterを押したら出力モード
        println("入力:" + tmp); //出力される文字列のコンソール表示(消しても問題ない)。
        client.write("str"+tmp); //サーバーに文字列の情報を送る。
        move = true; //出力モードオン
        move_tmp = tmp; //文字列を動かす用の文字列に記録(要修正) 
        tmp = ""; //入力する文字列の初期化
    }
    if (keyFlag){ //入力モードの時
      if (keyCode != 37 && keyCode != 38 && keyCode != 39 && keyCode != 40){ //上下左右移動のコマンドは無視
        if (keyCode == 8) { // backspaceを押したとき1文字消す
          if (tmp.length() >= 1) {
          tmp = tmp.substring(0, tmp.length()-1);
          }
        } else if(keyCode != 47) { //「/」以外は入力する(入力切替時に先頭に「/」が入ってしまうことを修正すると必要なくなる。)
          tmp += key;
        }
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
  for (int x = 1; x < board_x-1; x++) {
    for (int y = 1; y < board_y-1; y++) {
      road_map[x][y] = 0;
    }
  }
  for (int x = (board_x-2)/2-1; x <= (board_x-2)/2+1; x++) {
    for (int y = (board_y-2)/2-1; y <= (board_y-2)/2+1; y++) {
      road_map[x][y] = 18;
    }
  }
  while (true) {
    piece_x = int(random(2, board_x-2));
    piece_y = int(random(2, board_y-2));
    if(road_map[piece_x][piece_y] == 0) {
      break;
    }
  }
  piece_dir = int(random(0, 4));
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
  for (int x = 1; x < board_x-1; x++) {
    for (int y = 1; y < board_y-1; y++) {
      int status = road_map[x][y];
      if (status != 1) {
        pushMatrix();
        fill(255, 255, 255);
        translate(x*road_w, y*road_w, -road_w/2);
        box(road_w, road_w, 1);
        popMatrix();
      }
      if (status >= 2 && status <= 17) {
        Avater(x, y, status);
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
  text_input();
  if (comment_l.size() > 0){
    for (int i = 0 ;i < comment_l.size(); i++){
      com = comment_l.get(i).get(0);
      com_x = Float.valueOf(comment_l.get(i).get(1));
      com_y = Float.valueOf(comment_l.get(i).get(2)) - 100;
      com_z = Float.valueOf(comment_l.get(i).get(3));
      com_v = Float.valueOf(comment_l.get(i).get(4));
      text_result = text_move(i, com, com_x, com_y, com_z, com_v); //これを適当にfor とかで全コメントで回す
      if (text_result != 0){
        com_y += 100;
        if (com_z > 0 && com_x == 0){
          com_z = text_result;
        }
        else if(com_z < 0 && com_x < 600){
          com_x = text_result;
        }
        else if(com_z < 600 && com_x > 600){
          com_z = text_result;
        }
        ArrayList<String> comment3 = new ArrayList<String>(comment_l.get(i));
        comment3.set(0, com);
        comment3.set(1, ""+com_x);
        comment3.set(2, ""+com_y);
        comment3.set(3, ""+com_z);
        comment_l.set(i, comment3);
      }
      else{
        del_com.add(""+i);
      }
    }
    if (del_com.size() > 0){
      for (int i = 0; i < del_com.size(); i++){
        comment_l.remove(del_com.get(i));
      }
      del_com.clear();
    }
  }
  Yagura();
  Yatai();
  Tyouchin();
  Avater(17, 1, 3);
  Avater(18, 1, 7);
  Avater(19, 1, 11);
  Avater(20, 1, 15);
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
        p = new Particle(random(0,48), random(0,600), hue);
        break;
      case 1:
        p = new Particle(random(48,552), random(0,48), hue);
        break;
      case 2:
        p = new Particle(random(48,552), random(552,600), hue);
        break;
      case 3:
        p = new Particle(random(552,600), random(0,600), hue);
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

//以下テキスト関連
void text_input(){
  pushMatrix();
  fill(100); //灰色に変える。
  rotateX(-1.6); //向き調整
  textMode(SHAPE); //文字列のモード変更(コレにしないと解像度が酷い)
  text(tmp, 120, -road_w+4, 0.9); //入力モード時の文字列を表示
  popMatrix();
  pushMatrix();
  fill(255); //テキストボックスの背景
  translate(200,-1,road_w); //丁度いい座標に移動
  rotateX(-1.6); //向き調整
  box(196,30,0.5); //テキストボックス作成
  popMatrix();
}

//テキストを動かす関数
float text_move(int i, String move_tmp, float x, float y, float z, float v){
  fill(255); //文字を白色に変える。
  pushMatrix();
  rotateX(-PI/2); //向き調整
  textMode(SHAPE); //文字列のモード変更(コレにしないと解像度が酷い)
  if (z > 0 && x == 0){
    pushMatrix();
    translate(x,y,z);
    rotateY(PI/2);
    text(move_tmp, 0, 0, 0);
    popMatrix();
    z -= v;
    popMatrix();
    return z;
  }
  else if(z < 0 && x < 600){
    pushMatrix();
    translate(x,y,z);
    text(move_tmp, 0, 0, 0); //入力モード時の文字列を表示
    popMatrix();
    x += v;
    popMatrix();
    return x;
  }
  else if(z < 600 && x > 600){
    pushMatrix();
    translate(x,y,z);
    rotateY(-PI/2);
    text(move_tmp, 0, 0, 0); //入力モード時の文字列を表示
    popMatrix();
    z += v;
    popMatrix();
    return z;
  }
  else {
    popMatrix();
    return 0;
  }
}
