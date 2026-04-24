from settings.config import MODEL_PATH,MAX_TOKENS,N_CTX
from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama
app = FastAPI()

llm = Llama(model_path = MODEL_PATH,n_ctx = N_CTX,verbose = True)

class Query(BaseModel):
    prompt:str
    max_tokens: int = MAX_TOKENS

@app.post("/generate")
async def generate(query: Query):
    output = llm(
        prompt = query.prompt,
        max_tokens = query.max_tokens,
        stop = ["Q:","\n"]
    )

    return {"response": output["choices"][0]["text"]}