class Block implements Comparable<Block>
{
  PVector pos;
  int x, y, z;
  PImage texture;
  boolean lookingAt;
  Chunk chunk;
  boolean[] renderSide = new boolean[6];
  boolean underground;

  Block(PVector pos, int x, int y, int z, Chunk chunk, boolean underground)
  {
    this.pos = pos;
    this.x = x;
    this.y = y;
    this.z = z;
    this.chunk = chunk;
    this.underground = underground;
    float noise = noise(pos.x/2000, pos.z/2000);


    //underground
    if (y > chunk.floorLevel[x][z] + 5)
    {
      if (y > 256-3)
        texture = bedrock;

      else
      {
        texture = stone;

        if (noise > .5)
          texture = diamond;
      }
    }

    //above ground
    else
    {
      if (noise > .25)
        texture = dirt;
      else
        texture = sand;
    }
  }

  void render()
  {
    push();
    translate(pos.x, pos.y, pos.z);
    if (lookingAt)
    {
      noFill();
      stroke(0);
      strokeWeight(1);
      box(blockSize);
    }
    for (int i = 0; i < xDisp.length; i++)
    {
      if (renderSide[i])
      {
        push();
        translate(xDisp[i] * blockSize/2, yDisp[i] * blockSize/2, zDisp[i] * blockSize/2);
        if (xDisp[i] != 0)
          rotateY(HALF_PI);
        else if (yDisp[i] != 0)
          rotateX(HALF_PI);

        if (texture.equals(dirt) && !underground)
        {
          if (xDisp[i] != 0 || zDisp[i] != 0)
            image(grassSide, 0, 0);
          else if (yDisp[i] < 0)
            image(grassTop, 0, 0);
          else
            image(dirt, 0, 0);
        } else
          image(texture, 0, 0);
        pop();
      }
    }
    pop();

    lookingAt = false;
  }

  int compareTo(Block block)
  {
    return block.y - y;
  }

  //little help from chatGPT
  boolean hitScan(PVector rayOrigin, PVector rayDirection)
  {
    PVector minBounds = new PVector(pos.x - blockSize / 2, pos.y - blockSize / 2, pos.z - blockSize / 2);
    PVector maxBounds = new PVector(pos.x + blockSize / 2, pos.y + blockSize / 2, pos.z + blockSize / 2);
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
