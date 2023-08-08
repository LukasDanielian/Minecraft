class Chunk
{
  int x, z;
  float noiseX, noiseZ;
  int[] DEPTH_DISP = {0, -1, 0, 1};
  int[] HORIZ_DISP = {-1, 0, 1, 0};
  Block[][][] blocks;
  //y x z
  float r,g,b;

  Chunk(int x, int z)
  {
    noiseX = x * (noiseScl * numBlocks);
    this.x = x * chunkSize;
    this.z = z * chunkSize;
    blocks = new Block[256][numBlocks][numBlocks];
    generateChunk();
    r = random(0,256);
    g = random(0,256);
    b = random(0,256);
  }

  void generateChunk()
  {
    int blockX = x + (-blockSize * numBlocks/2) + blockSize/2;
    int blockZ = 0;

    for (int x = 0; x < numBlocks; x++)
    {
      blockZ = z + (-blockSize * numBlocks/2) + blockSize/2;
      noiseZ = (z/chunkSize) * (noiseScl * numBlocks);

      for (int z = 0; z < numBlocks; z++)
      {
        int y = (int)map(noise(noiseX, noiseZ), 0, 1, 50, 200);
        int blockY = y * blockSize;

        blocks[y][x][z] = new Block(blockX, blockY, blockZ);
        blockZ += blockSize;
        noiseZ += noiseScl;
      }

      blockX += blockSize;
      noiseX += noiseScl;
    }

    for (int x = 0; x < numBlocks; x++)
    {
      for (int z = 0; z < numBlocks; z++)
      {
        Block block = getTopBlock(x, z);
        int y = block.y;
        int largestGap = 1;

        //border between chunks 
        if (x == 0 || x == numBlocks-1 || z == 0 || z == numBlocks-1)
        {
          for (int i = 1; i < 3; i++)
          {
            blocks[(y/blockSize) + i][x][z] = new Block(block.x, block.y + (i*blockSize), block.z);
          }
        } 
        
        //Calculate for efficiency
        else
        {

          for (int i = 0; i < DEPTH_DISP.length; i++)
          {
            if (inBounds(x + HORIZ_DISP[i], z + DEPTH_DISP[i]))
            {
              Block adjecent = getTopBlock(x + HORIZ_DISP[i], z + DEPTH_DISP[i]);
              int gap = (adjecent.y/blockSize) - (block.y/blockSize);

              if (gap > largestGap)
                largestGap = gap;
            }
          }

          if (largestGap > 1)
          {
            for (int i = 1; i < largestGap; i++)
            {
              blocks[(y/blockSize) + i][x][z] = new Block(block.x, block.y + (i*blockSize), block.z);
            }
          }
        }
      }
    }
  }

  void render()
  {
    for (int y = 0; y < blocks.length; y++)
    {
      for (int x = 0; x < blocks[y].length; x++)
      {
        for (int z = 0; z < blocks[y][x].length; z++)
        {
          Block block = blocks[y][x][z];

          if (block != null)
            block.render();
        }
      }
    }
  }

  //Chekcs if spot in chunk
  boolean inBounds(int x, int z)
  {
    return x >= 0 && x <= numBlocks-1 && z >= 0 && z <= numBlocks-1;
  }

  //Returns floor block at x and z pos
  Block getTopBlock(int x, int z)
  {
    for (int y = 0; y < 256; y++)
    {
      if (blocks[y][x][z] != null)
        return blocks[y][x][z];
    }

    return null;
  }

  //Returns block that player is standing on
  Block getCurrentBlock()
  {
    int x = (int)map(player.pos.x, this.x - chunkSize/2, this.x + chunkSize/2, 0, 16);
    int z = (int)map(player.pos.z, this.z - chunkSize/2, this.z + chunkSize/2, 0, 16);
    return getTopBlock(x, z);
  }
}
