class Block implements Comparable<Block>
{
  PVector pos;
  int x, y, z;
  PShape cube;

  Block(PVector pos, int x, int y, int z)
  {
    this.pos = pos;
    this.x = x;
    this.y = y;
    this.z = z;
    
    if(y > 150)
      cube = dirt;
    else
      cube = stone;
  }

  void render()
  {
    push();
    translate(pos.x, pos.y, pos.z);
    shape(cube);
    pop();
  }

  int compareTo(Block block)
  {
    return block.y - y;
  }
}
