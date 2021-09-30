#export PATH=$PATH:/home/metairie/.local/bin/
sudo apt install pip
sudo apt install swig
sudo apt install libosmesa6-dev
sudo apt install patchelf

pip install tensorflow==2.6.0rc1 
pip install keras-rl2 

# add to .bashrc
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/metairie/.mujoco/mujoco200/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/metairie/.mujoco/mjpro150/bin

# mujoco200 folder unzip  into ~/.mujoco/
# https://www.roboti.us/download/mujoco200_linux.zip

# mjpro150 folder unzip into ~/.mujoco/
# https://www.roboti.us/download/mjpro150_linux.zip

# licence mjkey.txt into ~/.mujoco

git clone https://github.com/openai/mujoco-py.git
cd mujoco-py
python3 setup.py install

pip install gym
pip install gym[all]
pip install pyopengl
pip install ale-py
pip install PyOpenGL_accelerate