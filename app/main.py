from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_std_6510110004():
    return {"message": "Hello World from std_6510110004"}
