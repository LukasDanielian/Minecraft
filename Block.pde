class Block implements Comparable<Block>
{
  PVector pos;
  int x, y, z;
  Chunk chunk;
  PImage texture;

  Block(PVector pos, int x, int y, int z, Chunk chunk)
  {
    this.pos = pos;
    this.x = x;
    this.y = y;
    this.z = z;
    this.chunk = chunk;

    float noise  = noise(pos.x/10000, pos.z/10000);

    if (y > 250)
      texture = bedrock;

    else if (y > chunk.floorLevel[x][z] + 5)
    {
      texture = stone;

      if (noise < .05)
        texture = diamond;
    } 
    
    else
    {
      if (noise > .5)
        texture = sand;
      else
        texture = dirt;
    }
  }
  
  void render()
  {
    noFill();
    stroke(0);
    strokeWeight(2);
    push();
    translate(pos.x,pos.y,pos.z);
    box(blockSize);
    pop();
    noStroke();
  }

  int compareTo(Block block)
  {
    return block.y - y;
  }

  //little help from chatGPT
  boolean hitScan(PVector rayOrigin, PVector rayDirection)
  {
    PVector minBounds = new PVector(pos.x - halfBlock, pos.y - halfBlock, pos.z - halfBlock);
    PVector maxBounds = new PVector(pos.x + halfBlock, pos.y + halfBlock, pos.z + halfBlock);
    PVector invRayDirection = new PVector(1.0 / rayDirection.x, 1.0 / rayDirection.y, 1.0 / rayDirection.z);
    float tmin, tmax, tymin, tymax, tzmin, tzmax;

    if (PVector.dot(rayDirection, PVector.sub(pos, rayOrigin)) < 0)
      return false;

    if (invRayDirection.x >= 0)
    {
      tmin = (minBounds.x - rayOrigin.x) * invRayDirection.x;
      tmax = (maxBounds.x - rayOrigin.x) * invRayDirection.x;
    } else
    {
      tmin = (maxBounds.x - rayOrigin.x) * invRayDirection.x;
      tmax = (minBounds.x - rayOrigin.x) * invRayDirection.x;
    }

    if (invRayDirection.y >= 0) {
      tymin = (minBounds.y - rayOrigin.y) * invRayDirection.y;
      tymax = (maxBounds.y - rayOrigin.y) * invRayDirection.y;
    } else {
      tymin = (maxBounds.y - rayOrigin.y) * invRayDirection.y;
      tymax = (minBounds.y - rayOrigin.y) * invRayDirection.y;
    }

    if ((tmin > tymax) || (tymin > tmax))
      return false;

    if (tymin > tmin)
      tmin = tymin;

    if (tymax < tmax)
      tmax = tymax;

    if (invRayDirection.z >= 0) {
      tzmin = (minBounds.z - rayOrigin.z) * invRayDirection.z;
      tzmax = (maxBounds.z - rayOrigin.z) * invRayDirection.z;
    } else {
      tzmin = (maxBounds.z - rayOrigin.z) * invRayDirection.z;
      tzmax = (minBounds.z - rayOrigin.z) * invRayDirection.z;
    }

    if ((tmin > tzmax) || (tzmin > tmax))
      return false;

    return true;
  }
}
