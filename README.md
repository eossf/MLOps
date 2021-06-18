

# MLOps Labs

## Installation Docker Jupyter

We will install jupyter/tensorflow-notebook which contains scipy, minimal and base image:

- jupyter/base-notebook

    is a small image supporting the options common across all core stacks. It is the basis for all other stacks.
    Minimally-functional Jupyter Notebook server (e.g., no LaTeX support for saving notebooks as PDFs)
    Miniforge Python 3.x in /opt/conda with two package managers
    notebook, jupyterhub and jupyterlab packages
    No preinstalled scientific computing packages

- jupyter/minimal-notebook

    add TeX Live for notebook document conversion, git, vi (actually vim-tiny), nano (actually nano-tiny), tzdata, and unzip

- jupyter/scipy-notebook

    add altair, beautifulsoup4, bokeh, bottleneck, cloudpickle, conda-forge::blas=*=openblas, cython, dask, dill, h5py, matplotlib-base, numba, numexpr, pandas, patsy, protobuf, pytables, scikit-image, scikit-learn, scipy, seaborn, sqlalchemy, statsmodel, sympy, widgetsnbextension, xlrd packages, ipympl and ipywidgets for interactive visualizations and plots in Python notebooks, Facets for visualizing machine learning datasets

- jupyter/tensorflow-notebook

    add tensorflow machine learning library


````bash
echo "Install Jupyter tf notebook"
docker pull jupyter/tensorflow-notebook
docker run -p 8888:8888 --rm --user $(id -u):$(id -g) --group-add users -v "${PWD}":/home/jovyan/work jupyter/tensorflow-notebook
````

You can open up with the url displayed in the container log, for example : http://127.0.0.1:8888/?token=1390c921c5b804919597266b1a8c634700b410fc09459078


## Reference

https://github.com/jupyter/jupyter/wiki
