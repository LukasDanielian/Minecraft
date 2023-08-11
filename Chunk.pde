class Chunk
{
  int x, z;
  float noiseX, noiseZ;
  Block[][][] blocks;
  int[][] floorLevel = new int[16][16];
  //y x z

  Chunk(int x, int z)
  {
    noiseX = x * (noiseScl * numBlocks);
    this.x = x * chunkSize;
    this.z = z * chunkSize;
    blocks = new Block[256][numBlocks][numBlocks];
    generateChunk();
  }

  //Builds single floor layer of blocks at every x and z pos for chunk
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
        int y = (int)map(noise(noiseX, noiseZ) * noise(-noiseX, -noiseZ), 0, 1, 100, 200);
        int blockY = y * blockSize;
        floorLevel[x][z] = y;
        blocks[y][x][z] = new Block(new PVector(blockX, blockY, blockZ), x, y, z, this, false);
        blockZ += blockSize;
        noiseZ += noiseScl;
      }

      blockX += blockSize;
      noiseX += noiseScl;
    }
  }

  //Fills in open spots under blocks from large gaps between y values of blocks
  void updateBlocksUnder()
  {
    for (int x = 0; x < numBlocks; x++)
    {
      for (int z = 0; z < numBlocks; z++)
      {
        Block block = getTopBlock(x, z);
        int largestGap = 1;
        Block[] neighbors = getNeighbors(block);

        for (int i = 0; i < neighbors.length; i++)
        {
          if (neighbors[i] != null)
          {
            int gap = block.compareTo(neighbors[i]);

            if (gap > largestGap)
              largestGap = gap;
          }
        }

        for (int i = 1; i < largestGap; i++)
        {
          if (blocks[block.y+i][x][z] == null && !minedBlocks.contains(this.x/chunkSize + "x" + this.z/chunkSize + "x" + x + "x" + (block.y+i) + "x" + z))
            blocks[block.y+i][x][z] = new Block(new PVector(block.pos.x, block.pos.y + (i * blockSize), block.pos.z), x, block.y + i, z, this, true);
        }
      }
    }
  }

  void updateFaces()
  {
    for (int y = 0; y < blocks.length; y++)
    {
      for (int x = 0; x < blocks[y].length; x++)
      {
        for (int z = 0; z < blocks[y][x].length; z++)
        {
          Block block = blocks[y][x][z];

          if (block != null)
            getAllNeighbors(block);
        }
      }
    }
  }

  Block[] getAllNeighbors(Block block)
  {
    Block[] neighbors = new Block[6];

    for (int i = 0; i < xDisp.length; i++)
    {
      Chunk chunk = this;
      int bx = block.x + xDisp[i];
      int by = block.y + yDisp[i];
      int bz = block.z + zDisp[i];

      if (bx < 0)
      {
        chunk = world.chunks.get(world.cordString((x/chunkSize)-1, z/chunkSize));
        bx = 15;
      } else if (bx > 15)
      {
        chunk = world.chunks.get(world.cordString((x/chunkSize)+1, z/chunkSize));
        bx = 0;
      } else if (bz < 0)
      {
        chunk = world.chunks.get(world.cordString(x/chunkSize, (z/chunkSize) - 1));
        bz = 15;
      } else if (bz > 15)
      {
        chunk = world.chunks.get(world.cordString(x/chunkSize, (z/chunkSize) + 1));
        bz = 0;
      }

      if ((chunk != null && chunk.blocks[by][bx][bz] == null && by < chunk.getTopBlock(bx, bz).y) || (chunk != null && minedBlocks.contains(chunk.x/chunkSize + "x" + chunk.z/chunkSize + "x" + bx + "x" + by + "x" + bz)))
        block.renderSide[i] = true;
      if (chunk != null)
      {
        if (chunk.blocks[by][bx][bz] == null && by > chunk.getTopBlock(bx, bz).y)
          neighbors[i] = new Block(new PVector(block.pos.x + xDisp[i] * blockSize, block.pos.y + yDisp[i] * blockSize, block.pos.z + zDisp[i] * blockSize), bx, by, bz, chunk, true);
      }
    }

    return neighbors;
  }

  //renders every block in chunk
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

  Block checkHitScan(PVector center, PVector looking)
  {
    ArrayList<Block> blocksHit = new ArrayList<Block>();
    for (int y = 0; y < blocks.length; y++)
    {
      for (int x = 0; x < blocks[y].length; x++)
      {
        for (int z = 0; z < blocks[y][x].length; z++)
        {
          Block block = blocks[y][x][z];

          if (block != null && block.hitScan(center, looking))
            blocksHit.add(block);
        }
      }
    }

    float closest = Float.POSITIVE_INFINITY;
    int num = -1;

    for (int i = 0; i < blocksHit.size(); i++)
    {
      Block block = blocksHit.get(i);

      float dist = dist(player.pos.x, player.pos.y, player.pos.z, block.pos.x, block.pos.y, block.pos.z);

      if (dist < closest)
      {
        num = i;
        closest = dist;
      }
    }

    if (num != -1)
      return blocksHit.get(num);

    return null;
  }

  //returns 4 neighbors of given block: 0 = left, 1 = right, 2 = front, 3 = back
  Block[] getNeighbors(Block block)
  {
    Block[] neighbors = new Block[4];

    //Left block in diff chunk
    if (block.x - 1 < 0)
    {
      Chunk chunk = world.chunks.get(world.cordString(x/chunkSize - 1, z/chunkSize));

      if (chunk != null)
        neighbors[0] = chunk.getTopBlock(15, block.z);
    }

    //same chunk
    else
      neighbors[0] = getTopBlock(block.x-1, block.z);

    //Right block in diff chunk
    if (block.x + 1 > 15)
    {
      Chunk chunk = world.chunks.get(world.cordString(x/chunkSize + 1, z/chunkSize));

      if (chunk != null)
        neighbors[1] = chunk.getTopBlock(0, block.z);
    }

    //same chunk
    else
      neighbors[1] = getTopBlock(block.x+1, block.z);

    //front block in diff chunk
    if (block.z - 1 < 0)
    {
      Chunk chunk = world.chunks.get(world.cordString(x/chunkSize, z/chunkSize - 1));

      if (chunk != null)
        neighbors[2] = chunk.getTopBlock(block.x, 15);
    }

    //same chunk
    else
      neighbors[2] = getTopBlock(block.x, block.z-1);

    //back chunk in diff chunk
    if (block.z + 1 > 15)
    {
      Chunk chunk = world.chunks.get(world.cordString(x/chunkSize, z/chunkSize + 1));

      if (chunk != null)
        neighbors[3] = chunk.getTopBlock(block.x, 0);
    }

    //same chunk
    else
      neighbors[3] = getTopBlock(block.x, block.z+1);

    return neighbors;
  }

  //Returns floor block at x and z pos
  Block getTopBlock(int x, int z)
  {
    for (int y = floorLevel[x][z]; y < 256; y++)
    {
      if (blocks[y][x][z] != null)
        return blocks[y][x][z];
    }

    return null;
  }
}
