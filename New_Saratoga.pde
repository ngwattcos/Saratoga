/* REFERENCE --> file:///Applications/Processing.app/Contents/Java/modes/java/reference/index.html
 * SURRENDER if general dies! if the 1st element != general, then

 * steer each soldier towards the center of his group
 * Loading images inside draw() will reduce the speed of a program.
 * Images cannot be loaded outside setup() unless they're inside a function that's called after setup() has already run.
 * Generals are horse-mounted. Soldiers on foot. Artillerymen can not move, only rotate.
 * use bullet physics? Or just use 2d coordinates?
 * each bullet has x and y coords, and ending x and ending y coords. If endX and endY are close enough to a soldier, that soldier dies,
 * but only after the bullet is near.
 * Assume each bullet is extremely accurate, but the soldiers do not have perfect aim.
 * a4 is organize American group 1. s4 is organize American group 2. d4 is organize British group.
 * 1 = idle, 2 = engage, 3 = fire, 4 = organize
 * health is 100, then decreases; once 0, starts bleeding nonstop, and guy dissapears after health < -50
 * once health is 0 (and bleeding commences), remove the soldier and place into wounded/dead array
 * fire only when still (circle is pink) and when done reloading
 * only reload when still; when reloading, stay still
 * use perlin noise to draw grass, or mud beneath translucent grass
 *
 * when going to base, just go DIRECTLY to base, no walking required
 * formation position depends on index
 * base position depends on base index
 * changeTargetFrame = index % 60!!!!!!!
 * HESSIAN TROOPERS!!!!
 * with 60% chance, choose the closest enemy to kill
 * seperate ArrayLists for American and British projectiles
 * when projectiles "burrow" into the ground, they dissapear
 */


int screenX = 900, screenY = 600, frameRt = 30;

PFont monaco;

class Picture {
    
    Dimensions size;
    PImage image;
    
    public Picture(PImage image, int x, int y) {
    
    this.image = image;
    size = new Dimensions(x, y);
    }
}

// PImage[] PImages = new PImage[30];
Picture[] pictures = new Picture[34];

void loadImages() {
    for (int i = 0; i < pictures.length; i++) {
    PImage thisImg = loadImage("data_small/" + Integer.toString(i) + ".png");
    pictures[i] = new Picture(thisImg, thisImg.width, thisImg.height);
    }
}

///////////////////////////////////////////////////////// Keys

class Key {
    int code;
    
    boolean pressed = false;
    boolean released = false;
    boolean clicked = false;
    int pressedTimer = 0;
    int releasedTimer = 0;
    
    public Key(int code) {
    this.code = code;
    }
    
    void update() {
    pressedTimer += 1;
    clicked = false;
    
    releasedTimer += 1;
    released = false;
    }
}

int MAX_KEYS = 200;

Key[] keys = new Key[MAX_KEYS];

// ArrayList<Key> pressedKeys = new ArrayList<Key>();
ArrayList<Integer> pressedKeys = new ArrayList<Integer>();


void keyPressed() {
    boolean inArr = false;
    
    if (keyCode < MAX_KEYS) {
    
    keys[keyCode].pressed = true;
    keys[keyCode].released = false;
    keys[keyCode].clicked = true;
    
    for (int i = 0; i < pressedKeys.size(); i++) {
    if (pressedKeys.get(i).intValue() == keyCode) {
    inArr = true;
    }
    }
    
    if (!inArr) {
    pressedKeys.add(new Integer(keyCode));
    }
    }
}

void keyReleased() {
    if (keyCode < MAX_KEYS) {
    
    keys[keyCode].pressed = false;
    keys[keyCode].released = true;
    keys[keyCode].clicked = false;
    keys[keyCode].releasedTimer = 0;
    
    int i = 0;
    boolean found = false;
    
    while (!found && i < pressedKeys.size()) {
    if (pressedKeys.get(i).intValue() == keyCode) {
    found = true;
    pressedKeys.remove(i);
    
    i -= 1;
    }
    
    i += 1;
    }
    }
}

void updateKey(int i) {
    if (keys[i].pressed) {
    keys[i].pressedTimer += 1;
    } else {
    keys[i].pressedTimer = 0;
    }
    
    if (keys[i].pressedTimer == 1) {
    keys[i].clicked = true;
    } else {
    keys[i].clicked = false;
    }
    
    
    if (!keys[i].pressed) {
    keys[i].releasedTimer += 1;
    }
    
    if (keys[i].releasedTimer == 1) {
    keys[i].released = true;
    } else {
    keys[i].released = false;
    }
}

void updateKeys() {
    for (int i = 16; i < 100; i++) {
    updateKey(i);
    }
    
    
    //// update the = key
    updateKey(187);
}



class Coords {
    int x; int y;
    
    public Coords(int x, int y) {
    this.x = x;
    this.y = y;
    }
}

int gSizeX = 3000;
int gSizeY = 3000;

float posX = gSizeX/2;
float posY = gSizeY/2 - 300;


//////////// mouse

public class Mouse {
    int x = mouseX;
    int y = mouseY;
    
    boolean isPressed = false;
    boolean isReleased = false;
    boolean isDragged = false;
    int pressedTimer = 0;
    int releasedTimer = 0;
    boolean clicked = false;
    boolean released = false;
    
    
    // selecting when mouse.selecting && mouse.clickNum == 0
    
    boolean selecting = false;
    boolean select = false;
    int clickNum = 0;
    Coords click1 = new Coords(x, y);
    Coords click2 = new Coords(x, y);
    
    
    
    public Mouse() {
    
    }
    
    void addPressed() {
    pressedTimer += 1;
    }
    
    void addReleased() {
    releasedTimer += 1;
    }
    
    void update() {
    
    if (pressedTimer == 1) {
    clicked = true;
    } else {
    clicked = false;
    }
    
    if (releasedTimer == 1) {
    released = true;
    } else {
    released = false;
    }
    }
    
