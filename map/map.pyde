board_x = 0
board_y = 0
road_w = 0
road_map = []
piece_x = 0
piece_y = 0
piece_size = 0
dir_x = [1, 0, -1, 0]
dir_y = [0, 1, 0, -1]
piece_dir = 0
route_mode = False
route_dir = []
trace_step = 0
piece_xprev = 0
piece_yprev = 0
piece_dirprev = 0 
on_move = False
on_turn = False
move_time = 20
move_count = 0

def setup():
    size(800, 600, P3D)
    make_board(13, 9, 46)
    init_maze()
    
def draw():
    if route_mode:
        trace_route()
    draw_maze3D()

def make_board(x, y, w):
    global board_x, board_y
    global road_w
    global road_map
    board_x = x+4
    board_y = y+4
    road_w = w
    road_map = [[0 for i in range(board_y)]for j in range(board_x)]

def init_maze():
    for x in range(0, board_x):
        for y in range(0, board_y):
            road_map[x][y] = 1
    for x in range(3, board_x-3):
        for y in range(3, board_y-3):
            road_map[x][y] = 0
    road_map[2][3] = 2
    road_map[board_x-3][board_y-4] = 3
    global piece_x, piece_y
    global piece_size
    global piece_dir
    piece_x = 2
    piece_y = 3
    piece_size = 0.7*road_w
    piece_dir = 0

def draw_maze():
    noStroke()
    background(100)
    for x in range(2, board_x-2):
        for y in range(2, board_y-2):
            if road_map[x][y] == 0:
                fill(100, 0, 0)
            elif road_map[x][y] == 1:
                fill(0, 200, 0)
            elif road_map[x][y] == 2:
                fill(200, 200, 0)
            elif road_map[x][y] == 3:
                fill(200, 0, 200)
            rect(road_w*x, road_w*y, road_w, road_w)

def keyPressed():
    global piece_x, piece_y
    global piece_dir
    global piece_xprev, piece_yprev, on_turn, on_move, piece_dirprev
    if keyCode == UP:
        if piece_dir == 0 and road_map[piece_x+1][piece_y] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_x += 1
            on_move = True
        elif piece_dir == 1 and road_map[piece_x][piece_y+1] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_y += 1
            on_move = True
        elif piece_dir == 2 and road_map[piece_x-1][piece_y] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_x -= 1
            on_move = True
        elif piece_dir == 3 and road_map[piece_x][piece_y-1] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_y -= 1
            on_move = True
    
    elif keyCode == DOWN:
        if piece_dir == 0 and road_map[piece_x-1][piece_y] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_x -= 1
            on_move = True
        elif piece_dir == 1 and road_map[piece_x][piece_y-1] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_y -= 1
            on_move = True
        elif piece_dir == 2 and road_map[piece_x+1][piece_y] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_x += 1
            on_move = True
        elif piece_dir == 3 and road_map[piece_x][piece_y+1] != 1:
            piece_xprev = piece_x
            piece_yprev = piece_y
            piece_y += 1
            on_move = True
    
    elif keyCode == LEFT:
        piece_dirprev = piece_dir
        piece_dir = (piece_dir+3) % 4
        on_turn = True
    
    elif keyCode == RIGHT:
        piece_dirprev = piece_dir
        piece_dir = (piece_dir+1) % 4
        on_turn = True

def draw_piece():
    global piece_x, piece_y
    if is_mouse_playing:
        in_touch = False
        pos_x = mouseX % road_w
        pos_y = mouseY % road_w
        p_x = mouseX / road_w
        p_y = mouseY / road_w
        if p_x >= 2 and p_x < board_x-2 and p_y >= 2 and p_y < board_y-2:
            piece_x = p_x
            piece_y = p_y
        
        if road_map[piece_x][piece_y] == 1 \
            or (road_map[piece_x+1][piece_y] == 1 \
            and pos_x > road_w-piece_size/2)\
            or (road_map[piece_x-1][piece_y] == 1 \
            and pos_x < piece_size/2)\
            or (road_map[piece_x][piece_y+1] == 1 \
            and pos_y > road_w-piece_size/2)\
            or (road_map[piece_x][piece_y-1] == 1 \
            and pos_y < piece_size/2):
            in_touch = True
        
        if in_touch:
            fill(255, 0, 0)
            stroke(255, 0, 0)
        else:
            fill(0, 200, 0)
            stroke(0, 200, 0)
        ellipse(mouseX, mouseY, piece_size, piece_size)
        
    else:
        fill(0, 200, 0)
        stroke(0, 200, 0)
        ellipse((piece_x+0.5)*road_w, (piece_y+0.5)*road_w, piece_size, piece_size)

def trace_route():
    global piece_x, piece_y, route_mode, trace_step, step_dir
    if frameCount % 10 == 0:
        step_dir = route_dir[trace_step]
        piece_x = piece_x + dir_x[step_dir]
        piece_y = piece_y + dir_y[step_dir]
        if road_map[piece_x][piece_y] == 3:
            route_mode = False
        trace_step += 1

def draw_maze3D():
    global r, f, move_count, on_turn, on_move, mdir_x, mdir_y, m_x, m_y, piece_x, piece_y, piece_xprev, piece_yprev
    background(100)
    stroke(0)
    r = float(move_count)/float(move_time-1)
    perspective(radians(100), float(width)/float(height), 1, 800)
    
    if on_turn:
        f = 0
        if piece_dir-piece_dirprev == 1 or piece_dir-piece_dirprev == -3:
            f = 1
        elif piece_dir-piece_dirprev == -1 or piece_dir-piece_dirprev == 3:
            f = -1
        mdir_x = cos((piece_dirprev + r*f)*HALF_PI)
        mdir_y = sin((piece_dirprev + r*f)*HALF_PI)
        camera(piece_x*road_w, piece_y*road_w, 0, (piece_x+mdir_x)*road_w, (piece_y+mdir_y)*road_w, 0, 0, 0, -1)
    
    elif on_move:
        m_x = piece_x - piece_xprev
        m_y = piece_y - piece_yprev
        camera((piece_xprev+m_x*r)*road_w, (piece_yprev+m_y*r)*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1)
    else:
        camera(piece_x*road_w, piece_y*road_w, 0, piece_x*road_w+dir_x[piece_dir], piece_y*road_w+dir_y[piece_dir], 0, 0, 0, -1)
    
    for x in range(2, board_x-2):
        for y in range(2, board_y-2):
            if road_map[x][y] == 0:
                fill(100, 0, 0)
            elif road_map[x][y] == 1:
                fill(0, 200, 0)
            elif road_map[x][y] == 2:
                fill(200, 200, 0)
            elif road_map[x][y] == 3:
                fill(200, 0, 200)
            pushMatrix()
            if road_map[x][y] == 1:
                translate(x*road_w, y*road_w, 0)
                box(road_w)
            else:
                translate(x*road_w, y*road_w, -road_w/2)
                box(road_w, road_w, 1)
            popMatrix()
        
    if on_turn or on_move:
        move_count += 1
        if move_count == move_time:
            on_move = False
            on_turn = False
            move_count = 0
