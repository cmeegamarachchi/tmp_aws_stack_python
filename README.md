# aaf-api-py
appsolve application blocks fast-api starter kit  

`aab-api-py` is a Python, Fast-API based api starter kit. Its build around best practices such as router based feature moudles.  

Some of the highlevel features  
1. Feature modules. All features are hosted in `features` folder and common code is hosted in `common` folder

### To start
Install the dependencies  
```bash
cd api
pip install -r requirements.txt
cd ..
uvicorn api:app --reload
```