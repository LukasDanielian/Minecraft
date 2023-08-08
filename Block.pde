class Block
{
  int x, y, z;

  Block(int x, int y, int z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  void render()
  {
    fill(#103110);
    stroke(0);
    strokeWeight(1);
    push();
    translate(x, y, z);
    box(blockSize);
    pop();
  }
}
