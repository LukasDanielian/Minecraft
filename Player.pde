class Player
{
  float yaw, pitch, speed;
  int chunkX, chunkZ;
  PVector pos, lastPos, view, vel;
  boolean jumping;
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
    player.currBlock = world.checkHitScan(player.pos.copy(), new PVector(0, 1, 0), blockSize*256);
  }

  //updates player view
  void updateCamera()
  {
    view = new PVector(cos(yaw) * cos(pitch), -sin(pitch), sin(yaw) * cos(pitch)).mult(-1);
    perspective(PI/2.5, float(width)/height, .01, width * width);
    camera(pos.x, pos.y, pos.z, pos.x + view.x, pos.y + view.y, pos.z + view.z, 0, 1, 0);
    
    Block block = world.checkHitScan(player.pos.copy(), player.view.copy(), chunkSize);
    
    if(block != null)
    {
      lookingAt = block;
      lookingAt.render();
    }
    else
      lookingAt = null;
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
        jump();
    }
  }

  //Keeps player in map
  void checkBounds()
  {
    if (currBlock != null)
    {
      //left block
      if (pos.x < currBlock.pos.x - halfBlock + 5)
      {
        Block top = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y-15, currBlock.pos.z), new PVector(-1, 0, 0), blockSize + 15);
        Block bottom = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y+blockSize+5, currBlock.pos.z), new PVector(-1, 0, 0), blockSize + 15);

        if (bottom != null && top == null)
          jump();

        if (bottom != null || top != null)
          pos.x = currBlock.pos.x - halfBlock + 5;
      } 
      
      //right block
      if (pos.x > currBlock.pos.x + halfBlock - 5)
      {
        Block top = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y-15, currBlock.pos.z), new PVector(1, 0, 0), blockSize + 15);
        Block bottom = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y+blockSize+5, currBlock.pos.z), new PVector(1, 0, 0), blockSize + 15);

        if (bottom != null && top == null)
          jump();

        if (bottom != null || top != null)
          pos.x = currBlock.pos.x + halfBlock - 5;
      } 
      
      //front block
      if (pos.z < currBlock.pos.z - halfBlock + 5)
      {
        Block top = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y-15, currBlock.pos.z), new PVector(0, 0, -1), blockSize + 15);
        Block bottom = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y+blockSize+5, currBlock.pos.z), new PVector(0, 0, -1), blockSize + 15);

        if (bottom != null && top == null)
          jump();

        if (bottom != null || top != null)
          pos.z = currBlock.pos.z - halfBlock + 5;
      } 
      
      //back block
      if (pos.z > currBlock.pos.z + halfBlock - 5)
      {
        Block top = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y-15, currBlock.pos.z), new PVector(0, 0, 1), blockSize + 15);
        Block bottom = world.checkHitScan(new PVector(currBlock.pos.x, player.pos.y+blockSize+5, currBlock.pos.z), new PVector(0, 0, 1), blockSize + 15);

        if (bottom != null && top == null)
          jump();

        if (bottom != null || top != null)
          pos.z = currBlock.pos.z + halfBlock - 5;
      }
      
      currBlock = world.checkHitScan(new PVector(player.pos.x, player.pos.y, player.pos.z), new PVector(0, 1, 0), blockSize * 265);
    }

    if (currChunk != null)
    {
      if (pos.x < currChunk.x - chunkSize/2)
      {
        for(int z = -world.renderDistance; z <= world.renderDistance; z++)
          world.chunks.get(world.cordString(chunkX - world.renderDistance,chunkZ + z)).updated = false;
       
        chunkX--;
      }
      else if (pos.x > currChunk.x + chunkSize/2)
      {
        for(int z = -world.renderDistance; z <= world.renderDistance; z++)
          world.chunks.get(world.cordString(chunkX + world.renderDistance,chunkZ + z)).updated = false;
          
        chunkX++;
      }
      else if (pos.z < currChunk.z - chunkSize/2)
      {
        for(int x = -world.renderDistance; x <= world.renderDistance; x++)
          world.chunks.get(world.cordString(chunkX + x,chunkZ - world.renderDistance)).updated = false;
          
        chunkZ--;
      }
      else if (pos.z > currChunk.z + chunkSize/2)
      {
        for(int x = -world.renderDistance; x <= world.renderDistance; x++)
          world.chunks.get(world.cordString(chunkX + x,chunkZ + world.renderDistance)).updated = false;
          
        chunkZ++;
      }
      else
        return;

      world.update(world.renderDistance);
      setCurrentBlock();
    }
  }

  //Checks all movement conditions
  void applyPhysics()
  {
    pos.add(vel);

    //Jumping animation
    if (jumping || pos.y < currBlock.pos.y - 100)
      vel.y++;

    if (pos.y + 100 > currBlock.pos.y)
    {
      pos.y = currBlock.pos.y - 100;
      vel.y = 0;
      jumping = false;
    }
  }

  void jump()
  {
    if(!jumping && world.checkHitScan(new PVector(currBlock.pos.x,currBlock.pos.y-blockSize,currBlock.pos.z),new PVector(0,-1,0),(blockSize * 2) - 5) == null)
    {
      jumping = true;
      vel.y = -10;
    }
  }
}
