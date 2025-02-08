import aiofiles
import json

async def read_from_json(file_path: str):
    async with aiofiles.open(file_path, 'r', encoding='utf-8') as f:
        content = await f.read()
    return json.loads(content)