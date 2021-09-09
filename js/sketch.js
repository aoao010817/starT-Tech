let gravity = new PVector(0.05, 0.05, -0.1); //重力のようなもの
ArrayList<ParticleSystem> particleSystem; //花火の情報

let board_x = 0;// ボードサイズ
let board_y = 0;
let road_w = 0;// ボード1マスのサイズ
let road_map;// ボード情報(0:移動可能, 1:移動不可能, 2～17:他ユーザー, 18:移動不可能(床有り))
let piece_x = 0;// 自アバターの座標
let piece_y = 0; 
const dir_x = [1, 0, -1, 0]; //進行方向と座標の関係を保持
const dir_y = [0, 1, 0, -1];
let piece_dir = 0;// 自アバターの向き
let piece_xprev = 0; // 一つ前の情報を保持
let piece_yprev = 0;
let piece_dirprev = 0 ;
let on_move = false;
let on_turn = false;
let move_time = 10; // アニメーションの描画時間(ms)
let move_count = 0;
let C_id = "000"; // 自分のクライアントID
let Avater1;
let Avater2;
let Avater3;
let Avater4;
let Yagura;
let id_exist = false;
let request_count = 0;
let keyFlag = false; //入力モードON/OFF
let move = false; //出力モードON/OFF
let tmp = ""; //入力した文字列を記録するもの
let move_tmp = ""; //壁際に流す
let x = 0; //動いている文字のx軸
let z = 600; //動いている文字のz軸
let a = 0; //意味を成さない(実験用変数)