    void check() {
    x = mouseX;
    y = mouseY;
    
    if (isPressed) {
    pressedTimer += 1;
    } else {
    pressedTimer = 0;
    }
    
    if (pressedTimer == 1) {
    clicked = true;
    } else {
    clicked = false;
    }
    
    if (isReleased) {
    releasedTimer += 1;
    } else {
    releasedTimer = 0;
    }
    
    if (releasedTimer == 1) {
    released = true;
    } else {
    released = false;
    }
    
    
    if (clickNum == 0) {
    selecting = false;
    }
    
    // selecting - hold shift
    if (keys[16].pressed) {
    if (released) {
    clickNum += 1;
    
    if (clickNum == 1) {
    selecting = true;
    click1.x = x + (int) round(posX);
    click1.y = y + (int) round(posY);
    }
    
    if (clickNum == 2) {
    selecting = true;
    click2.x = x + (int) round(posX);
    click2.y = y + (int) round(posY);
    }
    
    }    // if released
    } else {
    // shift is not held
    if (clicked) {
    clickNum = 0;
    selecting = false;
    }
    }
    
    // 0 - nothing selected; 1 - 1st point selected; 2 - 2nd point selected --> immediately back to 0
    if (clickNum > 1) {
    clickNum = 0;
    }
    
    select = selecting && clickNum == 0;
    
    }
    
    
    void draw() {
    stroke(0, 0, 0);
    line(x - 20, y - 20, x + 20, y + 20);
    line(x + 20, y - 20, x - 20, y + 20);
    
    if (clickNum == 1) {
    pushMatrix();
    translate(-posX, -posY);
    fill(255, 255, 255, 100);
    stroke(255, 255, 255);
    rect(click1.x, click1.y, (x + posX) - click1.x, (y + posY) - click1.y);
    noStroke();
    popMatrix();
    }
    }
}

Mouse mouse = new Mouse();

void mousePressed() {
    mouse.isPressed = true;
    mouse.isReleased = false;
}

void mouseDragged() {
    mouse.isDragged = true;
}

void mouseReleased() {
    mouse.isPressed = false;
    mouse.isDragged = false;
    mouse.isReleased = true;
}





////////////////////////////////////////////////////////// Setup
void setup() {
    size(900, 600, P2D);
    frameRate(33);
    
    loadImages();
    
    monaco = createFont("monaco", 20);
    
    for (int i = 0; i < keys.length; i++) {
    keys[i] = new Key(i);
    }
}

class Point {
    float x; float y;
    
    public Point(float x, float y) {
    this.x = x;
    this.y = y;
    }
    
    public Point(Point pt) {
    this.x = pt.x;
    this.y = pt.y;
    }
}

class Dimensions {
    int x;
    int y;
    
    public Dimensions(int x, int y) {
    this.x = x;
    this.y = y;
    }
}

class PolarVec {
    float angle;
    int dir;
    
    public PolarVec(float angle, int dir) {
    this.angle = angle;
    this.dir = dir;
    }
}

float distSq(float x, float y) {
    return (float) (pow(x, 2) + pow(y, 2));
}

float smallerDiff(float x, float y) {
    if (y > x) {
    return x - y;
    } else {
    return y - x;
    }
}

boolean inBetween(float x, float m, float n) {
    return (x > m && x < n) || (x > n && x < m);
}

boolean inBetweenD(float x, float min, float max) {
    return (x > pow(min, 2) && x < pow(max, 2));
}

float angle(float ang) {
    float angl = ang;
    
    if (angl < 0) {
    angl += TWO_PI;
    
    }
    
    if (angl > TWO_PI) {
    angl -= TWO_PI;
    }
    
    return angl;
}

int soldierCount = 0;

class Projectile {
    Point pos;
    Point pPos;
    Point prev;
    
    Point end;
    
    float x;
    float y;
    
    float angle;
    int speed;
    int size;
    
    float distToEnd = 0;
    
    boolean explode = false;
    
    
    public Projectile(Point pos, float angle, int speed, int size, Point end) {
    x = pos.x;
    y = pos.y;
    
    this.end = new Point(end);
    prev = new Point(x, y);
    
    this.angle = angle;
    this.speed = speed;
    this.size = size;
    }
    
    void update() {
    prev.x = x;
    prev.y = y;
    /*x = 500;
    y = 500;*/
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    
    distToEnd = distSq(x - end.x, y - end.y);
    }
    
    void draw() {
    // fill(100, 100, 100);
    fill(0, 0, 0);
    ellipse(x, y, size, size);
    }
}

void orb(float x, float y, int[] orbColor, float size, boolean flicker) {
    float flickerSize = 0;
    if (flicker) {
    flickerSize = random(-size/5, size/5);
    }
    int diff1 = 0;
    int diff2 = 0;
    int diff3 = 0;
    
    int circs = 7;
    
    for (int i = 0; i < circs; i++) {
    // fill(255, 255, 200 + (i * i * 55)/100, i * i);
    diff1 = 255 - orbColor[0];
    diff2 = 255 - orbColor[1];
    diff3 = 255 - orbColor[2];
    noStroke();
    fill(
    orbColor[0] + (i * i * diff1)/(pow(circs, 2)),
    orbColor[1] + (i * i * diff2)/(pow(circs, 2)),
    orbColor[2] + (i * i * diff3)/(pow(circs, 2)),
    i * i);
    ellipse(
    x, y,
    (size + flickerSize) * 0.6 * (100 - (pow(i, 1) * 7)),
    (size + flickerSize) * 0.6 * (100 - (pow(i, 1) * 7))
    );
    }
};





////////////////////////////
/////////////// Names
String[] names = {"Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes"};


/////////////////////////////////
int shareChangeTargetFrame = 60;

// int soldier

int soldierID = 0;

int soldiersX = 10;
int soldiersDistX = 40;
int soldiersDistY = 25;

class Soldier {
    
    int officerID;
    int id = 0;
    String name = "";
    
    boolean surrender = false;
    
    boolean inFrustum = true;
    boolean inHudson = false;
    boolean inMills = false;
    boolean inMap = true;    // if not, health rapidly deteriorates
    
    int index = 0;
    int baseIndex = 0;
    
    int onBaseImg;
    
    // "battle" or "base"
    String place;
    
    // Point position;
    
    float x; float y;
    
    boolean areEnemies = true;
    
    // Point destination;
    Point target = new Point(0, 0);    // will change througout
    String targetType = "";
    
    float targetAngle = 0;
    float distance = 0;
    int image;
    
    boolean change = false;
    
