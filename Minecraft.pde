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
int halfBlock = blockSize/2;
int numBlocks = 16;
int chunkSize = numBlocks * blockSize;
float noiseScl = .02;
PImage stone, dirt, sand, grassTop, grassSide, diamond, bedrock, wood, woodTop, leave, cactus, cactusTop;
ArrayList<PImage> textures = new ArrayList<PImage>();
int[] xDisp = {-1, 1, 0, 0, 0, 0};
int[] yDisp = {0, 0, 0, 0, -1, 1};
int[] zDisp = {0, 0, -1, 1, 0, 0};
HashSet<String> minedBlocks = new HashSet<String>();
boolean doneLoading;

void setup()
{
  fullScreen(P3D);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  textureMode(NORMAL);
  hint(DISABLE_OPENGL_ERRORS);
  hint(ENABLE_DEPTH_SORT);
  frameRate(60);
  textSize(128);
  noStroke();
  
  thread("loadEverything");
}

void draw()
{
  background(#16819D);
  lights();
  directionalLight(200, 200, 200, .9, 1, .9);

  if(!doneLoading)
  {
    background(0);
    fill(#280F58);
    text("Danielian Softworks®", width/2, height * .15);
    push();
    translate(width/2,height * .6,-500);
    rotateX(frameCount * .01);
    rotateY(frameCount * .01);
    rotateZ(frameCount * .01);
    noFill();
    stroke(255);
    box(width/4);
    stroke(0);
    fill(#280F58);
    if(world != null)
      box(map(world.chunksFinished,0,(20+1+20) * (20+1+20),0,width/4));
    pop();
  }
  else
  {
    player.render();
    world.render();
    player.renderHUD();
  }
}

void loadEverything()
{
  stone = loadImage("stone.jpg");
  dirt = loadImage("dirt.jpg");
  sand = loadImage("sand.jpg");
  grassTop = loadImage("grassTop.jpg");
  grassSide = loadImage("grassSide.jpg");
  diamond = loadImage("diamond.jpg");
  bedrock = loadImage("bedrock.jpg");
  wood = loadImage("wood.jpg");
  woodTop = loadImage("woodTop.jpg");
  leave = loadImage("leave.png");
  cactus = loadImage("cactus.jpg");
  cactusTop = loadImage("cactusTop.jpg");
  textures.add(stone);
  textures.add(dirt);
  textures.add(grassTop);
  textures.add(grassSide);
  textures.add(sand);
  textures.add(diamond);
  textures.add(bedrock);
  textures.add(wood);
  textures.add(woodTop);
  textures.add(leave);
  textures.add(cactus);
  textures.add(cactusTop);

  window = (GLWindow)surface.getNative();
  oldMouse = new PVector(mouseX, mouseY);
  lockMouse();
  player = new Player();
  world = new World();
  world.update(20);
  player.setCurrentBlock();
  player.pos.y = player.currBlock.pos.y-100;
  doneLoading = true;
}
