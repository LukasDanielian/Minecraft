import com.jogamp.newt.opengl.GLWindow;

GLWindow window;
boolean[] keys = new boolean[256];
boolean mouseLock;
PVector oldMouse;
int offsetX, offsetY;
Player player;
World world;
int blockSize = 50;
int numBlocks = 16;
int chunkSize = numBlocks * blockSize;
float noiseScl = .035;

void setup()
{
  fullScreen(P3D);
  shapeMode(CENTER);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  hint(ENABLE_STROKE_PERSPECTIVE);
  frameRate(60);
  textSize(128);

  window = (GLWindow)surface.getNative();
  keys = new boolean[256];
  oldMouse = new PVector(mouseX, mouseY);
  lockMouse();
  player = new Player();
  world = new World();
}

void draw()
{
  background(#16819D);
  
  player.render();
  world.render();
  player.renderHUD();
}
