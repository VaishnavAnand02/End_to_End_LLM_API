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
async def generate(request: Query):
    # THE NEW WAY (Perfect for Llama 3.1)
    output = llm.create_chat_completion(
    messages=[
        {"role": "system", "content": "You are a helpful, highly technical AI assistant."},
        {"role": "user", "content": request.prompt}
    ],
    max_tokens=request.max_tokens
    )
    response_text = output['choices'][0]['message']['content']

    return {"response": response_text}