    int walkFrame = 0;
    int totalFrames = (round(random(0, 3)) * 6) + 54;
    int changeFrame = 6;
    boolean walking = false;
    int walkFrames = 2;
    
    int reloadFrame = 0;
    int deathImg = (int) round(random(0, 1));
    
    // 0 - idle, 1 - advance, 2 - engage (shoots, reloads, does not advance);
    String state = "idle";
    
    boolean selected = false;
    
    boolean canMove = true;
    
    String rank;
    
    int reloadTime;
    int reloadCounter = 0;
    
    // ArrayList<Projectile> projectiles;
    
    int changeTargetFrame = shareChangeTargetFrame;
    int targetFrameCounter = 0;
    int targetIndex = 0;
    boolean aggressive = false;
    Point escape = new Point(0, 0);
    
    boolean deciding = false;
    
    int decideFactor = 0;
    float distToEsc = 0;
    boolean runAway = false;
    
    int teamSize = 0;
    int friendIndex = 0;
    float distToFriend = 0;
    boolean provideCover = false;
    Point friend = new Point(0, 0);
    
    Point closest;
    float distToCloser;
    float distToClosest;
    int closestIndex;
    
    boolean targetClosest = false;
    boolean targetEnemy = false;
    
    boolean stepBack = false;
    
    Point targeter = new Point(0, 0);
    int targeterIndex = -1;
    float distToTargeter = 100000.0;
    
    boolean fighting = false;
    
    float angle;
    float walkSpeed = random(3, 4);
    float speedMod = 1;
    int directionChange = 3;
    
    float health = 100;
    
    public Soldier(Point position, String place) {
    // this.image = image;
    this.x = position.x;
    this.y = position.y;
    
    this.place = place;
    
    reloadTime = round(random(80, 100));
    }
    
    int[] yellow = {255, 255, 150};
    
    int homeButton = 0;
    
    void update() {
    inFrustum = inBetween(x, posX, posX + screenX) && inBetween(y, posY, posY + screenY);
    
    inMap = inBetween(x, 0, gSizeX) && inBetween(y, 0, gSizeY);
    
    if (!inMap && place.equals("battle")) {
    health -= 1;
    
    if (health > 0) {
    textSize(10);
    fill(0, 0, 0);
    text("Poisonous gases!!", x + 10, y - 30);
    }
    }
    
    inHudson = inMap && x > (gSizeX - 100) && x < (gSizeX - 100 + 30);
    
    if (inHudson && place.equals("battle")) {
    y += 5;
    health -= 0.75;
    
    if (health > 0) {
    fill(0, 0, 0);
    textSize(10);
    text("HELP MEEEE!!!", x + 10, y - 30);
    }
    }
    
    }
    
    void interact() {
    
    if (mouse.select) {
    if (inBetween(x, mouse.click1.x, mouse.click2.x) &&
    inBetween(y, mouse.click1.y, mouse.click2.y)) {
    selected = true;
    }
    }
    
    // number key and SHIFT is not held
    // u - select all
    if (place.equals("battle") && keys[homeButton].pressed && keys[85].clicked && !keys[16].pressed) {
    selected = true;
    }
    
    // c - deselect all
    if (keys[homeButton].pressed && keys[67].clicked && !keys[16].pressed) {
    selected = false;
    }
    
    // i = select inverse
    if (keys[homeButton].pressed && keys[73].clicked && !keys[16].pressed) {
    selected = !selected;
    }
    
    if (mouse.clicked && !keys[16].pressed) {
    if (distSq(mouse.x - x + posX, mouse.y - y + posY) < 400) {
    mouse.pressedTimer += 1;
    mouse.update();
    selected = true;
    } else {
    selected = false;
    }
    }
    
    if (selected && inFrustum) {
    if (place.equals("battle")) {
    fill(255, 255, 100, 100);
    ellipse(x, y, 30, 30);
    noFill();
    stroke(255, 255, 0);
    strokeWeight(1);
    ellipse(x, y, 35, 35);
    noStroke();
    }
    
    if (place.equals("base")) {
    fill(255, 255, 100, 100);
    ellipse(x, y, 30, 30);
    noFill();
    stroke(255, 255, 0);
    strokeWeight(1);
    //ellipse(x, y, 35, 35);
    line(x - 35, y, x, y - 35);
    line(x, y - 35, x + 35, y);
    line(x + 35, y, x, y + 35);
    line(x, y + 35, x - 35, y);
    
    line(x - 44, y, x, y - 44);
    line(x, y - 44, x + 44, y);
    line(x + 44, y, x, y + 44);
    line(x, y + 44, x - 44, y);
    noStroke();
    }
    }
    }
    
    Coords base;
    
    // for everyone
    void onBase() {
    state = "idle";
    
    if (selected && keys[16].pressed && keys[38].clicked) {
    place = "battle";
    }
    
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    image(pictures[onBaseImg].image, -pictures[onBaseImg].size.x/2, -pictures[onBaseImg].size.y/2);
    popMatrix();
    }
    
    // coordinates based on baseIndex
    }
    
    void inBattle() {
    if (health > 0 && selected && keys[16].pressed && keys[40].clicked) {
    place = "base";
    }
    }
    
    void draw() {
    
    }
    
    void wounded() {
    
    }
}

int baseDistX = 85;
int baseDistY = 30;
int defaultSoldiersX = 25;
int brSoldiersX = 25;
int amSoldiersX = 30;

class Infantry extends Soldier {
    
    // int homeButton = 0;
    
    int baseSoldiersX;
    
    int idleNum;
    int walk1;
    int walk2;
    int fire;
    int die1;
    int die2;
    
    int punchCounter = 0;
    int punchFrame = 10;
    
    int fireCounter = 0;
    int fireFrame = 1;
    int reloadTime = 60;
    
    ArrayList<Soldier> enemies;
    ArrayList<Projectile> projs;
    
    public Infantry(Point position, String place) {
    super(position, place);
    // homeButton = super.homeButton;
    
    onBaseImg = 31;
    }
    
