//Locks mouse into place
void lockMouse() 
{
  if (!mouseLock) 
  {
    oldMouse = new PVector(mouseX, mouseY);
    offsetX = mouseX - width/2;
    offsetY = mouseY - height/2;
  }
  
  mouseLock = true;
}

//unlocks mouse
void unlockMouse() 
{
  if (mouseLock) 
    window.warpPointer((int) oldMouse.x, (int) oldMouse.y);
    
  mouseLock = false;
}

//Key down
void keyPressed()
{
  if (keyCode >= 0 && keyCode < 256)
    keys[keyCode] = true;
    
  if(key == 'p')
  {
    if(mouseLock)
      unlockMouse();
      
    else
      lockMouse();
  }
}

//Key up
void keyReleased() 
{
  if (keyCode >= 0 && keyCode < 256)
    keys[keyCode] = false;
}

//Grabs key
boolean keyDown(int key) 
{
  return keys[key];
}

//Checks if mouse buttons are pressed
void mousePressed()
{
   
}
