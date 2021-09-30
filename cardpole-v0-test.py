import gym
import time

env = gym.make('CartPole-v0')
env.reset()

for _ in range(10):
    env.render()
    env.step(env.action_space.sample())
    time.sleep(0.5)
    env.reset()

env.close()