    void drawGun() {
    if (!walking) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    fill(128, 95, 43);
    rect(-8, -7, 3, 50);
    
    fill(145, 110, 55);
    rect(-9, -7, 5, 20);
    
    fill(150, 150, 150);
    rect(-9, 5, 5, 20);
    popMatrix();
    }
    
    }
    
    void fight() {
    // punch punch
    if (targetIndex < enemies.size() && distSq(enemies.get(targetIndex).x - x, enemies.get(targetIndex).y - y) < 300) {
    fireCounter = 0;
    punchCounter += 1;
    
    if (punchCounter > 10) {
    punchCounter = 0;
    }
    
    if (areEnemies && targetIndex < enemies.size() && punchCounter == 1) {
    enemies.get(targetIndex).health -= 10;
    }
    } else {
    punchCounter = 0;
    
    drawGun();
    
    // shoot
    punchCounter = 0;
    
    fireCounter += 1;
    
    if (fireCounter > reloadTime) {
    fireCounter = 0;
    }
    
    if (fireCounter == 1) {
    // start a bullet offset in the X direction
    fill(255, 255, 0);
    ellipse(x + (43.7 * cos(angle + (10 * PI/180))), y + (43.7 * sin(angle + (10 * PI/180))), 20, 20);
    
    float distAway = distance + 1000;
    Point end = new Point(
    x + (distAway * cos(angle)),
    y + (distAway * sin(angle))
    );
    
    Point ps = new Point(x, y);
    // gunx * cos(angle)
    // guny * sin(angle)
    ps.x = x + (43.7 * cos(angle + (10 * PI/180)));
    ps.y = y + (43.7 * sin(angle + (10 * PI/180)));
    
    Projectile bullet = new Projectile(new Point(ps), angle + (random(-2, 2) * PI/180), 20, 3, end);
    // calculate end.x and end.y, which are far away
    projs.add(bullet);
    
    x += cos(angle + PI) * 3;
    y += sin(angle + PI) * 3;
    }
    }
    
    }
    
    void draw() {
    
    // if on the river, get carried south, lose health
    
    // also, if off the map, die
    
    // update properties here, only if selected
    if (selected) {
    
    if (keys[53].clicked) {
    fighting = !fighting;
    }
    
    // 1 - freeze, idle
    if (keys[49].clicked && !keys[32].pressed) {
    state = "idle";
    fighting = false;
    }
    
    // 2 - advance with officer
    if (keys[50].clicked && !keys[32].pressed) {
    state = "advance";
    fighting = false;
    }
    
    // 3 - engage at will, always fire or punch
    if (keys[51].clicked && !keys[32].pressed) {
    state = "engage at will";
    fighting = true;
    }
    
    if (keys[82].clicked && !keys[32].pressed) {
    state = "runFromMouse";
    }
    
    // go to base
    /*if (keys[40].clicked) {
    place = "base";
    }*/
    
    }
    
    if (state.equals("idle")) {
    walking = false;
    
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[idleNum].image, -pictures[idleNum].size.x/2, -pictures[idleNum].size.y/2);
    popMatrix();
    }
    
    }
    
    if (state.equals("advance")) {
    // will advance to target
    
    targetType = "order";
    walking = true;
    
    
    // define target; will later ba a GENERAL
    // target.x = mouse.x + posX;
    // target.y = mouse.y + posY;
    
    target.x = mouse.x + posX + ((int) (index % soldiersX) * soldiersDistX) - (soldiersDistX * soldiersX/2);
    target.y = mouse.y + posY + ((int) (index/soldiersX) * soldiersDistY);
    
    distance = distSq(x - target.x, y - target.y);
    
    if (distance > 25) {
    angle = atan2(target.y - y, target.x - x);
    }
    
    
    if (fighting) {
    fight();
    }
    
    // if not in walk mode
    }
    
    if (state.equals("runFromMouse")) {
    walking = true;
    
    target.x = mouse.x + posX;
    target.y = mouse.y + posY;
    
    angle = atan2(target.y - y, target.x - x) + PI;
    
    distance = distSq(x - target.x, y - target.y);
    }
    
    
    //////// engaging the enemy
    if (state.equals("engage at will")) {
    targetFrameCounter += 1;
    
    /*if (keys[homeButton].pressed && keys[187].clicked) {
    aggressive = !aggressive;
    }*/
    
    if (targetFrameCounter > changeTargetFrame) {
    targetFrameCounter = 0;
    }
    
    
    if (enemies.size() > 0) {
    areEnemies = true;
    } else {
    areEnemies = false;
    }
    
    // !deciding && areEnemies && (targetFrameCounter == round(random(0, shareChangeTargetFrame)) || targetIndex >= enemies.size())
    change = areEnemies && (targetFrameCounter == round(random(0, shareChangeTargetFrame)) || targetIndex >= enemies.size());
    
    ////////// if time to target
    if (change) {
    
    deciding = true;
    
    decideFactor = (int) round(random(1, 3));
    runAway = decideFactor == 1 && distance < 22500;
    targetEnemy = decideFactor == 2;
    targetClosest = true;
    
    // provideCover = decideFactor == 3 && distance < 10000;
    
    escape.x = x + random(-150, 150);
    escape.y = y + random(-50, 50);
    
    if (areEnemies) {
    targetIndex = (int) round(random(0, enemies.size() - 1));
    targetIndex = (int) round(random(0, enemies.size() - 1));
    
    }
    
    // end time to target
    } else {
    deciding = false;
    }    
    
    
    //////////////////////////////////////// begin chased!
    if (targetIndex > 0 && targetIndex < enemies.size()) {
    enemies.get(targetIndex).targeterIndex = index;
    
    // when an ally of an enemy dies
    // make sure the target index is synchronized
    
    }
    
    // check if being targeted
    // this soldier's own targeterIndex was set by another (enemy) soldier
    if (targeterIndex >= 0 && targeterIndex < enemies.size()) {
    // when an ally dies
    // make sure your index is synchronized with enemy's targetIndex
    
    /*if (!enemies.get(targeterIndex).deciding) {
    enemies.get(targeterIndex).targetIndex = index;
    }*/
    
    
    targeter.x = enemies.get(targeterIndex).x;
    targeter.y = enemies.get(targeterIndex).y;
    
    distToTargeter = distSq(targeter.y - y, targeter.x - x);
    
    if (distToTargeter < 100) {
    stepBack = true;
    } else {
    stepBack = false;
    }
    }
    //////////////////////
    
    //////////////////////////////////////////////
    ////////////// 3 or 4 Engage actions
    // attack
    /*if (provideCover) {
    // float distToFriend = 0;
    // boolean provideCover = false;
    // Point friend = new Point(0, 0);
    
    // if
    
    // distToFriend = distSq();
    }*/
    
    if (stepBack) {
    targetType = "back";
    
    angle = atan2(targeter.y - y, targeter.x - x) + PI;
    
    walking = true;
    
    } else if (runAway && !targetEnemy) {    // run away: the poor guy chose to run away
    targetType = "escape";
    
    distToEsc = distSq(x - escape.x, y - escape.y);
    walking = true;
    
    if (distToEsc > 25) {
    angle = atan2(escape.y - y, escape.x - x);
    } else {
    runAway = false;
    }
    
    
    /*noFill();
    stroke(0, 0, 0);
    line(x, y, escape.x, escape.y);
    stroke(255, 255, 0);
    ellipse(x, y, 40, 40);
    stroke(0, 0, 255);
    ellipse(escape.x, escape.y, 40, 40);
    noStroke();*/
    
    
    } else {
    targetType = "enemy";
    
    if (targetClosest) {
    if (deciding) {
    for (int i = 0; i < enemies.size(); i++) {
    if (i == 0) {
    distToCloser = distSq(x - enemies.get(i).x, y - enemies.get(i).y);
    closestIndex = i;
    }
    
    if (distSq(x - enemies.get(i).x, y - enemies.get(i).y) < distToCloser) {
    distToCloser = distSq(x - enemies.get(i).x, y - enemies.get(i).y);
    closestIndex = i;
    }
    }
    }
    
    if (closestIndex < enemies.size()) {
    target.x = enemies.get(closestIndex).x;
    target.y = enemies.get(closestIndex).y;
    }
    
    } else {    // choose target randomly
    if (targetIndex <= enemies.size() - 1) {
    target.x = enemies.get(targetIndex).x;
    target.y = enemies.get(targetIndex).y;
    }
    }
    
    
    
    distance = distSq(x - target.x, y - target.y);
    
    if (distance > 25 && areEnemies) {
    
    angle = atan2(target.y - y, target.x - x);
    }
    
    
    
    if ((inBetweenD(distance, 400, 600) || inBetweenD(distance, 800, 1000) || inBetweenD(distance, 0, 200)) || !areEnemies) {
    
    walking = false;
    
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI + (30 * PI/180));
    image(pictures[fire].image, -pictures[fire].size.x/2, -pictures[fire].size.y/2);
    popMatrix();
    }
    
    if (enemies.size() > 0) {
    fight();
    }
    
    } else {
    walking = true;
    }
    
    
    /////////////////////////////////
    }
    ///////////////////////////////////////////////// end attacks
    
    
    } else {
    targetFrameCounter = 0;
    
    }    // end if engaged //////////////////////////////////////////////////////////////
    
    if (walking) {
    
    walkFrame += 1;
    
    if (targetType.equals("escape")) {
    
    if (distSq(x - escape.x, y - escape.y) < 25) {
    speedMod = 0;
    } else {
    speedMod = 1;
    }
    
    } else if (targetType.equals("order")) {
    
    if (distSq(x - target.x, y - target.y) < 25) {
    speedMod = 0;
    } else {
    speedMod = 1;
    }
    
    
    } else if (targetType.equals("enemy")) {
    
    if (distSq(x - target.x, y - target.y) < 25) {
    speedMod = 0;
    } else {
    speedMod = 1;
    }
    
    } else if (targetType.equals("back")) {
    
    }
    
    x += cos(angle) * walkSpeed * speedMod;
    y += sin(angle) * walkSpeed * speedMod;
    
    
    // greatest is 59
    if (walkFrame >= totalFrames) {
    walkFrame = 0;
    }
    
    
    if (walkFrame/(changeFrame) % 2 == 0) {
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[walk1].image, -pictures[walk1].size.x/2, -pictures[walk1].size.y/2);
    popMatrix();
    }
    
    } else {
    // greatest is 29
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[walk2].image, -pictures[walk2].size.x/2, -pictures[walk2].size.y/2);
    popMatrix();
    }
    }
    
    // else not walking
    } else {
    
    }
    
    // healh bar
    if (health < 100 && health > 0) {
    fill(510 - health/100 * 510, health/100 * 510, 0);
    rect(x - 20, y - 25, health * 0.4, 1);
    }
    
    
    if (selected) {
    textSize(10);
    fill(0, 150, 255);
    text("Pvt. " + name + " " + id, x - 10, y + 20);
    }
    
    if (keys[homeButton].pressed && keys[88].clicked) {
    // health = 0;
    }
    
    }    // end void draw()
    ////////////////////////
    
    // infantry only
    void onBase() {
    
    state = "advance";
    fighting = false;
    
    if (selected && keys[16].pressed && keys[38].clicked) {
    place = "battle";
    }
    
    if (place.equals("base")) {
    x = base.x + (baseIndex % baseSoldiersX) * baseDistX + ((((int) baseIndex/baseSoldiersX) % 2) * baseDistX/2);
    y = base.y + ((int) baseIndex/baseSoldiersX) * baseDistY;
    }
    
    
    health = 100;
    
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    image(pictures[onBaseImg].image, -pictures[onBaseImg].size.x/2, -pictures[onBaseImg].size.y/2);
    popMatrix();
    }
    
    // coordinates based on baseIndex
    }
    
    
    void wounded() {
    health -= 1;
    
    if (inFrustum) {
    if (deathImg == 0) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[die1].image, -pictures[die1].size.x/2, -pictures[die1].size.y/2);
    popMatrix();
    } else if (deathImg == 1) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[die2].image, -pictures[die2].size.x/2, -pictures[die2].size.y/2);
    popMatrix();
    }
    }
    
    }
}    // end class Infantry


