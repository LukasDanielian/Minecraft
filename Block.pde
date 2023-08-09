class Block implements Comparable<Block>
{
  PVector pos;
  int x, y, z;
  PShape cube;
  boolean lookingAt;

  Block(PVector pos, int x, int y, int z)
  {
    this.pos = pos;
    this.x = x;
    this.y = y;
    this.z = z;
    float noise = noise(pos.x/1000, pos.z/1000);

    if (noise > .66)
      cube = stone;
    else if (noise > .33)
      cube = dirt;
    else
      cube = sand;
  }

  void render()
  {
    push();
    translate(pos.x, pos.y, pos.z);
    if(lookingAt)
      box(blockSize);
    shape(cube);
    pop();
    
    lookingAt = false;
  }

  int compareTo(Block block)
  {
    return block.y - y;
  }




  boolean hitScan(PVector rayOrigin, PVector rayDirection) 
  {
    PVector minBounds = new PVector(pos.x - blockSize / 2, pos.y - blockSize / 2, pos.z - blockSize / 2);
    PVector maxBounds = new PVector(pos.x + blockSize / 2, pos.y + blockSize / 2, pos.z + blockSize / 2);
    float tmin = (minBounds.x - rayOrigin.x) / rayDirection.x;
    float tmax = (maxBounds.x - rayOrigin.x) / rayDirection.x;
    float tymin = (minBounds.y - rayOrigin.y) / rayDirection.y;
    float tymax = (maxBounds.y - rayOrigin.y) / rayDirection.y;

    if ((tmin > tymax) || (tymin > tmax))
      return false;

    if (tymin > tmin)
      tmin = tymin;

    if (tymax < tmax)
      tmax = tymax;

    float tzmin = (minBounds.z - rayOrigin.z) / rayDirection.z;
    float tzmax = (maxBounds.z - rayOrigin.z) / rayDirection.z;

    if ((tmin > tzmax) || (tzmin > tmax))
      return false;

    return true;
  }
}
