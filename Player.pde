class Player
{
  float yaw, pitch, speed;
  int chunkX, chunkZ;
  PVector pos, lastPos, view, vel;
  boolean jumping, climbing;
  Chunk currChunk;
  Block currBlock, lookingAt;

  public Player()
  {
    pos = new PVector(0, 0, 0);
    vel = new PVector(0, 0, 0);
    speed = 10;
    yaw = HALF_PI;
  }

  //Moves players position and view
  void render()
  {
    mouseUpdate();
    buttons();
    checkBounds();
    applyPhysics();
    updateCamera();
  }

  void setCurrentBlock()
  {
    currChunk = world.getCurrentChunk();
    currBlock = currChunk.getCurrentBlock();
  }

  //updates player view
  void updateCamera()
  {
    view = new PVector(cos(yaw) * cos(pitch), -sin(pitch), sin(yaw) * cos(pitch)).mult(-1);
    perspective(PI/2.5, float(width)/height, .01, width * width);
    camera(pos.x, pos.y, pos.z, pos.x + view.x, pos.y + view.y, pos.z + view.z, 0, 1, 0);
  }

  //On screen info
  void renderHUD()
  {
    push();
    camera();
    ortho();
    noLights();
    hint(DISABLE_DEPTH_TEST);
    //FPS
    fill(255);
    textSize(15);
    text("Frame Rate: " + (int)frameRate, width/2, height * .05);
    textAlign(CENTER);

    //Cross hair
    noStroke();
    fill(0);
    rect(width/2, height/2, 25, 2);
    rect(width/2, height/2, 2, 25);

    hint(ENABLE_DEPTH_TEST);
    pop();
  }

  //updates cursor info and loc
  void mouseUpdate()
  {
    if (!focused && mouseLock)
      unlockMouse();

    //Bound
    if (mouseLock)
    {
      yaw += (mouseX-offsetX-width/2.0)*.001;
      pitch += (mouseY-offsetY-height/2.0)*.001;
      window.setPointerVisible(false);
      window.warpPointer(width/2, height/2);
      window.confinePointer(true);
    }

    //Not bound
    else
    {
      window.confinePointer(false);
      window.setPointerVisible(true);
    }

    offsetX=offsetY=0;
    pitch = constrain(pitch, -HALF_PI + 0.0001, HALF_PI- .0001);
    lastPos = pos.copy();
  }

  //Checks if bottons were clicked
  void buttons()
  {
    if (keyPressed)
    {
      //Classic movement
      if (keyDown('W'))
      {
        pos.x += view.x * speed;
        pos.z += view.z * speed;
      }
      if (keyDown('S'))
      {
        pos.x += -view.x * speed;
        pos.z += -view.z * speed;
      }
      if (keyDown('A'))
      {
        pos.x += -cos(yaw - PI/2) * cos(pitch) * 10;
        pos.z += -sin(yaw - PI/2) * cos(pitch) * 10;
      }
      if (keyDown('D'))
      {
        pos.x += cos(yaw - PI/2) * cos(pitch) * 10;
        pos.z += sin(yaw - PI/2) * cos(pitch) * 10;
      }

      //Jump
      if (keyDown(' '))
      {
        if (!jumping)
        {
          jumping = true;
          vel.y = -10;
        }
      }
    }
  }

  //Keeps player in map
  void checkBounds()
  {
    Block[] neighbors = currChunk.getNeighbors(currBlock);
    
    if (currBlock != null)
    {
      if (pos.x < currBlock.pos.x - blockSize/2 + 5 && currBlock.compareTo(neighbors[0]) < 0 && pos.y + 100 > neighbors[0].pos.y)
      {
        if (!jumping)
        {
          jumping = true;
          vel.y = -10;
        }
        pos.x = currBlock.pos.x - blockSize/2 + 5;
      }
      if (pos.x > currBlock.pos.x + blockSize/2 - 5 && currBlock.compareTo(neighbors[1]) < 0 && pos.y + 100 > neighbors[1].pos.y)
      {
        if (!jumping)
        {
          jumping = true;
          vel.y = -10;
        }
        pos.x = currBlock.pos.x + blockSize/2 - 5;
      }
      if (pos.z < currBlock.pos.z - blockSize/2 + 5 && currBlock.compareTo(neighbors[2]) < 0 && pos.y + 100 > neighbors[2].pos.y)
      {
        if (!jumping)
        {
          jumping = true;
          vel.y = -10;
        }
        pos.z = currBlock.pos.z - blockSize/2 + 5;
      }
      if (pos.z > currBlock.pos.z + blockSize/2 - 5 && currBlock.compareTo(neighbors[3]) < 0 && pos.y + 100 > neighbors[3].pos.y)
      {
        if (!jumping)
        {
          jumping = true;
          vel.y = -10;
        }
        pos.z = currBlock.pos.z + blockSize/2 - 5;
      }
      
      currBlock = currChunk.getCurrentBlock();
    }

    if (currChunk != null)
    {
      if (pos.x < currChunk.x - chunkSize/2)
        chunkX--;
      else if (pos.x > currChunk.x + chunkSize/2)
        chunkX++;
      else if (pos.z < currChunk.z - chunkSize/2)
        chunkZ--;
      else if (pos.z > currChunk.z + chunkSize/2)
        chunkZ++;
      else
        return;

      world.updateChunks();
      world.updateBlocksUnder();
      currChunk = world.getCurrentChunk();
    }
  }

  //Checks all movement conditions
  void applyPhysics()
  {
    pos.add(vel);

    //Jumping animation
    if (jumping || pos.y < currBlock.pos.y - 100)
    {
      vel.y++;
      setCurrentBlock();
    }

    if (pos.y > currBlock.pos.y - 100)
    {
      pos.y = currBlock.pos.y - 100;
      vel.y = 0;
      jumping = false;
    }
  }
}
