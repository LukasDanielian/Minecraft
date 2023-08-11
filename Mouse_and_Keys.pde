//Locks mouse into place
void lockMouse()
{
  if (!mouseLock)
  {
    oldMouse = new PVector(mouseX, mouseY);
    offsetX = mouseX - width/2;
    offsetY = mouseY - height/2;
  }

  mouseLock = true;
}

//unlocks mouse
void unlockMouse()
{
  if (mouseLock)
    window.warpPointer((int) oldMouse.x, (int) oldMouse.y);

  mouseLock = false;
}

//Key down
void keyPressed()
{
  if (keyCode >= 0 && keyCode < 256)
    keys[keyCode] = true;

  if (key == 'p')
  {
    if (mouseLock)
      unlockMouse();

    else
      lockMouse();
  }
}

//Key up
void keyReleased()
{
  if (keyCode >= 0 && keyCode < 256)
    keys[keyCode] = false;
}

//Grabs key
boolean keyDown(int key)
{
  return keys[key];
}

void mousePressed()
{
  Block block = player.lookingAt;

  if (block != null && !block.texture.equals(bedrock))
  {
    minedBlocks.add(block.chunk.x/chunkSize + "x" + block.chunk.z/chunkSize + "x" + block.x + "x" + block.y + "x" + block.z);
    Block[] neighbors = block.chunk.getAllNeighbors(block);
    
    for(int i = 0; i < neighbors.length; i++)
    {
      Block nBlock = neighbors[i];
      
      if(nBlock != null && !minedBlocks.contains(nBlock.chunk.x/chunkSize + "x" + nBlock.chunk.z/chunkSize + "x" + nBlock.x + "x" + nBlock.y + "x" + nBlock.z))
        nBlock.chunk.blocks[nBlock.y][nBlock.x][nBlock.z] = neighbors[i];
    }

    block.chunk.blocks[block.y][block.x][block.z] = null;
    world.updateMesh();
  }
}
