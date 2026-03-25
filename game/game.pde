// VARIABLES

enum Level
{
  MENU,
  LEVEL1
}

public Level currentLevel = Level.MENU;

// FUNCTIONS

public void game()
{
  while (true)
  {
    if (currentLevel == Level.MENU)
    {
      size();
      background(#6DB9E0);
    }
  }
}
