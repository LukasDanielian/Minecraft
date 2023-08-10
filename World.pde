class World
{
  HashMap<String, Chunk> chunks;
  //int[] DEPTH_DISP = {-1, -1, -1, 0, 0, 0, 1, 1, 1,0,-1,-2,-2,-2,-2,-2,-1,0,1,2,2,2,2,2,1};
  //int[] HORIZ_DISP = {-1, 0, 1, -1, 0, 1, -1, 0, 1,-2,-2,-2,-1,0,1,2,2,2,2,2,1,0,-1,-2,-2};
  int[] DEPTH_DISP = {-1, -1, -1, 0, 0, 0, 1, 1, 1};
  int[] HORIZ_DISP = {-1, 0, 1, -1, 0, 1, -1, 0, 1};

  public World()
  {
    chunks = new HashMap<String, Chunk>();
  }

  //renders 9 chunks including current and all adjecent chunks
  void render()
  {
    ArrayList<Block> blocks = new ArrayList<Block>();
    
    for (int i = 0; i < DEPTH_DISP.length; i++)
    {
      Chunk chunk = chunks.get(cordString(player.chunkX + HORIZ_DISP[i], player.chunkZ + DEPTH_DISP[i]));
      chunk.render();
      
      Block block = chunk.checkHitScan();
      if (block != null)
        blocks.add(block);
    }

    float lowestDist = Float.POSITIVE_INFINITY;
    int num = -1;

    for (int i = 0; i < blocks.size(); i++)
    {
      Block block = blocks.get(i);

      float dist = dist(player.pos.x, player.pos.y, player.pos.z, block.pos.x, block.pos.y, block.pos.z);

      if (dist < lowestDist)
      {
        num = i;
        lowestDist = dist;
      }
    }

    if (num != -1)
    {
      Block block = blocks.get(num);
      block.lookingAt = true;
      player.lookingAt = block;
    } else
    {
      player.lookingAt = null;
    }
  }

  //resets center chunk and adds new chunks if needed
  void updateChunks()
  {
    for (int i = 0; i < DEPTH_DISP.length; i++)
    {
      Chunk chunk = chunks.get(cordString(player.chunkX + HORIZ_DISP[i], player.chunkZ + DEPTH_DISP[i]));

      //brand new chunk
      if (chunk == null)
      {
        chunk = new Chunk(player.chunkX + HORIZ_DISP[i], player.chunkZ + DEPTH_DISP[i]);
        chunks.put(cordString(player.chunkX + HORIZ_DISP[i], player.chunkZ + DEPTH_DISP[i]), chunk);
      }
    }
  }

  void updateBlocksUnder()
  {
    for (int i = 0; i < DEPTH_DISP.length; i++)
      chunks.get(cordString(player.chunkX + HORIZ_DISP[i], player.chunkZ + DEPTH_DISP[i])).updateBlocksUnder();
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