class AmericanSoldier extends Infantry {
    public AmericanSoldier(Point position, String place) {
    super(position, place);
    
    homeButton = 65;
    
    idleNum = 0;
    walk1 = 1;
    walk2 = 2;
    fire = 3;
    die1 = 6;
    die2 = 7;
    
    enemies = BritishPositions;
    projs = amProjs;
    
    base = new Coords(300, gSizeY - 850);
    
    baseSoldiersX = amSoldiersX;
    
    }
}

class Artillery extends Soldier {
    
    int fireCounter = 0;
    int reloadTime = 120;
    
    int idleImg;
    int fireImg;
    int dieImg;
    
    public Artillery(Point position, String place) {
    super(position, place);
    
    onBaseImg = 32;
    }
    
    void draw() {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[idleImg].image, -pictures[idleImg].size.x/2, -pictures[idleImg].size.y/2);
    popMatrix();
    }
    
    void wounded() {
    if (inFrustum) {
    pushMatrix();
    translate(x, y);
    rotate(angle - HALF_PI);
    image(pictures[dieImg].image, -pictures[dieImg].size.x/2, -pictures[dieImg].size.y);
    popMatrix();
    }
    
    }
    
}


class AmericanArt extends Artillery {
    
    public AmericanArt(Point position, String place) {
    super(position, place);
    canMove = false;
    
    idleImg = 8;
    fireImg = 9;
    dieImg = 10;
    }
    
}