function setup() {
    size(1200, 900, P3D);
    // client = new Client(this, "153.122.191.29", 5024);
    client = new Client(this, "", 5024);
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

function draw(){
  draw_maze3D();  
  if (random(1) < 0.3) {
    particleSystem.add(new ParticleSystem());
  }
  for (i = particleSystem.size()-1; i >= 0; i--) {
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

    let C_str = C_id + str(piece_dir);
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
function Avater(x, y, num) {
  let Avater_list = {
    Avater1,
    Avater2,
    Avater3,
    Avater4
  };
  let avater_num = (num-2)/4;
  let avater_dir = (num-2)%4;
  
  pushMatrix();
  translate(x*road_w, y*road_w, -11);
  lights();
  rotateZ(PI/2 * (avater_dir+1));
  shape(Avater_list[avater_num]);
  popMatrix();
}

function Yagura() {
  pushMatrix();
  translate((board_x-2)*road_w/2-8, (board_y-2)*road_w/2-8, -11);
  lights();
  shape(Yagura);
  popMatrix();
}

// サーバーからメッセージを受け取った際に実行
function clientEvent(Client c) {
  let S_str = c.readString();
  println("C:" + S_str);
  if (S_str != null) {
    if (S_str.substring(0, 3).equals(C_id) && (S_str.length()-3)%8 == 0) { // 対象クライアントIDが自分のIDと等しいとき 
      for (x = 2; x < board_x-2; x++) { // 他ユーザーの描画をリセット
        for (y = 2; y < board_y-2; y++) {
          if (road_map[x][y] < 18) {
            road_map[x][y] = 0;
          }
        }
      }
      for (i = 0; i < (S_str.length()-3) / 8; i++) { // 他ユーザーの座標を取得

        let id = S_str.substring(8 * i + 3, 8 * i + 6);
        let dir = int(S_str.substring(8 * i + 6, 8 * i + 7));
        let x = int(S_str.substring(8 * i + 7, 8 * i + 9));
        let y = int(S_str.substring(8 * i + 9, 8 * i + 11));
        if (!id.equals(C_id)) {
          road_map[x][y] = 2 + int(id.substring(2))*4 + dir;
        }
      }
    } else if (S_str.substring(0, 3).equals("str")) { // サーバーからコメントを受信したときの処理
        let comment = S_str.substring(3, S_str.length());
    } else if (C_id == "000") { // 自分のクライアントIDが未登録でサーバーからIDが発行されたとき
      if (S_str.length() == 3) {
         C_id = S_str;
         id_exist = true;
      }
    }
  }
}

function keyPressed() {
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
function make_board(x, y, w) {
  board_x = x+2;
  board_y = y+2;
  road_w = w;
  road_map = new int[board_x][board_y];
  for (i = 0; i < board_y; i++) {
    for (j = 0; j < board_x; j++) {
      road_map[j][i] = 0;
    }
  }
}

// ボード、座標初期化関数
function init_maze() {
  for (x = 0; x < board_x; x++) {
    for (y = 0; y < board_y; y++) {
      road_map[x][y] = 1;
    }
  }
  for (x = 1; x < board_x-1; x++) {
    for (y = 1; y < board_y-1; y++) {
      road_map[x][y] = 0;
    }
  }
  for (x = (board_x-2)/2-1; x <= (board_x-2)/2+1; x++) {
    for (y = (board_y-2)/2-1; y <= (board_y-2)/2+1; y++) {
      road_map[x][y] = 18;
    }
  }
  piece_x = int(random(4, board_x-4));
  piece_y = int(random(4, board_y-4));
  piece_dir = 0;
}

// 描画関数
function draw_maze3D() {
  colorMode(RGB, 255, 255, 255); // RGBでの色指定モード
  background(20); //空の色
  stroke(0);
  let r = float(move_count)/float(move_time-1);
  perspective(radians(100), float(width)/float(height), 1, 800);
  if (on_turn) {
    let f = 0;
    if (piece_dir-piece_dirprev == 1 || piece_dir-piece_dirprev == -3) {
      f = 1;
    } else if (piece_dir-piece_dirprev == -1 || piece_dir-piece_dirprev == 3) {
      f = -1;
    }
    let mdir_x = cos((piece_dirprev + r*f)*HALF_PI);
    let mdir_y = sin((piece_dirprev + r*f)*HALF_PI);
    camera(piece_x*road_w, piece_y*road_w, 0, (piece_x+mdir_x)*road_w, (piece_y+mdir_y)*road_w, 0, 0, 0, -1);
  } else if (on_move) {
    let m_x = piece_x - piece_xprev;
    let m_y = piece_y - piece_yprev;
    camera((piece_xprev+m_x*r)*road_w, (piece_yprev+m_y*r)*road_w, 0, (piece_x+dir_x[piece_dir])*road_w+dir_x[piece_dir], (piece_y+dir_y[piece_dir])*road_w+dir_y[piece_dir], 0, 0, 0, -1);
  } else {
    camera(piece_x*road_w, piece_y*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1);
  }
  for (x = 1; x < board_x-1; x++) {
    for (y = 1; y < board_y-1; y++) {
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
  if (move){
    text_move();
  }
  Yagura();
}

//以下花火
class Particle {
  constructor() {
    this.life = 100;
    this.lifeSpan = random(life/50, life/30);
    this.seed = false;
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    this.pos = new PVector(random(0,800), random(0,600), 0);
    this.vel = new PVector(0, 0, random(-12, -6));
    this.acc = new PVector(0, 0, 0.1);
    this.c = color(random(360), 80, 100);
  }
  Particle(x, y, hue) {
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    this.pos = new PVector(x, y, random(-500, 500));
    this.vel = new PVector(0, 0, random(-12, -6));
    this.acc = new PVector(0, 0, 0.1);
    this.c = color(hue, 80, 100);
    this.seed = true;
  }
  Particle(_pos, hue) {
    colorMode(HSB, 360, 100, 100); // HSBでの色指定にする
    this.pos = new PVector(_pos.x, _pos.y, _pos.z);
    this.vel = PVector.random3D();
    this.vel.mult(random(4, 6));
    this.acc = new PVector(0, 0, 0.1);
    this.c = color(hue, 80, 100);
  }
  update() {
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
  draw() {
    stroke(c, life);
    strokeWeight(4);
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    point(0, 0, 0);
    popMatrix();
  }
  applyForce(force) {
    acc.add(force);
  }
  run() {
    update();
    draw();
  }
  isDead() {
    if (life < 0) {
      return true;
    }
      return false;
  }
  explode() {
    if (seed && vel.y > 0) {
      lifeSpan = 0;
      return true;
    }
    return false;
  }
}

class ParticleSystem {
  constructor() {
    ArrayList<Particle> particles;
    this.hue = random(360);
    switch (int(random(4))){
      case 0:
        this.p = new Particle(random(0,48), random(0,600), hue);
        break;
      case 1:
        this.p = new Particle(random(48,552), random(0,48), hue);
        break;
      case 2:
        this.p = new Particle(random(48,552), random(552,600), hue);
        break;
      case 3:
        this.p = new Particle(random(552,600), random(0,600), hue);
        break;
    }
    particles = new ArrayList<Particle>();
  }
  done(){
    if (p == null && particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }
  run() {
    if (p != null) {
      p.applyForce(gravity);
      p.update();
      p.draw();
      if (p.explode()) {
        for (i = 0; i < 100; i++) {
          particles.add(new Particle(p.pos, hue));
        }
        p = null;
      }
    }
    for (i = particles.size()-1; i >= 0; i--) {
      let child = particles.get(i);
      child.applyForce(gravity);
      child.run();
      if (child.isDead()) {
        particles.remove(child);
      }
    }
  }
}

//以下テキスト関連
function text_input(){
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
function text_move(){
  fill(255); //文字を白色に変える。
  pushMatrix();
  rotateX(-1.6); //向き調整
  textMode(SHAPE); //文字列のモード変更(コレにしないと解像度が酷い)
  if (z != 0 && x != 600){
    text(move_tmp, x, -50, z); //入力モード時の文字列を表示
    z -= 1.0;
  }
  else if(x != 600){
    text(move_tmp, x, -50, z); //入力モード時の文字列を表示
    x += 1.0;
  }
  else if(z != 600){
    text(move_tmp, x, -50, z); //入力モード時の文字列を表示
    z += 1.0;
  }
  else {
    x = 0;
    z = 600;
    move = false;
  }
  popMatrix();
}