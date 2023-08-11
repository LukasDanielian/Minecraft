import com.jogamp.newt.opengl.GLWindow;
import java.util.*;

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
PImage stone, dirt, sand, grassTop, grassSide, diamond, bedrock;
int[] xDisp = {-1, 1, 0, 0, 0, 0};
int[] yDisp = {0, 0, 0, 0, -1, 1};
int[] zDisp = {0, 0, -1, 1, 0, 0};
HashSet<String> minedBlocks = new HashSet<String>();

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

  stone = loadImage("stone.jpg");
  stone.resize(blockSize, 0);
  dirt = loadImage("dirt.jpg");
  dirt.resize(blockSize, 0);
  sand = loadImage("sand.jpg");
  sand.resize(blockSize, 0);
  grassTop = loadImage("grassTop.jpg");
  grassTop.resize(blockSize, 0);
  grassSide = loadImage("grassSide.jpg");
  grassSide.resize(blockSize, 0);
  diamond = loadImage("diamond.jpg");
  diamond.resize(blockSize, 0);
  bedrock = loadImage("bedrock.jpg");;
  bedrock.resize(blockSize,0);



  window = (GLWindow)surface.getNative();
  keys = new boolean[256];
  oldMouse = new PVector(mouseX, mouseY);
  lockMouse();
  player = new Player();
  world = new World();
  world.updateChunks();
  world.updateMesh();
  player.setCurrentBlock();
}

void draw()
{
  background(#16819D);
  lights();
  directionalLight(200, 200, 200, .75, 1, .75);

  player.render();
  world.render();
  player.renderHUD();
}