class AmericanGeneral extends Soldier {
    
    public AmericanGeneral(Point position, String place) {
    super(position, place);
    
    this.health = 1000.0;
    }
    
}


class BritishSoldier extends Infantry {
    public BritishSoldier(Point position, String place) {
    super(position, place);
    
    homeButton = 83;
    
    idleNum = 15;
    walk1 = 16;
    walk2 = 17;
    fire = 18;
    die1 = 21;
    die2 = 22;
    
    enemies = AmericanPositions;
    
    projs = brProjs;
    
    base = new Coords(300, 100);
    
    baseSoldiersX = brSoldiersX;
    
    }
}

class BritishArt extends Artillery {
    
    public BritishArt(Point position, String place) {
    super(position, place);
    canMove = false;
    
    deathImg = 0;
    }
    
}

class BritishGeneral extends Soldier {
    
    public BritishGeneral(Point position, String place) {
    super(position, place);
    
    this.health = 1000.0;
    }
    
}


class Asset {
    int x;
    int y;
    boolean inFrustum = false;
    
    public Asset(int x, int y) {
    this.x = x;
    this.y = y;
    }
    
    
    void update() {
    inFrustum = inBetween(x, posX, posX + screenX) && inBetween(y, posY, posY + screenY);
    }
    
    void draw() {
    
    }
}

class Tree extends Asset {
    
    public Tree(int x, int y) {
    super(x, y);
    }
    
    void draw() {
    noStroke();
    fill(0, 150, 0);
    ellipse(x, y - 8, 20, 16);
    ellipse(x, y + 8, 20, 16);
    ellipse(x - 12, y - 6, 16, 12);
    ellipse(x + 12, y - 6, 16, 12);
    ellipse(x - 12, y + 6, 16, 12);
    ellipse(x + 12, y + 6, 16, 12);
    ellipse(x - 20, y, 20, 10);
    ellipse(x + 20, y, 20, 10);
    }
}

void tree(int x, int y) {
    noStroke();
    fill(0, 150, 0);
    ellipse(x, y - 8, 20, 16);
    ellipse(x, y + 8, 20, 16);
    ellipse(x - 12, y - 6, 16, 12);
    ellipse(x + 12, y - 6, 16, 12);
    ellipse(x - 12, y + 6, 16, 12);
    ellipse(x + 12, y + 6, 16, 12);
    ellipse(x - 20, y, 20, 10);
    ellipse(x + 20, y, 20, 10);
}

ArrayList<Projectile> amProjs = new ArrayList<Projectile>();
ArrayList<Projectile> brProjs = new ArrayList<Projectile>();


ArrayList<Soldier> AmericanBase = new ArrayList<Soldier>();
ArrayList<Soldier> AmericanPositions = new ArrayList<Soldier>();

ArrayList<Soldier> MorganRifles = new ArrayList<Soldier>();

ArrayList<Soldier> woundedAmericans = new ArrayList<Soldier>();

ArrayList<Soldier> BritishBase = new ArrayList<Soldier>();
ArrayList<Soldier> BritishPositions = new ArrayList<Soldier>();
ArrayList<Soldier> woundedBritish = new ArrayList<Soldier>();

void addAmericanBase() {
    soldierID += 1;
    
    AmericanSoldier bill = new AmericanSoldier(
    new Point(0, 0), "base");

    bill.angle = random(-20, 20) * PI/180 + HALF_PI + PI;
    bill.reloadTime = round(random(80, 100));
    bill.id = soldierID;
    bill.name = names[round(random(0, names.length - 1))];
    
    AmericanBase.add(bill);
}

void addBritishBase() {
    soldierID += 1;
    
    BritishSoldier bob = new BritishSoldier(
    new Point(0, 0), "base");

    bob.angle = random(-20, 20) * PI/180 + HALF_PI + PI;
    bob.reloadTime = round(random(80, 100));
    bob.id = soldierID;
    bob.name = names[round(random(0, names.length - 1))];
    
    BritishBase.add(bob);
}

void addAmericanBattle() {
    soldierID += 1;
    AmericanSoldier bill = new AmericanSoldier(
    new Point(mouse.x + posX, mouse.y + posY), "battle");
    
    bill.angle = random(-20, 20) * PI/180 + HALF_PI + PI;
    bill.reloadTime = round(random(80, 100));
    bill.id = soldierID;
    bill.name = names[round(random(0, names.length - 1))];

    AmericanPositions.add(bill);
}

void addBritishBattle() {
    soldierID += 1;
    
    BritishSoldier bob = new BritishSoldier(
    new Point(mouse.x + posX, mouse.y + posY), "battle");
    
    bob.angle = random(-20, 20) * PI/180 + HALF_PI;
    bob.reloadTime = round(random(80, 100));
    bob.id = soldierID;
    bob.name = names[round(random(0, names.length - 1))];

    BritishPositions.add(bob);
}

void loadingSoldiers() {
    // place all soldiers into position
    if (time == 10) {
    for (int i = 0; i < 750; i++) {
    
    addAmericanBase();
    
    }
    
    for (int i = 0; i < 150; i++) {
    
    addBritishBase();
    }
    }
}


