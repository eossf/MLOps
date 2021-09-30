import ale_py
from ale_py import ALEInterface

# ale import game
from ale_py.roms import Breakout
ale = ALEInterface()
ale.loadROM(Breakout)
