import gym
import time

from gym import envs

env = gym.make('CartPole-v0')
env.reset()
env.render()

time.sleep(5)
env.close()