void debugScreen() {
    fill(0, 0, 0, 150);
    rect(30, 30, 150, 300);
    fill(0, 255, 0);
    textFont(monaco, 10);
    text("\n\nframerate: " + frameRate + "\n(" + mouseX + ", " + mouseY + ")\n" + posX + ", " + posY + "\nkeys: " + pressedKeys.size() + "\nselect" + mouse.select
    + "\namericans: " + AmericanPositions.size() + "\nBritish: " + BritishPositions.size()
    + "\nam_projs: " + amProjs.size() + "\nbr_projs: " + brProjs.size() + "\ntime: " + time, 45, 30);
    
    /*for (int l = 0; l < pressedKeys.size(); l++) {
    int i = l + 1;
    int b = pressedKeys.get(l).intValue();
    
    fill(0, 0, 0, 150);
    rect((i % 4) * 180 + 200, 30 + (i/4) * 210, 150, 180);
    fill(166, 255, 255);
    text("\n\n[keyCode: " + pressedKeys.get(l).intValue() + "]\n------------\npressed: " + keys[b].pressed + "\nreleased: " + keys[b].released + "\nclicked: "
    + keys[b].clicked + "\npressedTimer: " + keys[b].pressedTimer + "\nreleasedTimer: " + keys[b].releasedTimer, (i % 4) * 180 + 215, 30 + (i/4) * 210);
    }
    
     fill(0, 0, 0, 150);
    rect(200, 30 + (0/4) * 210, 150, 180);
    fill(166, 255, 255);
    text("\n\n[keyCode: " + keys[32].code + "]\n------------\npressed: " + keys[32].pressed + "\nreleased: " + keys[32].released + "\nclicked: "
    + keys[32].clicked + "\npressedTimer: " + keys[32].pressedTimer + "\nreleasedTimer: " + keys[32].releasedTimer, 215, 30);*/
}



int addSoldierFrame = 2;

void addingSoldiers() {
    if (keys[32].pressed) {
    //if (mouse.clicked) {
    if (keys[16].pressed) {
    soldierCount += 1;
    
    if (soldierCount > 60) {
    soldierCount = 0;
    }
    if (keys[49].pressed) {
    addBritishBattle();
    }
    
    if (keys[50].pressed) {
    
    }
    
    if (keys[51].pressed) {
    
    }
    
    } else {
    soldierCount += 1;
    
    if (soldierCount > shareChangeTargetFrame) {
    soldierCount = 0;
    }
    
    if (keys[49].pressed) {
    addAmericanBattle();
    }
    
    if (keys[50].pressed) {
    
    }
    
    if (keys[51].pressed) {
    
    }
    
    }
    }
}

// float posX = 0;
// float posY = 0;

float v_x = 0;
float v_y = 0;

float accel_factor = 8;
float attenuation_factor = 0.8;
float threshold = 0.05;

int tileSize = 200;
int tilesX = gSizeX/tileSize;
int tilesY = gSizeY/tileSize;

int firstX = 0;
int lastX = 0;
int firstY = 0;
int lastY = 0;


int day = 1;


