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
float noiseScl = .01;
PShape stone, dirt, sand;

void setup()
{
  fullScreen(P3D);
  shapeMode(CENTER);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  frameRate(60);
  textSize(128);
  noStroke();

  stone = createShape(BOX, blockSize);
  stone.translate(blockSize/2, blockSize/2, 0);
  stone.setTexture(loadImage("stone.jpg"));


  dirt = createShape(BOX, blockSize);
  dirt.translate(blockSize/2, blockSize/2, 0);
  dirt.setTexture(loadImage("dirt.jpg"));
  
  sand = createShape(BOX, blockSize);
  sand.translate(blockSize/2, blockSize/2, 0);
  sand.setTexture(loadImage("sand.jpg"));


  window = (GLWindow)surface.getNative();
  keys = new boolean[256];
  oldMouse = new PVector(mouseX, mouseY);
  lockMouse();
  player = new Player();
  world = new World();
  world.updateChunks();
  world.updateBlocksUnder();
  player.setCurrentBlock();
}

void draw()
{
  background(#16819D);
  lights();
  directionalLight(200, 200, 190, .75, -1, .75);

  player.render();
  world.render();
  player.renderHUD();
}
