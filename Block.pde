class Block
{
  PVector pos;
  int x, y, z;

  Block(PVector pos, int x, int y, int z)
  {
    this.pos = pos;
    this.x = x;
    this.y = y;
    this.z = z;
  }

  void render()
  {
    push();
    translate(pos.x, pos.y, pos.z);
    box(blockSize);
    pop();
  }
}