void gameScreen() {
    background(255, 255, 255);
    
    addingSoldiers();
    
    if (keys[37].pressed && !keys[65].pressed && !keys[83].pressed && !keys[16].pressed) {
    v_x -= 1 * accel_factor;
    }
    
    if (keys[39].pressed && !keys[65].pressed && !keys[83].pressed && !keys[16].pressed) {
    v_x += 1 * accel_factor;
    }
    
    if (keys[38].pressed && !keys[65].pressed && !keys[83].pressed && !keys[16].pressed) {
    v_y -= 1 * accel_factor;
    }
    
    if (keys[40].pressed && !keys[65].pressed && !keys[83].pressed && !keys[16].pressed) {
    v_y += 1 * accel_factor;
    }
    
    v_x *= attenuation_factor;
    v_y *= attenuation_factor;
    
    if (posX < -screenX/2) {
    posX = -screenX/2;
    }
    
    if (posY < -screenY/2) {
    posY = -screenY/2;
    }
    
    if (posX > gSizeX - screenX/2) {
    posX = gSizeX - screenX/2;
    }
    
    if (posY > gSizeY - screenY/2) {
    posY = gSizeY - screenY/2;
    }
    
    posX += v_x;
    posY += v_y;
    
    firstX = (int) ceil(posX/tileSize) - 1;
    firstY = (int) ceil(posY/tileSize) - 1;
    
    lastX = (int) floor((posX + screenX)/tileSize) + 1;
    lastY = (int) floor((posY + screenY)/tileSize) + 1;
    
    if (firstX < 0) {
    firstX = 0;
    }
    
    if (firstY < 0) {
    firstY = 0;
    }
    
    if (lastX < 0) {
    lastX = 0;
    }
    
    if (lastY < 0) {
    lastY = 0;
    }
    
    if (firstX > tilesX) {
    firstX = tilesX;
    }
    
    if (firstY > tilesY) {
    firstY = tilesY;
    }
    
    if (lastX > tilesX) {
    lastX = tilesX;
    }
    
    if (lastY > tilesY) {
    lastY = tilesY;
    }
    
    
    
    
    
    
    pushMatrix();
    translate(-posX, -posY);

    fill(80, 190, 0);
    rect(0, 0, gSizeX, gSizeY);
    
    for (int i = firstX; i < lastX; i++) {
    for (int j = firstY; j < lastY; j++) {
    fill(0, 150, 0);
    rect(30 + (i * tileSize), 40 + (j * tileSize), 3, 3);
    fill(150, 255, 80);
    rect(100 + (i * tileSize), 120 + (j * tileSize), 7, 7);
    fill(90, 230, 50);
    rect(140 + (i * tileSize), 60 + (j * tileSize), 5, 5);
    fill(60, 110, 40);
    rect(40 + (i * tileSize), 160 + (j * tileSize), 1, 1);
    
    }
    }
    
    // Freeman's Farm
    image(pictures[33].image, gSizeX - 350 - pictures[33].size.x, gSizeY/2 - 300);
    
    fill(255, 255, 255);
    textFont(monaco, 30);
    text("Freeman's Farm", gSizeX - 350, gSizeY/2 - 200);
    
    // Hudson River
    pushMatrix();
    translate(gSizeX - 150, gSizeY/2);
    rotate(HALF_PI);
    fill(255, 255, 255);
    text("Hudson River", -100, 0);
    popMatrix();
    fill(0, 150, 255);
    rect(gSizeX - 100, 0, 30, gSizeY);
    
    stroke(0, 0, 0);
    for (int i = 0; i < 10; i++) {
    int x = round(random(gSizeX - 100 + 5, gSizeX - 100 + 30 - 5));
    int y = round(random(0, gSizeY));
    int length = round(random(5, 50));
    line(x, y, x, y + length);
    }
    noStroke();
    
    // American Base
    fill(0, 0, 0);
    text("American Encampment", gSizeX/2, gSizeY + 50);
    
    // British Base
    fill(255, 255, 255);
    text("British Encampment", gSizeX/2, 50);
    
    // You have reached the boundary of the map.
    
    
    // Welcome message
    
    text("Welcome to the Battle of Saratoga\nInteractive Reenactment.", gSizeX/2 + 100, gSizeY/2);
    
    
    
    //image(pictures[30].image, 0, 0, pictures[30].size.x, pictures[30].size.y);
    
    for (int i = 0; i < amProjs.size(); i++) {
    amProjs.get(i).update();
    amProjs.get(i).draw();
    
    if (amProjs.get(i).x < 0 || amProjs.get(i).x > gSizeX || amProjs.get(i).y < 0 || amProjs.get(i).y > gSizeY) {
    amProjs.remove(i);
    i -= 1;
    continue;
    }
    
    int j = 0;
    boolean hit = false;
    while (!hit && j < BritishPositions.size()) {
    if (distSq(amProjs.get(i).x - BritishPositions.get(j).x, amProjs.get(i).y - BritishPositions.get(j).y) < 100) {
    BritishPositions.get(j).x += cos(amProjs.get(i).angle) * 10;
    BritishPositions.get(j).y += sin(amProjs.get(i).angle) * 10;
    BritishPositions.get(j).health -= 20;
    hit = true;
    
    
    }
    
    j++;
    }
    
    if (hit) {
    amProjs.remove(i);
    i -= 1;
    }
    }
    
    for (int i = 0; i < brProjs.size(); i++) {
    brProjs.get(i).update();
    brProjs.get(i).draw();
    
    if (brProjs.get(i).x < 0 || brProjs.get(i).x > gSizeX || brProjs.get(i).y < 0 || brProjs.get(i).y > gSizeY) {
    brProjs.remove(i);
    i -= 1;
    continue;
    
    }
    
    int j = 0;
    boolean hit = false;
    while (AmericanPositions.size() > 0 && !hit && j < AmericanPositions.size()) {
    if (distSq(brProjs.get(i).x - AmericanPositions.get(j).x, brProjs.get(i).y - AmericanPositions.get(j).y) < 100) {
    AmericanPositions.get(j).x += cos(brProjs.get(i).angle) * 10;
    AmericanPositions.get(j).y += sin(brProjs.get(i).angle) * 10;
    AmericanPositions.get(j).health -= 20;
    hit = true;
    
    
    }
    j++;
    }
    
    if (hit) {
    brProjs.remove(i);
    i -= 1;
    }
    }
    
    
    for (int i = 0; i < AmericanBase.size(); i++) {
    AmericanBase.get(i).baseIndex = i;
    AmericanBase.get(i).update();
    AmericanBase.get(i).interact();

    AmericanBase.get(i).onBase();

    if (AmericanBase.get(i).place.equals("battle")) {
    AmericanPositions.add(AmericanBase.get(i));
    AmericanBase.remove(i);
    i -= 1;
    }
    }
    
    for (int i = 0; i < BritishBase.size(); i++) {
    BritishBase.get(i).baseIndex = i;
    BritishBase.get(i).update();
    BritishBase.get(i).interact();
    
    BritishBase.get(i).onBase();
    
    if (BritishBase.get(i).place.equals("battle")) {
    BritishPositions.add(BritishBase.get(i));
    BritishBase.remove(i);
    i -= 1;
    }
    }
    
    
    for (int i = 0; i < woundedAmericans.size(); i++) {
    woundedAmericans.get(i).update();
    woundedAmericans.get(i).wounded();
    
    if (woundedAmericans.get(i).health <= -200) {
    woundedAmericans.remove(i);
    i -= 1;
    }
    }
    
    for (int i = 0; i < woundedBritish.size(); i++) {
    woundedBritish.get(i).update();
    woundedBritish.get(i).wounded();
    
    if (woundedBritish.get(i).health <= -200) {
    woundedBritish.remove(i);
    i -= 1;
    }
    }
    
    
    
    for (int i = 0; i < AmericanPositions.size(); i++) {
    AmericanPositions.get(i).index = i;
    
    AmericanPositions.get(i).update();
    AmericanPositions.get(i).interact();
    AmericanPositions.get(i).draw();
    
    AmericanPositions.get(i).inBattle();
    
    if (AmericanPositions.get(i).place.equals("base")) {
    AmericanBase.add(AmericanPositions.get(i));
    AmericanPositions.remove(i);
    i -= 1;
    continue;
    }
    
    if (AmericanPositions.get(i).health <= 0) {
    woundedAmericans.add(AmericanPositions.get(i));
    AmericanPositions.remove(i);
    i -= 1;
    continue;
    }
    }
    
    for (int i = 0; i < BritishPositions.size(); i++) {
    BritishPositions.get(i).index = i;
    
    BritishPositions.get(i).update();
    BritishPositions.get(i).interact();
    BritishPositions.get(i).draw();
    
    BritishPositions.get(i).inBattle();
    
    if (BritishPositions.get(i).place.equals("base")) {
    BritishBase.add(BritishPositions.get(i));
    BritishPositions.remove(i);
    i -= 1;
    continue;
    }
    
    if (BritishPositions.get(i).health <= 0) {
    woundedBritish.add(BritishPositions.get(i));
    BritishPositions.remove(i);
    i -= 1;
    continue;
    }
    }
    
    popMatrix();
}

int time = 0;

void draw() {
    time += 1;
    
    background(255, 255, 255);
    noStroke();
    
    
    textFont(createFont("monaco", 10));
    
    updateKeys();
    
    mouse.check();
    
    loadingSoldiers();
    
    gameScreen();
    
    debugScreen();
    
    //ellipse(mouseX, mouseY, 25, 25);
    mouse.draw();
}