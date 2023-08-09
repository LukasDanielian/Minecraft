class Chunk
{
  int x, z;
  float noiseX, noiseZ;
  Block[][][] blocks;
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
        int y = (int)map(noise(noiseX, noiseZ), 0, 1, 50, 200);
        int blockY = y * blockSize;

        blocks[y][x][z] = new Block(new PVector(blockX, blockY, blockZ), x, y, z);
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
          blocks[block.y+i][x][z] = new Block(new PVector(block.pos.x, block.pos.y + (i * blockSize), block.pos.z), x, block.y + i, z);
      }
    }
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

    if (x > 15)
      x = 15;
    if (z > 15)
      z = 15;

    return getTopBlock(x, z);
  }
}
