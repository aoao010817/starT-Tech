import processing.net.*;
Client client;
PVector gravity = new PVector(0, 0.1);
ArrayList<ParticleSystem> particleSystem;

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

void setup() {
    size(800, 600, P3D);
    make_board(15, 15, 32);
    init_maze();
    colorMode(HSB, 360, 100, 100, 100); // HSBでの色指定にする
    smooth(); // 描画を滑らかに
    particleSystem = new ArrayList<ParticleSystem>();
}

void draw(){
    draw_maze3D();
    if (random(1) < 0.05) {
    particleSystem.add(new ParticleSystem());
    }
    for (int i = particleSystem.size()-1; i >= 0; i--) {
      ParticleSystem ps = particleSystem.get(i);
      ps.run();
      if (ps.done()) {
        particleSystem.remove(ps);
      }
    }
}

void clientEvent(Client c) {
    String s = c.readString();
    if (s != null) {
        println("client received: " + s);
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
    background(0);
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
    pos = new PVector(random(0,800), random(0,600), 0);
    vel = new PVector(0, 0, random(-12, -6));
    acc = new PVector(0, 0, 0.1);
    c = color(random(360), 80, 100);
  }
  Particle(float x, float y, float hue) {
    pos = new PVector(x, y, random(-500, 500));
    vel = new PVector(0, 0, random(-12, -6));
    acc = new PVector(0, 0, 0.1);
    c = color(hue, 80, 100);
    seed = true;
  }
  Particle(PVector _pos, float hue) {
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
    if (pos.y > height) {
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
    p = new Particle(random(-width/2, width/2), height, hue);
    particles = new ArrayList<Particle>();
  }
  boolean done() {
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
