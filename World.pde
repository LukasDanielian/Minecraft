class World
{
  HashMap<String, Chunk> chunks;
  int renderDistance = 10;
  PShape clouds;
  int chunksFinished;

  public World()
  {
    chunks = new HashMap<String, Chunk>();
    clouds = createShape(GROUP);

    for (int x = -renderDistance * chunkSize * 4; x <= renderDistance * chunkSize * 4; x += chunkSize/4)
    {
      for (int z = -renderDistance * chunkSize * 4; z <= renderDistance * chunkSize * 4; z += chunkSize/4)
      {
        if (noise((x/2500) + 100, (z/2500) + 100) > .6)
        {
          PShape box = createShape(BOX, chunkSize/4);
          box.setStroke(false);
          box.beginShape(BOX);
          box.translate(x, 0, z);
          box.fill(255);
          box.endShape();
          clouds.addChild(box);
        }
      }
    }
  }

  //renders chunks including current and all adjecent chunks
  void render()
  {
    for (int x = -renderDistance; x <= renderDistance; x++)
    {
      for (int z = -renderDistance; z <= renderDistance; z++)
        chunks.get(cordString(player.chunkX + x, player.chunkZ + z)).render();
    }

    noLights();
    push();
    translate(player.pos.x,player.pos.y - blockSize * 100,player.pos.z);
    shape(clouds);
    translate(chunkSize * 4,-width/2,chunkSize * 4);
    fill(#F7E323);
    box(chunkSize,1,chunkSize);
    pop();
  }

  void update(int dist)
  {
    updateChunks(dist);
    updateMesh(dist);
  }

  Block checkHitScan(PVector center, PVector looking, float range)
  {
    ArrayList<Block> blocks = new ArrayList<Block>();

    for (int x = -1; x <= 1; x++)
    {
      for (int z = -1; z <= 1; z++)
      {
        Chunk chunk = chunks.get(cordString(player.chunkX + x, player.chunkZ + z));
        Block block = chunk.checkHitScan(center, looking);

        if (block != null)
          blocks.add(block);
      }
    }

    float lowestDist = range;
    int num = -1;

    for (int i = 0; i < blocks.size(); i++)
    {
      Block block = blocks.get(i);

      float dist = dist(player.pos.x, player.pos.y, player.pos.z, block.pos.x, block.pos.y, block.pos.z);

      if (dist <= lowestDist)
      {
        num = i;
        lowestDist = dist;
      }
    }

    if (num != -1)
      return blocks.get(num);
    else
      return null;
  }

  //resets center chunk and adds new chunks if needed
  void updateChunks(int renderDistance)
  {
    for (int x = -renderDistance; x <= renderDistance; x++)
    {
      for (int z = -renderDistance; z <= renderDistance; z++)
      {
        Chunk chunk = chunks.get(cordString(player.chunkX + x, player.chunkZ + z));

        //brand new chunk
        if (chunk == null)
        {
          chunk = new Chunk(player.chunkX + x, player.chunkZ + z);
          chunks.put(cordString(player.chunkX + x, player.chunkZ + z), chunk);
        }
      }
    }
  }

  void updateMesh(int renderDistance)
  {
    for (int x = -renderDistance; x <= renderDistance; x++)
    {
      for (int z = -renderDistance; z <= renderDistance; z++)
      {
        Chunk chunk = chunks.get(cordString(player.chunkX + x, player.chunkZ + z));

        if (!chunk.updated || renderDistance == 1)
          chunk.updateBlocksUnder();
      }
    }

    for (int x = -renderDistance; x <= renderDistance; x++)
    {
      for (int z = -renderDistance; z <= renderDistance; z++)
      {
        Chunk chunk = chunks.get(cordString(player.chunkX + x, player.chunkZ + z));

        if (!chunk.updated || renderDistance == 1)
        {
          chunk.buildMesh();
          chunk.updated = true;
          chunksFinished++;
        }
      }
    }
  }

  //returns current chunk of player
  Chunk getCurrentChunk()
  {
    return chunks.get(cordString(player.chunkX, player.chunkZ));
  }

  //formats into string for hash map
  String cordString(int x, int z)
  {
    return x + "x" + z;
  }
}
