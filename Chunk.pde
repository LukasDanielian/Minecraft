class Chunk
{
  int x, z;
  Block[][][] blocks;
  int[][] floorLevel;
  PShape mesh;
  boolean updated;

  Chunk(int x, int z)
  {
    this.x = x * chunkSize;
    this.z = z * chunkSize;
    blocks = new Block[256][numBlocks][numBlocks];
    floorLevel = new int[numBlocks][numBlocks];
    generateChunk();
  }

  //Builds single floor layer of blocks at every x and z pos for chunk
  void generateChunk()
  {
    int bx = this.x + (-blockSize * numBlocks/2) + halfBlock;
    int bz = 0;
    float nx = x/chunkSize * (noiseScl * numBlocks);
    float nz = 0;

    for (int x = 0; x < numBlocks; x++)
    {
      bz = z + (-blockSize * numBlocks/2) + halfBlock;
      nz = (z/chunkSize) * (noiseScl * numBlocks);

      for (int z = 0; z < numBlocks; z++)
      {
        int y = (int)map(noise(nx + 500, nz + 500), 0, 1, 100, 125);
        int by = y * blockSize;
        floorLevel[x][z] = y;
        blocks[y][x][z] = new Block(new PVector(bx, by, bz), x, y, z, this);

        //Spawn tree
        if (blocks[y][x][z].texture.equals(dirt) && x > 2 && x < numBlocks-2 && z > 2 && z < numBlocks-2 && noise(x + this.x, z + this.z) > .82)
        {
          int treeTop = (int)random(5, 7);
          for (int i = 1; i < treeTop; i++)
          {
            blocks[y-i][x][z] = new Block(new PVector(bx, by - (i * blockSize), bz), x, y-i, z, this);
            blocks[y-i][x][z].texture = wood;

            if (i > 2)
            {
              for (int tx = -1; tx <= 1; tx++)
              {
                for (int tz = -1; tz <= 1; tz++)
                {
                  if (blocks[y-i][x+tx][z+tz] == null)
                  {
                    blocks[y-i][x+tx][z+tz] = new Block(new PVector(bx + (tx * blockSize), by - (i * blockSize), bz + (tz * blockSize)), x+tx, y-i, z+tz, this);
                    blocks[y-i][x+tx][z+tz].texture = leave;
                  }
                }
              }
            }
          }

          blocks[y-treeTop][x][z] = new Block(new PVector(bx, by - (treeTop * blockSize), bz), x, y-treeTop, z, this);
          blocks[y-treeTop][x][z].texture = leave;
        } else if (blocks[y][x][z].texture.equals(sand) && noise(x + this.x, z + this.z) > .85)
        {
          int cactusTop = (int)random(4, 6);
          for (int i = 1; i < cactusTop; i++)
          {
            blocks[y-i][x][z] = new Block(new PVector(bx, by - (i * blockSize), bz), x, y-i, z, this);
            blocks[y-i][x][z].texture = cactus;
          }
        }

        bz += blockSize;
        nz += noiseScl;
      }

      bx += blockSize;
      nx += noiseScl;
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
            blocks[block.y+i][x][z] = new Block(new PVector(block.pos.x, block.pos.y + (i * blockSize), block.pos.z), x, block.y + i, z, this);
        }
      }
    }
  }

  void buildMesh()
  {
    ArrayList<Thread> threads = new ArrayList<Thread>();
    mesh = createShape(GROUP);

    for (int i = 0; i < textures.size(); i++)
    {
      Thread thread = new Thread(new MeshBuilder(textures.get(i)));
      thread.start();
      threads.add(thread);
    }

    for (Thread thread : threads)
    {
      try {
        thread.join();
      }
      catch(InterruptedException e) {
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

      if (chunk != null)
      {
        if (chunk.blocks[by][bx][bz] == null && by > chunk.getTopBlock(bx, bz).y)
          neighbors[i] = new Block(new PVector(block.pos.x + xDisp[i] * blockSize, block.pos.y + yDisp[i] * blockSize, block.pos.z + zDisp[i] * blockSize), bx, by, bz, chunk);
      }
    }

    return neighbors;
  }

  //renders mesh
  void render()
  {
    shape(mesh);
  }

  Block checkHitScan(PVector center, PVector looking)
  {
    ArrayList<Block> blocksHit = new ArrayList<Block>();

    for (int x = 0; x < blocks[0].length; x++)
    {
      for (int z = 0; z < blocks[0][0].length; z++)
      {
        for (int y = floorLevel[x][z] - 15; y < blocks.length; y++)
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

  class MeshBuilder implements Runnable
  {
    PImage texture;
    PShape child;

    MeshBuilder(PImage texture)
    {
      this.texture = texture;
      child = createShape();
    }

    void run()
    {
      child.beginShape(TRIANGLES);
      child.texture(texture);

      for (int x = 0; x < blocks[0].length; x++)
      {
        for (int z = 0; z < blocks[0][0].length; z++)
        {
          for (int y = floorLevel[x][z] - 15; y < blocks.length; y++)
          {
            Block block = blocks[y][x][z];

            if (block != null)
            {
              float bx = block.pos.x;
              float by = block.pos.y;
              float bz = block.pos.z;

              //Dirt textures
              if (block.texture.equals(dirt) && block.y == floorLevel[block.x][block.z])
              {
                if (texture.equals(grassSide))
                {
                  addFront(bx, by, bz);
                  addBack(bx, by, bz);
                  addLeft(bx, by, bz);
                  addRight(bx, by, bz);
                } else if (texture.equals(grassTop))
                  addTop(bx, by, bz);
                else if (texture.equals(dirt))
                  addBottom(bx, by, bz);
              } 
              
              else if (block.texture.equals(cactus))
              {
                if (texture.equals(cactusTop))
                {
                  addTop(bx, by, bz);
                  addBottom(bx, by, bz);
                } 
                
                else if (texture.equals(cactus))
                {
                  addFront(bx, by, bz);
                  addBack(bx, by, bz);
                  addLeft(bx, by, bz);
                  addRight(bx, by, bz);
                }
              }
              
              else if (block.texture.equals(wood))
              {
                if (texture.equals(woodTop))
                {
                  addTop(bx, by, bz);
                  addBottom(bx, by, bz);
                } else if (texture.equals(wood))
                {
                  addFront(bx, by, bz);
                  addBack(bx, by, bz);
                  addLeft(bx, by, bz);
                  addRight(bx, by, bz);
                }
              }

              //Normal textures
              else if (texture.equals(block.texture))
              {
                addFront(bx, by, bz);
                addBack(bx, by, bz);
                addTop(bx, by, bz);
                addBottom(bx, by, bz);
                addLeft(bx, by, bz);
                addRight(bx, by, bz);
              }
            }
          }
        }
      }

      child.endShape();
      synchronized(textures)
      {
        mesh.addChild(child);
      }
    }

    void addFront(float bx, float by, float bz)
    {
      child.vertex(bx + -halfBlock, by + -halfBlock, bz + halfBlock, 0, 0);
      child.vertex(bx + halfBlock, by + -halfBlock, bz + halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by + halfBlock, bz + halfBlock, 0, 1);

      child.vertex(bx + halfBlock, by + -halfBlock, bz + halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by +halfBlock, bz + halfBlock, 1, 1);
      child.vertex(bx + -halfBlock, by + halfBlock, bz + halfBlock, 0, 1);
    }

    void addBack(float bx, float by, float bz)
    {
      child.vertex(bx + halfBlock, by + -halfBlock, bz + -halfBlock, 0, 0);
      child.vertex(bx + -halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by + halfBlock, bz + -halfBlock, 0, 1);

      child.vertex(bx + -halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by +halfBlock, bz + -halfBlock, 1, 1);
      child.vertex(bx + halfBlock, by + halfBlock, bz + -halfBlock, 0, 1);
    }

    void addTop(float bx, float by, float bz)
    {
      child.vertex(bx + -halfBlock, by + -halfBlock, bz + -halfBlock, 0, 0);
      child.vertex(bx + halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by +-halfBlock, bz + halfBlock, 0, 1);

      child.vertex(bx + halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by + -halfBlock, bz + halfBlock, 1, 1);
      child.vertex(bx + -halfBlock, by + -halfBlock, bz + halfBlock, 0, 1);
    }

    void addBottom(float bx, float by, float bz)
    {
      child.vertex(bx + -halfBlock, by + halfBlock, bz +halfBlock, 0, 0);
      child.vertex(bx + halfBlock, by + halfBlock, bz + halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by + halfBlock, bz +-halfBlock, 0, 1);

      child.vertex(bx + halfBlock, by + halfBlock, bz +halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by + halfBlock, bz + -halfBlock, 1, 1);
      child.vertex(bx + -halfBlock, by + halfBlock, bz +-halfBlock, 0, 1);
    }

    void addLeft(float bx, float by, float bz)
    {
      child.vertex(bx + -halfBlock, by + -halfBlock, bz +-halfBlock, 0, 0);
      child.vertex(bx + -halfBlock, by + -halfBlock, bz +halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by + halfBlock, bz + -halfBlock, 0, 1);

      child.vertex(bx + -halfBlock, by + -halfBlock, bz +halfBlock, 1, 0);
      child.vertex(bx + -halfBlock, by + halfBlock, bz +halfBlock, 1, 1);
      child.vertex(bx + -halfBlock, by + halfBlock, bz + -halfBlock, 0, 1);
    }

    void addRight(float bx, float by, float bz)
    {
      child.vertex(bx + halfBlock, by + -halfBlock, bz + halfBlock, 0, 0);
      child.vertex(bx + halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by + halfBlock, bz + halfBlock, 0, 1);

      child.vertex(bx + halfBlock, by + -halfBlock, bz + -halfBlock, 1, 0);
      child.vertex(bx + halfBlock, by + halfBlock, bz +-halfBlock, 1, 1);
      child.vertex(bx + halfBlock, by + halfBlock, bz + halfBlock, 0, 1);
    }
  }
}
